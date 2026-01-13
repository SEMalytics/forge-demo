# Forge Architecture Deep Dive

This document explains how Forge works under the hood.

## The Problem

AI code generation tools (Cursor, Copilot, Claude Code) share a fundamental limitation:

1. **No verification** — They generate, you verify
2. **No memory** — Every generation starts fresh
3. **No self-repair** — When code fails, they can't diagnose why
4. **No patterns** — Proven fixes aren't remembered

## The Solution: Multi-Agent Orchestration

Forge uses 6 sequential layers with parallel agents within layers:

```
Planning → Decomposition → Generation → Testing → Review → Deploy
                                                    ↓
                                        12 parallel agents
                                           vote (8/12)
                                         CRITICAL vetoes
```

## Layer 1: Planning

**File:** `src/forge/layers/planning.py`

Converts natural language requirements into structured tasks.

```python
# Input
"Create a REST API for user management"

# Output (structured)
{
    "tasks": [
        {"id": 1, "type": "model", "description": "User data model"},
        {"id": 2, "type": "api", "description": "CRUD endpoints"},
        {"id": 3, "type": "auth", "description": "JWT authentication"}
    ],
    "dependencies": [[1, 2], [2, 3]]
}
```

## Layer 2: Decomposition

**File:** `src/forge/layers/decomposition.py`

Breaks complex tasks into atomic units that can be generated independently.

## Layer 3: Generation

**File:** `src/forge/layers/generation.py`

Parallel code generation using Claude. Each task becomes a file or function.

## Layer 4: Testing

**File:** `src/forge/layers/testing.py`

Docker-isolated test execution. Runs:
- Unit tests
- Integration tests
- Security scans
- Performance benchmarks

Output is structured, not raw stack traces.

## Layer 5: Review

**File:** `src/forge/layers/review.py`, `src/forge/review/panel.py`

The heart of Forge. 12 specialized agents review in parallel:

| Agent | Focus | Lines in agents.py |
|-------|-------|-------------------|
| SecurityReviewer | OWASP, injection, secrets | 228-307 |
| PerformanceReviewer | O(n²), memory, async | 326-400 |
| ArchitectureReviewer | SOLID, coupling | 403-488 |
| QualityReviewer | Test coverage, edge cases | 491-608 |
| DocumentationReviewer | Docstrings, types | 611-698 |
| ErrorHandlingReviewer | Exception patterns | 701-793 |
| CodeStyleReviewer | PEP 8 | 796-883 |
| APIDesignReviewer | Contracts, params | 886-989 |
| ConcurrencyReviewer | Race conditions | 992-1084 |
| DataValidationReviewer | Input sanitization | 1087-1183 |
| MaintainabilityReviewer | Complexity | 1186-1299 |
| IntegrationReviewer | Compatibility | 1302-1413 |

### Voting System

```python
# src/forge/review/panel.py:348-380
def _review_parallel(self, code, file_path, context):
    with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
        future_to_reviewer = {
            executor.submit(reviewer.review, code, file_path, context): reviewer
            for reviewer in self.reviewers
        }
        # Collect results, abstain on failure
```

- **Threshold:** 8/12 must approve
- **Veto:** Any CRITICAL finding blocks deployment
- **Abstain:** Agent failures don't count against

## Layer 6: Failure Analysis

**File:** `src/forge/layers/failure_analyzer.py`

When tests or reviews fail, this layer diagnoses and fixes.

### 16 Failure Types

```python
# failure_analyzer.py:30-46
class FailureType(Enum):
    SYNTAX_ERROR = "syntax_error"
    IMPORT_ERROR = "import_error"
    ASSERTION_ERROR = "assertion_error"
    TYPE_ERROR = "type_error"
    NAME_ERROR = "name_error"
    ATTRIBUTE_ERROR = "attribute_error"
    KEY_ERROR = "key_error"
    INDEX_ERROR = "index_error"
    VALUE_ERROR = "value_error"
    ZERO_DIVISION_ERROR = "zero_division_error"
    TIMEOUT_ERROR = "timeout_error"
    NETWORK_ERROR = "network_error"
    SECURITY_VULNERABILITY = "security_vulnerability"
    PERFORMANCE_DEGRADATION = "performance_degradation"
    UNKNOWN = "unknown"
```

