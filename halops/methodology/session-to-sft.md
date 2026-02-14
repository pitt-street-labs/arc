# Session-to-SFT Pipeline

This document describes how raw Claude Code session transcripts are transformed into supervised fine-tuning (SFT) training pairs suitable for training a domain-specialized language model.

## Source Data: Claude Code JSONL Sessions

Claude Code stores every session as a JSONL (JSON Lines) file under `~/.claude/projects/<project-dir>/`. Each line is a JSON record representing one event in the conversation.

### JSONL Record Structure

Each record has these key fields:

```json
{
  "type": "user|assistant|system|summary|file-history-snapshot",
  "uuid": "unique-id",
  "parentUuid": "parent-unique-id",
  "timestamp": "2026-01-15T14:32:00.000Z",
  "message": {
    "role": "user|assistant",
    "content": "..."
  }
}
```

The `content` field can be either a plain string or a list of content blocks:

```json
{
  "content": [
    {"type": "text", "text": "Let me check the server status."},
    {"type": "thinking", "thinking": "I need to SSH to server-1 first..."},
    {"type": "tool_use", "id": "toolu_xxx", "name": "Bash", "input": {"command": "ssh labadmin@10.0.10.20 uptime"}},
    {"type": "tool_result", "tool_use_id": "toolu_xxx", "content": "14:32:01 up 42 days..."}
  ]
}
```

### Session Threading

Sessions have a tree structure via `uuid`/`parentUuid` linking. Assistant responses may be split across multiple records (thinking, text, tool_use as separate JSONL lines). The extraction step rebuilds the conversation graph and merges these into coherent turns.

### Subagent Conversations

Claude Code spawns subagent threads for delegated tasks. These live in `<session-dir>/subagents/agent-*.jsonl` and are independent conversation trees. They are excellent training data because they tend to be focused, tool-dense, single-task conversations.

### External Tool Results

Large tool outputs are stored as separate files in `<session-dir>/tool-results/toolu_*.txt`. The extraction step reattaches these to their corresponding tool calls.

## Pipeline Stage 1: Extract

**Script**: `data/scripts/extract_sessions.py`

The extraction step:

1. **Discovers** all session JSONL files across project directories
2. **Parses** each file into a list of records
3. **Builds** a conversation graph using `uuid`/`parentUuid` threading
4. **Traverses** the graph via iterative DFS to produce a linear conversation
5. **Merges** consecutive assistant records into single turns (reuniting thinking + text + tool_use that were split across records)
6. **Absorbs** tool_result records back into the preceding assistant turn's tool calls
7. **Enriches** tool calls with external tool results from the filesystem
8. **Extracts** subagent conversations as independent training examples

**Output**: `data/extracted/sessions.jsonl` + `data/extracted/subagents.jsonl`

Each output record contains:

```json
{
  "session_id": "abc123",
  "project_dir": "-home-labadmin-projects-infrastructure",
  "summary": "Configured VLAN 30 on switch...",
  "turn_count": 24,
  "user_turn_count": 12,
  "assistant_turn_count": 12,
  "turns": [
    {"role": "user", "content": "Add VLAN 30 to the switch"},
    {"role": "assistant", "content": "...", "thinking": "...", "tool_calls": [...]},
    ...
  ]
}
```

## Pipeline Stage 2: Qualify

**Script**: `data/scripts/qualify_sessions.py`

Not all sessions are equally valuable for training. The qualification step scores each session on a 0.0-1.0 composite scale across six dimensions:

| Dimension | Weight | What It Measures |
|-----------|--------|------------------|
| **Completion** | 0.25 | Does the session reach a clean conclusion? Summary present, no trailing errors, no dangling tool calls |
| **Depth** | 0.15 | Conversation length. 5-50 user turns is optimal; very short sessions lack context, very long ones are noisy |
| **Domain Relevance** | 0.25 | Keyword matching against infrastructure vocabulary (IP addresses, hostnames, tool names, protocols) |
| **Tool Richness** | 0.15 | Fraction of assistant turns containing tool calls. 30-70% is ideal (pure text or pure tool use are less valuable) |
| **Thinking Quality** | 0.10 | Fraction of assistant turns with thinking/reasoning blocks |
| **Error Ratio** | 0.10 | Inverse of tool call error frequency. Fewer errors = higher score |

