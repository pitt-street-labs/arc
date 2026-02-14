# QLoRA Training Approach

This document covers the training methodology for HALops: why QLoRA was chosen, what hyperparameters are used, how the base model was selected, and how the trained model is converted for efficient inference.

## Why QLoRA

### The VRAM Problem

Full fine-tuning of a 7B parameter model requires approximately 56 GB of VRAM (model weights in fp16 + optimizer states + gradients). This exceeds even high-end consumer GPUs. Cloud GPU rental works but adds ongoing cost and latency.

**QLoRA** (Quantized Low-Rank Adaptation) solves this by combining three techniques:

1. **4-bit NormalFloat quantization (NF4)**: The base model weights are quantized to 4 bits, reducing the 14 GB fp16 model to ~4 GB in memory. NF4 is information-theoretically optimal for normally distributed weights.

2. **Double quantization**: The quantization constants themselves are quantized, saving an additional ~0.4 GB.

3. **Low-Rank Adapters (LoRA)**: Instead of updating all 7B parameters, small rank-16 matrices are inserted into each attention and feed-forward layer. Only these adapters are trained (~33M parameters, or 0.5% of the model).

4. **Paged optimizers**: AdamW optimizer states are paged to CPU RAM when GPU memory is exhausted, preventing OOM crashes during gradient spikes.

The result: a 7B model can be fine-tuned on a consumer GPU with 8 GB VRAM.

### Comparison with Alternatives

| Method | VRAM Required | Training Speed | Quality |
|--------|---------------|----------------|---------|
| Full fine-tuning (fp16) | ~56 GB | Fast | Best |
| LoRA (fp16 base) | ~28 GB | Fast | Very good |
| QLoRA (4-bit base) | **~6-8 GB** | Slower (2-3x) | Good |
| Prompt tuning | ~14 GB | Fastest | Limited |
| In-context learning | ~14 GB | N/A (no training) | Variable |

QLoRA trades training speed for dramatic VRAM reduction. For a 2,891-example dataset with 3 epochs, the 2-3x slowdown translates to ~14 hours instead of ~5 hours -- an acceptable tradeoff for not needing cloud GPUs.

## Base Model Selection

### Why Qwen2.5-7B-Instruct

The model was selected through systematic evaluation of available open-source options:

**Size constraint (7B)**: Must fit in 8 GB VRAM with QLoRA during training AND fit in 8 GB VRAM during inference (as a GGUF quantized model). This rules out 13B+ models without quantization so aggressive it degrades quality.

**Instruction-tuned**: The base model must already follow instructions well. Fine-tuning should add domain knowledge, not teach basic instruction compliance. Starting from a pre-trained (non-instruct) checkpoint would require far more data.

**Code competence**: The model must understand JSON, shell commands, YAML, and structured output formats. Infrastructure operations are inherently code-adjacent.

**Chat template**: ChatML (`<|im_start|>role\ncontent<|im_end|>`) is clean, well-supported by llama.cpp, and does not waste tokens on elaborate formatting.

**Models evaluated**:

| Model | Parameters | Chat Template | Code Quality | Notes |
|-------|-----------|---------------|--------------|-------|
| **Qwen2.5-7B-Instruct** | 7B | ChatML | Excellent | **Selected** -- best overall balance |
| Llama 3.1 8B Instruct | 8B | Llama-style | Good | Larger vocab overhead, custom template |
| Mistral 7B Instruct v0.3 | 7B | Mistral-style | Good | Weaker on structured output |
| Phi-3-medium-128k | 14B | ChatML | Very good | Too large for 8 GB inference |
| CodeLlama 7B Instruct | 7B | Llama-style | Excellent (code) | Weak on natural language ops |

**Qwen2.5-7B-Instruct advantages**:
- 151K token vocabulary handles technical terms without excessive tokenization
- Strong pre-training on code and technical documentation
- Apache 2.0 license (fully permissive)
- Excellent llama.cpp GGUF support
- Active community with regular updates

### The 151K Vocabulary Challenge

