# Training Pipeline Overview

This document provides a high-level view of the end-to-end HALops training pipeline, from raw Claude Code sessions to a deployed inference model.

## Pipeline Diagram

```
                     RAW DATA SOURCES
  ========================================================
  |                          |                            |
  Claude Code Sessions    Skill Documents          Claude API
  (~/.claude/projects/)   (~/.claude/skills/)     (augmentation)
  |                          |                            |
  ========================================================
                             |
                      PHASE 1: DATA PIPELINE
  ========================================================
  |                                                       |
  | [1] EXTRACT                                           |
  |   extract_sessions.py                                 |
  |   - Parse JSONL session files                         |
  |   - Build conversation graphs (uuid/parentUuid)       |
  |   - Merge split assistant turns                       |
  |   - Extract subagent conversations                    |
  |   - Reattach external tool results                    |
  |   Output: extracted/sessions.jsonl                    |
  |           extracted/subagents.jsonl                    |
  |                          |                            |
  | [2] QUALIFY                                           |
  |   qualify_sessions.py                                 |
  |   - Score 6 dimensions (completion, depth, domain,    |
  |     tool richness, thinking, error ratio)             |
  |   - Assign tiers: A (>=0.7), B (0.4-0.7), C (<0.4)  |
  |   Output: qualified/session_scores.jsonl              |
  |                          |                            |
  | [3] CURATE                                            |
  |   curate_training_data.py                             |
  |   - Strategy A: Multi-turn from Tier A sessions       |
  |   - Strategy B: Single-turn Q&A from all tiers        |
  |   - Strategy C: Skill Q&A from documentation          |
  |   - Strategy D: Subagent task execution               |
  |   - All output in ChatML format                       |
  |   Output: curated/sft_multiturn.jsonl                 |
  |           curated/sft_singleturn.jsonl                |
  |           curated/sft_skills.jsonl                    |
  |           curated/sft_subagents.jsonl                 |
  |                          |                            |
  | [3.5] AUGMENT (optional)                              |
  |   augment_data.py (requires Claude API key)           |
  |   - DPO preference pairs from Tier B sessions        |
  |   - Synthetic emergency scenarios                     |
  |   - Skill Q&A expansion (25 pairs/skill)             |
  |   - RLM recursive decomposition examples             |
  |   Output: augmented/dpo_pairs.jsonl                   |
  |           augmented/synthetic_scenarios.jsonl          |
  |           augmented/skill_qa.jsonl                    |
  |           augmented/rlm_decomposition.jsonl           |
  |                          |                            |
  | [4] VALIDATE                                          |
  |   validate_data.py                                    |
  |   - Credential scrubbing (regex patterns)             |
  |   - Format validation (roles, length, content)        |
  |   - MinHash deduplication (Jaccard > 0.85)            |
  |   - Stratified train/val/test split (90/5/5)          |
  |   - No session leakage across splits                  |
  |   Output: final/train.jsonl                           |
  |           final/val.jsonl                             |
  |           final/test.jsonl                            |
  |           final/data_report.json                      |
  |                                                       |
  ========================================================
                             |
                      PHASE 2: TRAINING
  ========================================================
  |                                                       |
  | [5] SFT TRAINING                                      |
  |   train_sft.py + sft_qlora.yaml                       |
  |   - Load Qwen2.5-7B-Instruct in 4-bit (NF4)         |
  |   - Apply Liger kernel for 151K vocab efficiency      |
  |   - Patch kbit_training for 8GB VRAM compatibility    |
  |   - QLoRA: r=16, alpha=32, all proj layers            |
  |   - 3 epochs, lr=2e-4, cosine schedule                |
  |   - Gradient checkpointing + paged_adamw_8bit         |
  |   - TensorBoard logging                               |
  |   Output: models/lora/sft-v1/ (LoRA adapter)         |
  |                          |                            |
  | [6] MERGE ADAPTER                                     |
  |   merge_lora.py                                       |
  |   - Load base model in fp16 on CPU                    |
  |   - Load and merge LoRA adapter                       |
  |   - Save standalone HuggingFace model                 |
  |   Output: models/merged/sft-v1/ (~14GB)               |
  |                          |                            |
  | [7] CONVERT TO GGUF                                   |
  |   convert_to_gguf.sh                                  |
  |   - HF -> GGUF F16 (via llama.cpp convert script)     |
  |   - Quantize: Q4_K_M (4.4GB), Q5_K_M (5.1GB)        |
  |   Output: models/gguf/halops-q4_k_m.gguf             |
  |           models/gguf/halops-q5_k_m.gguf             |
  |           models/gguf/halops-f16.gguf                 |
  |                                                       |
  ========================================================
                             |
                      PHASE 3: DEPLOYMENT
  ========================================================
  |                                                       |
  | [8] DEPLOY                                            |
  |   deploy.sh                                           |
  |   - Stop conflicting GPU workloads                    |
  |   - Run llama-bench (speed benchmark)                 |
  |   - Start llama-server as systemd service             |
  |   - Health check and smoke test                       |
  |   Endpoint: http://127.0.0.1:8081/v1/chat/completions|
  |                          |                            |
  | [9] EVALUATE                                          |
  |   benchmark.py                                        |
  |   - Run 10 built-in + 32 docs-grounded tests         |
  |   - Score: keyword recall (70%) + length (30%)        |
  |   - Per-category and per-source breakdown             |
  |   Output: eval/reports/benchmark_*.json               |
  |                                                       |
  ========================================================
                             |
                      PHASE 4: RUNTIME
  ========================================================
  |                                                       |
  | AGENT LOOP (halops_agent.py)                          |
  |   User query                                          |
  |     -> RAG context retrieval (ChromaDB)               |
  |     -> System prompt + RAG + user message             |
  |     -> Model inference (llama-server)                 |
  |     -> Parse <tool_call> blocks                       |
  |     -> Safety check (blocklist, allowlist, rate limit)|
  |     -> Execute (SSH / IPMI / HTTP / shell)            |
  |     -> Scrub output for credentials                   |
  |     -> Feed results back to model                     |
  |     -> Repeat (max 10 iterations)                     |
  |     -> Final text response to user                    |
  |                                                       |
  ========================================================
```

