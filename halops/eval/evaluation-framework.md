# Evaluation Framework

This document describes how HALops model accuracy is measured, the benchmark structure, and results from the v1 training run.

## Evaluation Philosophy

Infrastructure operations models cannot be evaluated like general-purpose LLMs. Standard benchmarks (MMLU, HumanEval, HellaSwag) measure generic capabilities that do not predict whether a model can correctly diagnose a network issue or execute a safe shutdown sequence.

HALops evaluation focuses on three properties:

1. **Factual recall**: Does the model know the correct IP addresses, hostnames, protocols, and procedures for this specific environment?
2. **Operational correctness**: Are the commands it generates syntactically valid and semantically appropriate?
3. **Safety awareness**: Does it avoid destructive operations and use credential placeholders?

## Benchmark Structure

### Test Case Format

Each test case is a JSONL record with:

```json
{
  "id": "unique-test-id",
  "query": "How do I check if the firewall is running?",
  "expected_keywords": ["ssh", "10.0.10.1", "uptime", "opnsense"],
  "category": "firewall"
}
```

The `expected_keywords` list contains terms that a correct response should include. This is a recall-based metric: the model does not need to produce an exact answer, but its response should contain the key factual elements.

### Test Categories

Tests span the major infrastructure domains:

| Category | Description | Example Questions |
|----------|-------------|-------------------|
| **firewall** | Firewall management, rules, VPN | "What OS does the firewall run?" |
| **switch** | Managed switch VLAN and port config | "How do I add a new VLAN on the switch?" |
| **oob** | Out-of-band management (IPMI/BMC) | "Server-2 is unresponsive. How do I check remotely?" |
| **storage** | Disk encryption, ZFS, SMART | "How do I check storage pool health?" |
| **monitoring** | Grafana, Prometheus, Loki | "How do I check recent logs in Grafana?" |
| **network** | DNS, DHCP, WiFi, VLANs | "WiFi clients can't get DHCP. What should I check?" |
| **voip** | PBX, SIP trunks, extensions | "SIP trunk showing unreachable. How to diagnose?" |
| **emergency** | Power outage, shutdown sequences | "Power outage detected. What's the shutdown sequence?" |
| **server** | Hardware platforms, VMs, resources | "What hardware platform is server-1?" |
| **automation** | AI inference, TTS, agent systems | "What is the base model for HALops?" |
| **applications** | Lab applications and services | "What tool is used for video archival?" |

### Two Test Sets

**1. Built-in tests (10 questions)**: Hand-written operational scenarios covering the most common infrastructure tasks. These test practical knowledge: can the model tell you how to check firewall status, add a VLAN, or handle a power outage?

**2. Docs-grounded tests (32 questions)**: Factual accuracy questions derived from operational documentation (manuals M0-M7). These test knowledge recall: does the model know specific IP addresses, hardware models, software versions, and configuration details?

Both test sets can be run independently or combined:

```bash
# Built-in tests only
python eval/benchmark.py -v

# Docs-grounded tests only
python eval/benchmark.py --docs-only -v

# Combined (42 total questions)
python eval/benchmark.py --docs-grounded -v
```

## Scoring Methodology

### Keyword Recall Score (70% weight)

For each test case, the fraction of expected keywords found in the model's response:

```
keyword_score = (matched keywords) / (total expected keywords)
```

Matching is case-insensitive and uses substring matching (e.g., "opnsense" matches "OPNsense"). This favors recall over precision: including extra information is fine, but missing key facts is penalized.

### Response Length Score (30% weight)

Responses are penalized for being too short (likely incomplete) or excessively long (likely rambling):

| Word Count | Length Score |
|-----------|-------------|
| < 20 words | 0.3 |
| 20-49 words | 0.7 |
| 50-300 words | 1.0 |
| > 300 words | 0.8 |

### Composite Score

```
composite = keyword_score * 0.7 + length_score * 0.3
```

### Pass/Fail Thresholds

| Threshold | Meaning |
|-----------|---------|
| >= 0.7 | **Pass** -- response contains most expected information |
| 0.5 - 0.7 | **Partial** -- response has some relevant content but misses key details |
| < 0.5 | **Fail** -- response is missing critical information or incorrect |

## Evaluation Report

Each benchmark run generates a JSON report containing:

```json
{
  "timestamp": "2026-01-29T19:30:00",
  "model": "halops-sft-v1",
  "total_tests": 20,
  "failed_queries": 0,
  "mean_composite": 0.612,
  "pass_rate_50": 0.80,
  "pass_rate_70": 0.40,
  "mean_latency_s": 12.4,
  "category_scores": {
    "firewall": 0.756,
    "network": 0.680,
    "monitoring": 0.621,
    "storage": 0.590,
    "oob": 0.534,
    "voip": 0.498,
    ...
  },
  "source_scores": {
    "built_in": 0.645,
    "docs_grounded": 0.588
  }
}
```