Subagent conversations receive a 1.2x bonus on the tool richness score (capped at 1.0) because they are inherently tool-dense.

### Tier Assignment

| Tier | Composite Score | Usage |
|------|----------------|-------|
| **A** | >= 0.7 | Primary SFT training data (multi-turn and single-turn) |
| **B** | 0.4 - 0.7 | DPO preference pairs, augmentation source material |
| **C** | < 0.4 | Skipped, or used only as negative DPO examples |

**Output**: `data/qualified/session_scores.jsonl`

## Pipeline Stage 3: Curate

**Script**: `data/scripts/curate_training_data.py`

The curation step transforms qualified sessions into ChatML-formatted training examples using four complementary strategies:

### Strategy A: Multi-Turn Conversations

Full conversation histories from Tier A sessions, preserving the natural flow of multi-step operations. These teach the model how to:
- Maintain context across a long task
- Chain tool calls with intermediate reasoning
- Adapt plans based on tool output

**Selection criteria**: Tier A only, minimum 4 turns (2 user-assistant exchanges).

**Token budget**: ~4,096 tokens per example. If a conversation exceeds the budget, it is truncated to fit.

**Skill matching**: Each session is matched to a domain skill (firewall, switch, monitoring, etc.) based on keyword frequency. The matched skill's documentation is included in the system prompt, teaching the model to leverage retrieved knowledge.

### Strategy B: Single-Turn Instruction Pairs

Individual user question + assistant answer pairs extracted from all tiers. These teach focused Q&A patterns.

**Filtering**:
- User messages under 20 characters are skipped (tool result acknowledgments)
- Assistant responses must be at least 50 characters of substantive text
- Each pair gets a generic system prompt

### Strategy C: Skill-as-System-Prompt

Procedural Q&A generated directly from operational skill documents. For each section of a skill document that contains code blocks, bullet lists, or troubleshooting steps, the curation step generates question-answer pairs:
- "How do I [section header]?"
- "What are the steps for [section header]?"
- "How do I troubleshoot [section header]?"

These ensure coverage of documented procedures even if they do not appear in session history.

### Strategy D: Subagent Task Execution

Subagent conversations treated as first-class training examples. The delegation prompt (first user message) becomes the user turn, and the entire subagent tool chain becomes the assistant response. This teaches the model to:
- Execute focused, delegated tasks
- Chain multiple tool calls in sequence
- Report results concisely

### Output Format

All strategies produce the same ChatML message format:

```json
{
  "messages": [
    {"role": "system", "content": "You are HALops, an AI agent..."},
    {"role": "user", "content": "Check if firewall is healthy"},
    {"role": "assistant", "content": "<think>I should SSH...</think>\n\nLet me check...\n<tool_call>{\"name\": \"SSH\", \"host\": \"10.0.10.1\", \"command\": \"uptime\"}</tool_call>\n<tool_result>up 42 days</tool_result>\n\nFirewall is healthy..."}
  ],
  "strategy": "multiturn|singleturn|skill|subagent",
  "tier": "A|B|skill",
  "score": 0.85
}
```

**Output**: `data/curated/sft_multiturn.jsonl`, `sft_singleturn.jsonl`, `sft_skills.jsonl`, `sft_subagents.jsonl`

## Pipeline Stage 4: Validate

**Script**: `data/scripts/validate_data.py`

The final quality gate before training applies four checks:

### 4a. Credential Scrubbing

An extensive regex-based scanner detects and replaces potential credentials with `<REDACTED>`:
- Passwords, passphrases, API keys, tokens
- SSH/GPG private keys
- Bearer tokens, SNMP community strings
- Base64-encoded secrets near credential context
- Database passwords, IPMI passwords in command context

