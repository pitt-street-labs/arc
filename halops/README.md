# HALops: Fine-Tuning a Local LLM on AI Coding Assistant Session Data

**HALops** (Heuristic AI for Lab Operations) is a methodology for fine-tuning a small open-source LLM on Claude Code session transcripts to create a domain-specialized autonomous agent. The resulting model runs entirely on consumer hardware (8GB VRAM GPU + 64GB system RAM) and can execute infrastructure operations via SSH, IPMI, HTTP APIs, and shell commands.

This document describes the approach generically so anyone with access to Claude Code sessions and a consumer GPU can replicate it for their own domain.

## The Problem

Large frontier models (Claude, GPT-4) are excellent at infrastructure operations but require cloud API access, incur per-token costs, and send sensitive operational data to third parties. Small open-source models (7B parameters) are fast and private but lack domain-specific knowledge about your particular environment.

## The Insight

Claude Code sessions are structured JSONL transcripts containing:
- User requests for real infrastructure operations
- Extended thinking/reasoning about how to approach problems
- Tool calls (shell commands, SSH, file operations) with actual results
- Multi-step problem solving with error recovery
- Domain-specific vocabulary, IP addresses, procedures, and tribal knowledge

This is exactly the kind of high-quality, domain-specific training data that supervised fine-tuning needs, and you are already generating it as a byproduct of daily work.

## Architecture

```
 Claude Code Sessions (.jsonl)
          |
          v
 [1] Extract & Parse -----> Structured conversations
          |
          v
 [2] Score & Qualify -----> Tiered by quality (A/B/C)
          |
          v
 [3] Curate & Format -----> ChatML training pairs
          |                   (4 strategies: multi-turn,
          |                    single-turn, skills, subagents)
          v
 [4] Validate & Split ----> Dedup, credential scrub,
          |                   train/val/test splits
          v
 [5] QLoRA SFT -----------> 4-bit quantized fine-tuning
          |                   on consumer GPU
          v
 [6] Merge & Convert -----> GGUF quantized model
          |
          v
 [7] Deploy (llama.cpp) --> OpenAI-compatible API
          |
          v
 [8] Agent Loop ----------> RAG + tool execution + safety checks
```

## Why This Approach Works

### QLoRA on Session Data

**QLoRA** (Quantized Low-Rank Adaptation) lets you fine-tune a 7B parameter model on an 8GB consumer GPU by:
- Loading the base model in 4-bit precision (NF4 quantization)
- Training only small low-rank adapter matrices (33M trainable parameters out of 7B total)
- Using gradient checkpointing and paged optimizers to fit in VRAM

**Session data** is superior to synthetic training data because:
- It captures real operational patterns, not idealized ones
- Error recovery and debugging paths are naturally represented
- Tool call patterns match actual infrastructure APIs
- Domain vocabulary is used in context, not in isolation
- The reasoning traces (thinking blocks) teach the model how to plan, not just what to do

### Base Model Selection: Qwen2.5-7B-Instruct

The base model was chosen for these reasons:

| Criterion | Qwen2.5-7B-Instruct |
|-----------|---------------------|
| Size | 7B parameters -- fits in 8GB VRAM with QLoRA |
| Instruction following | Strong out-of-box instruction compliance |
| Code/tool use | Pre-trained on code, understands JSON tool schemas |
| Chat template | ChatML format (`<\|im_start\|>/<\|im_end\|>`) -- clean, well-supported |
| License | Apache 2.0 -- fully permissive |
| Vocabulary | 151K tokens -- large vocab handles technical terms well |
| Community | Extensive llama.cpp and GGUF support |

### RAG Augmentation

The fine-tuned model is supplemented with retrieval-augmented generation (RAG) over operational documentation:
- ChromaDB vector store with all-MiniLM-L6-v2 embeddings
- Skill documents, runbooks, and network topology indexed
- Retrieved context injected into the system prompt at query time
- The fine-tuned model understands how to use retrieved context because training data included skill-augmented system prompts

## Results: v1 Training Run