## Running the Full Pipeline

### One-Shot Execution

The `full_pipeline.sh` script runs the data pipeline and training in sequence:

```bash
# Full pipeline (data + training)
bash scripts/full_pipeline.sh

# Data pipeline only (skip training)
bash scripts/full_pipeline.sh --skip-train
```

### Step-by-Step Execution

For more control, run each step individually:

```bash
# Activate virtual environment
source venv/bin/activate

# Phase 1: Data Pipeline
python data/scripts/extract_sessions.py -v      # ~2 min
python data/scripts/qualify_sessions.py -v       # ~30 sec
python data/scripts/curate_training_data.py      # ~1 min
# Optional: python data/scripts/augment_data.py  # ~30 min + API cost
python data/scripts/validate_data.py -v          # ~2 min

# Phase 2: Training
# IMPORTANT: Free the GPU first
python training/scripts/train_sft.py \
    --config training/configs/sft_qlora.yaml     # ~14 hours

python training/scripts/merge_lora.py            # ~5 min (CPU)
bash training/scripts/convert_to_gguf.sh         # ~10 min

# Phase 3: Deploy and Evaluate
bash scripts/deploy.sh                           # ~2 min
python eval/benchmark.py -v                      # ~5 min
```

### Time Estimates

| Step | Duration | Notes |
|------|----------|-------|
| Extract sessions | 2-5 min | Depends on number of sessions |
| Qualify sessions | 30 sec | Fast scoring computation |
| Curate training data | 1-2 min | Includes skill parsing |
| Augment (optional) | 30-60 min | API rate-limited |
| Validate and split | 2-5 min | Dedup is the bottleneck |
| **SFT Training** | **10-14 hours** | Single consumer GPU, 3 epochs |
| Merge adapter | 5 min | CPU-bound, needs 64GB RAM |
| GGUF conversion | 10 min | Includes 3 quantization levels |
| Deploy | 2 min | Server startup + smoke test |
| Benchmark | 5 min | 42 questions at ~12s each |
| **Total** | **~15 hours** | Training dominates |