Safe patterns (already-redacted placeholders, variable references, documentation text) are whitelisted to avoid false positives. An optional post-scrub audit re-scans the final output to catch anything missed.

### 4b. Format Validation

Each example must have:
- At least one user message and one assistant message
- Non-empty assistant content
- Total content under ~4,096 tokens (estimated at 4 characters per token)

### 4c. Deduplication

MinHash-based near-duplicate detection with Jaccard similarity threshold of 0.85:
- 3-word shingles computed from user + assistant content
- 128-permutation MinHash signatures
- O(n^2) pairwise comparison (feasible for datasets under ~10K examples)
- When duplicates are found, the higher-scored example is kept

### 4d. Train/Val/Test Split

90/5/5 split with two critical constraints:

1. **Session-level splitting**: All examples from the same session go to the same split. This prevents data leakage where the model sees part of a conversation in training and is tested on another part.

2. **Domain stratification**: Examples are grouped by domain (firewall, switch, storage, monitoring, etc.) and each domain is split independently, ensuring all domains are represented in all splits.

**Output**: `data/final/train.jsonl`, `val.jsonl`, `test.jsonl`, `data_report.json`

## What Makes Good vs. Bad Training Examples

### Good Examples

- **Complete multi-step operations**: User asks to configure something, assistant thinks through the approach, executes commands, verifies success, handles errors
- **Troubleshooting with diagnosis**: Assistant reasons about possible causes, runs diagnostic commands, narrows down the issue, applies a fix
- **Domain-specific vocabulary in context**: IP addresses, hostnames, protocol names used naturally in operational sentences
- **Error recovery**: A tool call fails, assistant adjusts approach and tries an alternative
- **Credential hygiene**: Credentials referenced via `<from-secrets>` placeholder, never hardcoded

### Bad Examples

- **Trivial exchanges**: "OK" / "Done" with no substance
- **Hallucinated infrastructure**: References to servers, IPs, or tools that do not exist in your environment
- **Raw tool dumps**: Large unprocessed command output without interpretation
- **Incomplete sessions**: Task started but never finished (abandoned mid-operation)
- **Credential exposure**: Real passwords, API keys, or private keys in the training data

## Optional: API-Based Augmentation

**Script**: `data/scripts/augment_data.py`

For environments where session data alone is insufficient, additional training data can be generated using a frontier model API:

| Strategy | Description | Use Case |
|----------|-------------|----------|
| **DPO Pairs** | Take Tier B session responses and generate improved versions | Preference alignment training |
| **Synthetic Scenarios** | Generate emergency/edge-case scenarios with tool call chains | Coverage of rare but critical operations |
| **Skill Q&A Expansion** | Generate 20-50 Q&A pairs per skill document | Ensure procedural coverage |
| **RLM Decomposition** | Generate recursive task decomposition examples | Teach multi-step planning |

This step is optional and costs money (API calls). Use `--dry-run` to estimate costs before running.

## Adapting for Your Environment

To apply this pipeline to your own infrastructure:

1. **Accumulate sessions**: Use Claude Code for your daily operations for at least 2-4 weeks. The more diverse the sessions, the better.

2. **Customize domain patterns**: Edit the `DOMAIN_PATTERNS` dictionary in `qualify_sessions.py` to match your infrastructure vocabulary (IP ranges, hostnames, tools, protocols).

3. **Update credential patterns**: Add any environment-specific credential formats to the `CREDENTIAL_PATTERNS` list in `validate_data.py`.

4. **Write skill documents**: Create structured markdown documents covering your operational procedures. These feed Strategy C directly and improve Strategy A's system prompts.

5. **Adjust quality thresholds**: The tier boundaries (0.7 for A, 0.4 for B) may need tuning based on your session quality distribution. Start with the defaults and adjust after reviewing the tier distribution.