| Metric | Value |
|--------|-------|
| Training examples | 2,891 |
| Training time | ~14 hours (single consumer GPU) |
| Final loss | 0.48 |
| Eval accuracy | ~60% (8 pass / 8 partial / 4 fail on 20 questions) |
| Inference speed | 2,401 tok/s prompt processing, 84 tok/s generation |
| Model size (Q4_K_M) | 4.4 GB |
| VRAM usage (inference) | ~5 GB |

**Strengths observed**: Network topology recall, credential handling patterns, Linux system administration, monitoring stack queries.

**Weaknesses observed**: Hardware-specific hallucination (confusing server models), VLAN assignment errors, incomplete multi-step procedures.

## Safety Architecture

HALops includes a multi-layer safety system:

1. **Command blocklist**: Regex patterns block destructive commands (`rm -rf`, `dd`, `mkfs`, `iptables -F`, pipe-to-shell)
2. **Confirmation tier**: Dangerous-but-legitimate commands (reboot, power cycle, ZFS destroy) require explicit user confirmation
3. **Host allowlist**: SSH/IPMI/HTTP calls are restricted to known infrastructure IPs
4. **Credential scrubbing**: Output is scanned for private keys, passwords, and tokens before display
5. **Rate limiting**: Maximum 30 commands per 60-second window prevents runaway execution
6. **Iteration cap**: Agent loop is hard-limited to 10 iterations per query

## Repository Structure

```
halops/
  data/
    scripts/           # Data pipeline scripts
      extract_sessions.py
      qualify_sessions.py
      curate_training_data.py
      validate_data.py
      augment_data.py   # Optional: Claude API augmentation
    extracted/          # Raw parsed sessions
    qualified/          # Scored and tiered sessions
    curated/            # ChatML-formatted training pairs
    augmented/          # API-augmented data (DPO, synthetic)
    final/              # Train/val/test splits
  training/
    configs/            # YAML hyperparameter configs
    scripts/            # Training, merging, GGUF conversion
    checkpoints/        # Training checkpoints
    logs/               # TensorBoard logs
  eval/
    benchmark.py        # Automated evaluation harness
    test_cases/         # JSONL test case files
    reports/            # Benchmark results
  inference/
    halops_agent.py     # Main agent loop
    halops_server.py    # llama-server manager
    safety_checks.py    # Command validation
    tool_executor.py    # SSH/IPMI/HTTP execution
    templates/          # System prompts
    systemd/            # Service unit files
  rag/
    scripts/            # RAG indexing and query
    documents/          # Source documents for indexing
    chromadb/           # Vector store
  scripts/
    full_pipeline.sh    # End-to-end pipeline runner
    deploy.sh           # Model deployment
    monitor.sh          # Service health dashboard
```

## Getting Started

### Prerequisites

- Python 3.10+
- NVIDIA GPU with 8+ GB VRAM (training and inference)
- 64 GB system RAM (model loading during merge)
- llama.cpp built from source (for GGUF conversion and inference)
- Claude Code session data (JSONL files from `~/.claude/projects/`)

### Quick Start

```bash
# 1. Bootstrap environment
bash setup.sh

# 2. Run data pipeline
python data/scripts/extract_sessions.py -v
python data/scripts/qualify_sessions.py -v
python data/scripts/curate_training_data.py
python data/scripts/validate_data.py -v

# 3. Train (ensure GPU is free)
python training/scripts/train_sft.py --config training/configs/sft_qlora.yaml

# 4. Merge and convert
python training/scripts/merge_lora.py
bash training/scripts/convert_to_gguf.sh

# 5. Deploy and test
bash scripts/deploy.sh
python eval/benchmark.py -v
```

## Further Reading

- [Session-to-SFT Pipeline](methodology/session-to-sft.md) -- How sessions become training data
- [QLoRA Training Approach](methodology/qlora-approach.md) -- Hyperparameters and model selection
- [Evaluation Framework](eval/evaluation-framework.md) -- How accuracy is measured
- [Training Pipeline Overview](training/pipeline-overview.md) -- End-to-end pipeline diagram