Qwen2.5's large vocabulary creates a specific VRAM challenge during training. The language model head (lm_head) must compute logits over 151,000 tokens at each position, which briefly requires ~2 GB for the full logits tensor.

**Solution**: The Liger kernel provides a fused cross-entropy implementation that never materializes the full `[sequence_length, vocab_size]` tensor. Instead, it computes the loss in chunks, reducing peak memory by approximately 1.5 GB. This is applied before model loading:

```python
from liger_kernel.transformers import apply_liger_kernel_to_qwen2
apply_liger_kernel_to_qwen2()
```

Additionally, the standard `prepare_model_for_kbit_training` function attempts to cast all LayerNorm weights to fp32, which allocates ~2 GB temporarily. On an 8 GB GPU, this causes OOM. HALops patches this function to skip the fp32 cast, accepting slightly reduced numerical stability in exchange for fitting within the VRAM budget.

## Hyperparameters

### QLoRA Configuration

```yaml
quantization:
  load_in_4bit: true
  bnb_4bit_quant_type: nf4       # NormalFloat4 -- optimal for normally distributed weights
  bnb_4bit_compute_dtype: bfloat16  # Compute in bf16 for stability
  bnb_4bit_use_double_quant: true   # Quantize the quantization constants

lora:
  r: 16                    # Rank of adapter matrices
  lora_alpha: 32           # Scaling factor (alpha/r = 2.0 effective scaling)
  target_modules:          # Which layers get adapters
    - q_proj               # Query projection (attention)
    - k_proj               # Key projection (attention)
    - v_proj               # Value projection (attention)
    - o_proj               # Output projection (attention)
    - gate_proj            # Gate projection (MLP)
    - up_proj              # Up projection (MLP)
    - down_proj            # Down projection (MLP)
  lora_dropout: 0.05       # Light dropout for regularization
  bias: none               # No bias adaptation
  task_type: CAUSAL_LM
```

**Why rank 16**: Empirically, ranks 8-32 work well for domain adaptation. Rank 16 provides a good balance between capacity (33M trainable parameters) and VRAM usage. Higher ranks risk overfitting on a ~3K example dataset.

**Why all projection layers**: Targeting only attention (q/k/v/o) produces weaker results for domain adaptation. Including the MLP layers (gate/up/down) allows the model to learn new factual associations, not just new attention patterns.

**Alpha/rank ratio of 2.0**: This is a standard scaling factor. Higher ratios (3-4) can accelerate learning but risk instability with small datasets.

### Training Configuration

```yaml
training:
  num_train_epochs: 3
  per_device_train_batch_size: 1
  gradient_accumulation_steps: 8    # Effective batch size = 8
  learning_rate: 2.0e-4
  warmup_ratio: 0.1
  weight_decay: 0.01
  max_seq_length: 1024
  bf16: true
  gradient_checkpointing: true
  optim: paged_adamw_8bit
  lr_scheduler_type: cosine
```

**Why 3 epochs**: With ~2,900 examples, 3 epochs provides ~1,087 training steps (at effective batch size 8). Empirically, loss plateaus around epoch 2.5. More epochs risk overfitting on this dataset size.

**Why batch size 1 with gradient accumulation 8**: A single training example at sequence length 1024 consumes most of the 8 GB VRAM. Gradient accumulation simulates a larger batch by accumulating gradients over 8 forward passes before updating weights.

**Why learning rate 2e-4**: This is the upper end of typical LoRA learning rates. QLoRA can tolerate higher rates than full fine-tuning because only the small adapter matrices are being updated. With cosine scheduling and 10% warmup, the effective rate decays gracefully.

**Why sequence length 1024 (not 4096)**: While Qwen2.5 supports 32K context, each additional token costs VRAM during training. At 1024 tokens per example, the 8 GB GPU can process each example without OOM. The data pipeline already truncates examples to fit this budget. Multi-turn conversations longer than 1024 tokens are split or truncated during curation.

**Why gradient checkpointing**: Trades ~30% training speed for ~40% memory savings by recomputing activations during backward pass instead of storing them.