Reports are saved to `eval/reports/` with timestamped filenames for tracking improvement across training iterations.

## v1 Training Results

### Summary

| Metric | Value |
|--------|-------|
| Test set | 20 questions (10 built-in + 10 docs-grounded sample) |
| Pass (>= 0.7) | 8 (40%) |
| Partial (0.5-0.7) | 8 (40%) |
| Fail (< 0.5) | 4 (20%) |
| Mean composite | ~0.60 |
| Mean latency | ~12s per response |

### Category Performance

**Strong categories** (mean > 0.7):
- **Network topology**: The model correctly recalls VLAN assignments, IP address ranges, and network architecture. This is the highest-frequency topic in the training data.
- **Credential handling**: Consistently uses `<from-secrets>` placeholder instead of inventing credentials.
- **Linux administration**: SSH commands, systemctl, journalctl -- strong baseline from the pre-trained model plus session-reinforced patterns.

**Moderate categories** (0.5-0.7):
- **Monitoring stack**: Knows Grafana/Loki/Prometheus exist but sometimes confuses which runs where.
- **Firewall operations**: Correct procedures but occasionally references wrong configuration paths.
- **Emergency procedures**: Gets the general idea but may miss ordering details in shutdown sequences.

**Weak categories** (< 0.5):
- **Hardware specifics**: Hallucinates server model numbers (e.g., confusing DL360 with DL380, mixing up Intel and AMD CPUs). This is a classic SFT failure mode: the model has partial knowledge and fills gaps with plausible-sounding but incorrect details.
- **VLAN details**: Knows VLANs exist but sometimes assigns wrong VLAN numbers to services. This suggests the training data has inconsistent VLAN references across sessions.
- **Multi-step procedures**: When a question requires a 5+ step procedure, the model often gets the first 2-3 steps right but then drifts or hallucinates the remaining steps.

### Failure Analysis

The 4 outright failures share common patterns:

1. **Hallucinated specifics**: The model provides confident but incorrect IP addresses or port numbers. It has learned the pattern of providing specific details but sometimes invents them.

2. **Incomplete tool chains**: When asked about a multi-step operation (e.g., GELI unlock after reboot), the model starts correctly but omits critical middle steps.

3. **Domain confusion**: On questions that span multiple domains (e.g., "WiFi clients can't get DHCP" which involves WiFi AP, DHCP server, VLAN, and firewall), the model addresses only one domain.

4. **Overly generic responses**: Some responses read like general Linux documentation rather than environment-specific procedures. This indicates insufficient domain-specific training examples for that topic.

### Lessons Learned

1. **More examples per domain**: The training set was dominated by firewall and monitoring sessions. Under-represented domains (VoIP, WiFi, storage) performed worst. v2 uses domain-stratified sampling.

2. **Longer sequences needed**: Many operational procedures exceed the 1024-token training limit. Truncated multi-turn conversations lose the most important part (the conclusion). v2 targets 4096-token sequences via cloud GPU training.

3. **Synthetic data helps specific weaknesses**: The augmentation step (emergency scenarios, skill Q&A expansion) directly addresses the "partial knowledge" failure mode by providing explicit, complete answers for each infrastructure topic.

4. **RAG matters for facts**: The model's factual recall improves dramatically when RAG context is provided. Fine-tuning teaches the model how to use retrieved context; RAG provides the facts. Neither alone is sufficient.

## Writing New Test Cases

To add test cases for your environment:

1. Create a JSONL file in `eval/test_cases/`:

```json
{"id": "custom-001", "query": "How do I restart the web proxy?", "expected_keywords": ["systemctl", "restart", "nginx", "10.0.20.30"], "category": "proxy"}
```

2. Run with `--test-file`:

```bash
python eval/benchmark.py --test-file eval/test_cases/custom.jsonl -v
```

### Guidelines for Good Test Cases

- **Be specific**: "How do I check server status?" is too vague. "How do I check server-2's hardware status using out-of-band management?" is better.
- **Include verifiable keywords**: The expected keywords should be facts, not opinions. IP addresses, tool names, and configuration paths are good keywords.
- **Cover failure modes**: Include questions about error scenarios, not just happy-path operations.
- **Balance categories**: Aim for at least 3-5 questions per infrastructure domain.
- **Include multi-step operations**: These expose the model's weakest area and are the most operationally important.

## Continuous Evaluation

As new training runs are produced, benchmark results are compared across versions:

```bash
# Run benchmark on current model
python eval/benchmark.py --model-name "sft-v2" -v

# Compare reports
ls eval/reports/
# benchmark_sft-v1_20260129_193000.json
# benchmark_sft-v2_20260215_103000.json
```

Track these metrics across versions:
- **Mean composite score** (target: 0.75+)
- **Pass rate at 0.7** (target: 60%+)
- **Per-category scores** (no category below 0.5)
- **Worst-case performance** (minimum composite across all tests)
- **Latency** (should stay under 15s per response)