### Structured Diagnostics

```python
# failure_analyzer.py:78-101
@dataclass
class FixSuggestion:
    failure_type: FailureType      # Enum, not string
    root_cause: str
    suggested_fix: str
    code_changes: List[Dict]       # {"file": path, "old": str, "new": str}
    relevant_patterns: List[str]   # KnowledgeForge pattern filenames
    priority: Priority             # CRITICAL/HIGH/MEDIUM/LOW
    confidence: float              # 0.0-1.0
    explanation: str

    def to_dict(self) -> Dict:     # JSON-serializable
```

### Pattern Matching

**File:** `src/forge/knowledgeforge/pattern_store.py`

Hybrid search combining keyword (FTS5) and semantic (embeddings):

```python
# pattern_store.py:46
self.embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
# 384-dimensional vectors

# failure_analyzer.py:476-489
def _load_relevant_patterns(self, failure_type, error_message):
    query = f"troubleshooting {failure_type.value} {error_message[:50]}"
    return self.pattern_store.search(
        query=query,
        max_results=5,
        method='hybrid'  # FTS5 + semantic combined
    )
```

Storage is SQLite with blob embeddings — no external vector DB required:

```sql
CREATE TABLE patterns (
    embedding BLOB,  -- numpy array as bytes
    ...
);
CREATE VIRTUAL TABLE patterns_fts USING fts5(...);  -- Keyword search
```

## The Iterate Loop

**File:** `src/forge/layers/review.py:136-200`

```python
def iterate_until_passing(self):
    while not all_tests_pass:
        test_results = test_orchestrator.test_project()
        
        if test_results.failed:
            failures = analyzer.analyze_failures(test_results)
            fixes = fix_generator.generate_fixes(failures)
            apply_fixes(fixes)
            # Loop continues
        else:
            break  # All green
```

This is the core innovation: **automatic iteration until tests pass**.

## Pattern Library

18 patterns across multiple domains:

**KnowledgeForge (Agent Patterns):**
- 01_Navigator_Agent.md
- 02_Builder_Agent.md
- 03_Coordination_Patterns.md
- 04_Specification_Templates.md
- 05_Expert_Agent_Example.md
- 06_Quick_Reference.md

**Operational Patterns:**
- core/architecture.md
- core/data-transfer.md
- operations/security.md
- operations/implementation.md
- operations/git-integration.md
- testing/scenarios.md
- deployment/multi-platform.md
- development/conventional-commits.md

## Why This Works

1. **Structured failures** — Machines can parse enums, not stack traces
2. **Parallel review** — 12 perspectives catch what 1 misses
3. **Voting threshold** — Consensus prevents false positives
4. **Pattern matching** — Proven fixes, not generated guesses
5. **Automatic iteration** — No human bottleneck

## Comparison

| Feature | Cursor/Copilot | Forge |
|---------|---------------|-------|
| Agents | 1 | 12 parallel |
| Verification | Human | Automated |
| Failure diagnosis | None | 16 structured types |
| Pattern library | None | 18 searchable patterns |
| Self-repair | No | Yes (iterate loop) |
| Memory | None | Pattern store |

---

## Source Files Quick Reference

| Component | File | Lines |
|-----------|------|-------|
| 12 review agents | `src/forge/review/agents.py` | 228-1413 |
| Parallel execution | `src/forge/review/panel.py` | 348-380 |
| Failure types | `src/forge/layers/failure_analyzer.py` | 30-46 |
| FixSuggestion model | `src/forge/layers/failure_analyzer.py` | 78-101 |
| Pattern search | `src/forge/layers/failure_analyzer.py` | 476-489 |
| Pattern store | `src/forge/knowledgeforge/pattern_store.py` | entire |
| Iterate loop | `src/forge/layers/review.py` | 136-200 |