## Data Flow Sizes (v1 Reference)

| Stage | Examples | Notes |
|-------|----------|-------|
| Raw sessions discovered | ~500 | All Claude Code sessions on disk |
| Extracted (main) | ~350 | After filtering empty/system-only |
| Extracted (subagents) | ~200 | Independent subagent conversations |
| Tier A sessions | ~120 | Highest quality, used for multi-turn |
| Tier B sessions | ~250 | Medium quality, DPO source |
| Tier C sessions | ~180 | Lowest quality, skipped |
| Curated (all strategies) | ~3,200 | Before dedup |
| Augmented (API) | ~600 | DPO + synthetic + skill Q&A + RLM |
| After dedup | ~2,900 | Near-duplicates removed |
| **Train split** | **~2,600** | 90% |
| Val split | ~145 | 5% |
| Test split | ~145 | 5% |

## Storage Layout

All large artifacts (models, training cache, vector store) live on fast NVMe storage, symlinked from the project directory:

```
/mnt/data-nvme/halops/          # NVMe mount
  models/
    base/                        # Qwen2.5-7B-Instruct (~14GB)
    lora/                        # LoRA adapters (~100MB each)
    merged/                      # Merged HF models (~14GB each)
    gguf/                        # GGUF quantized (~4-15GB each)
  chromadb/                      # RAG vector store (~200MB)
  training-cache/                # HuggingFace cache

~/projects/halops/models -> /mnt/data-nvme/halops/models  # Symlink
```

Total NVMe budget: ~50 GB per training run (base + merged + GGUF). Old runs can be pruned.

## GPU VRAM Budget

The consumer GPU (8 GB) is shared between training and inference. Only one can run at a time.

**During training**:
- Base model (4-bit): ~4 GB
- LoRA adapters: ~0.1 GB
- Activations (gradient checkpointing): ~2 GB
- Optimizer states (paged): ~1 GB + CPU overflow
- Liger kernel savings: ~1.5 GB
- **Total**: ~7.1 GB peak

**During inference**:
- Q4_K_M model: ~4.4 GB
- KV cache (4096 ctx): ~0.5 GB
- **Total**: ~5 GB

The systemd unit files use `Conflicts=` directives to prevent simultaneous GPU workloads.

## Monitoring the Pipeline

The `monitor.sh` script provides a quick status dashboard:

```bash
bash scripts/monitor.sh
```

Output includes:
- Systemd service status (inference, agent, RAG, TTS)
- Port health checks
- GPU VRAM usage
- NVMe storage usage
- Data pipeline stage sizes
- Latest evaluation report summary

## Iterating on Training

The typical iteration cycle:

1. **Accumulate more sessions**: Continue using Claude Code for operations
2. **Re-run data pipeline**: Extract, qualify, curate, validate
3. **Review data report**: Check domain distribution, example counts, dedup stats
4. **Train**: QLoRA SFT with potentially adjusted hyperparameters
5. **Evaluate**: Run benchmark, compare with previous version
6. **Deploy or iterate**: If scores improve, deploy; otherwise adjust data or hyperparameters

### Common Adjustments

| Symptom | Adjustment |
|---------|-----------|
| Low scores on specific domain | Add more sessions or skill Q&A for that domain |
| Hallucinated facts | Add more docs-grounded test cases; increase RAG retrieval |
| Overfitting (val loss increases) | Reduce epochs, increase dropout, or add more data |
| Under-fitting (high loss plateau) | Increase learning rate, epochs, or LoRA rank |
| OOM during training | Reduce max_seq_length, enable gradient checkpointing |
| Slow inference | Use more aggressive quantization (Q4_K_M -> Q4_K_S) |