**Why paged_adamw_8bit**: Combines 8-bit optimizer states (half the memory of fp32 Adam) with paging to CPU RAM. When GPU memory is exhausted, optimizer states are transparently offloaded to system RAM.

## Training Process

### Pre-Training Checklist

1. **Free the GPU**: Stop any other GPU workloads (TTS, inference, etc.)
2. **Verify CUDA**: Confirm GPU is available and has expected VRAM
3. **Check data**: Ensure `data/final/train.jsonl` exists with expected example count
4. **Disk space**: GGUF conversion needs ~30 GB temporary space for the f16 intermediate

### Training Command

```bash
python training/scripts/train_sft.py --config training/configs/sft_qlora.yaml
```

### Monitoring

Training progress is logged to TensorBoard:
- **Loss curve**: Should decrease steadily, reaching ~0.5 by epoch 3
- **Learning rate**: Cosine schedule with warmup visible as initial ramp
- **Gradient norm**: Watch for spikes indicating instability

Checkpoints are saved every 100 steps (keep last 3). Resume from checkpoint if training is interrupted:

```bash
python training/scripts/train_sft.py --config training/configs/sft_qlora.yaml \
    --resume /path/to/checkpoint-XXXX
```

## Post-Training: Merge and Convert

### Step 1: Merge LoRA Adapter

The trained LoRA adapter is separate from the base model. Merging folds the adapter weights back into the base model to produce a standalone HuggingFace model:

```bash
python training/scripts/merge_lora.py
```

This runs on CPU (to avoid VRAM constraints) and produces a full fp16 model (~14 GB).

### Step 2: Convert to GGUF

The merged model is converted to GGUF format for llama.cpp inference:

```bash
bash training/scripts/convert_to_gguf.sh
```

This produces three quantization levels:

| Quantization | Size | Quality | Use Case |
|-------------|------|---------|----------|
| F16 | ~15 GB | Highest | Reference/archival |
| Q4_K_M | ~4.4 GB | Good | **Primary deployment** -- fits in 8 GB VRAM |
| Q5_K_M | ~5.1 GB | Better | Alternative if VRAM allows |

**Q4_K_M** is the recommended deployment quantization. It uses mixed 4-bit and 5-bit quantization with k-means clustering, preserving quality on important layers while aggressively compressing less critical ones.

## Inference Configuration

The GGUF model is served via llama-server (llama.cpp) with these settings:

```
llama-server \
    --model halops-q4_k_m.gguf \
    --host 127.0.0.1 --port 8081 \
    --n-gpu-layers 99 \     # Full GPU offload
    --ctx-size 4096 \        # Context window
    --threads 6 \            # CPU threads for non-GPU work
    --flash-attn \           # Flash attention for speed
    --cont-batching \        # Continuous batching for throughput
    --chat-template chatml   # Match training format
```

This provides an OpenAI-compatible API at `http://127.0.0.1:8081/v1/chat/completions`.

**Inference performance** (Q4_K_M on consumer GPU + 64 GB RAM):
- Prompt processing: ~2,400 tokens/second
- Generation: ~84 tokens/second
- First token latency: ~200ms for typical queries

## Future Training Directions

### DPO Alignment

Direct Preference Optimization using the DPO pairs generated in the augmentation step. This teaches the model to prefer correct, actionable responses over vague or incorrect ones.

### RLM (Recursive Language Modeling)

Training the model to decompose complex operations into sub-tasks using DECOMPOSE/RECURSE_STEP markers in thinking blocks. This improves multi-step planning without additional tool calls.

### Domain-Stratified Training

v2 training uses balanced sampling across infrastructure domains (firewall, switch, storage, monitoring, etc.) to prevent the model from over-specializing on the most common session types.

### Cloud GPU Training

For larger datasets or longer sequence lengths, training can be moved to cloud GPUs (A100 80 GB). The same QLoRA configuration works but with larger batch sizes and sequence lengths:

```yaml
training:
  per_device_train_batch_size: 4      # 4x larger
  gradient_accumulation_steps: 4      # Still effective batch 16
  max_seq_length: 4096                # Full context window
```

Estimated cost: $60-100 for a full training run on cloud A100 instances.
