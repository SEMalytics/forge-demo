# Forge Demo

Interactive walkthroughs demonstrating [Forge](https://github.com/SEMalytics/forge) — a multi-agent system that automatically generates, tests, diagnoses, and fixes code.

## What is Forge?

Forge solves the fundamental problem with AI code generation: tools generate fast but have no quality control, no institutional memory, and can't fix their own mistakes.

**Forge is different:**
- **12 specialized review agents** run in parallel (security, performance, architecture, concurrency...)
- **Voting system** — 8/12 must approve, any critical finding vetoes
- **16 failure types** — structured diagnostics, not stack traces
- **18 architecture patterns** — proven fixes matched via hybrid semantic search
- **Automated iteration** — loops until all tests pass, no human in the loop

## Quick Start

```bash
# Clone this demo repo
git clone https://github.com/SEMalytics/forge-demo.git
cd forge-demo

# Install Forge (if not already installed)
pip install forge-ai

# Run your first demo (full pipeline)
./run-demo.sh sql

# Or run steps manually (note: -i flag sets a stable project ID):
forge init "demo-sql-injection" -i demo-sql -d "SQL injection demo"
forge decompose "Create function with SQL query using f-string" -t python -t sqlite -p demo-sql -s
forge build -p demo-sql --parallel
forge iterate -p demo-sql --max-iterations 5
```

## Available Demos

| Demo | Command | What It Shows |
|------|---------|---------------|
| [SQL Injection](#sql-injection) | `./run-demo.sh sql` | SecurityReviewer catches f-string SQL |
| [Division by Zero](#division-by-zero) | `./run-demo.sh div` | QualityReviewer catches missing guard |
| [Hardcoded Secret](#hardcoded-secret) | `./run-demo.sh secret` | SecurityReviewer catches embedded API key |
| [Command Injection](#command-injection) | `./run-demo.sh cmd` | SecurityReviewer catches shell=True danger |
| [O(n²) Performance](#on2-performance) | `./run-demo.sh perf` | PerformanceReviewer catches nested loops |

---

## Walkthroughs

### SQL Injection

**The Setup:** We ask Forge to create a user lookup function, but deliberately request f-string SQL formatting — a classic vulnerability.

**Run it:**
```bash
./run-demo.sh sql

# Or manually (using -i for stable project ID):
forge init "demo-sql-injection" -i demo-sql -d "SQL injection demo"
forge decompose "Create a Python function get_user_by_username that queries a SQLite database. Use f-string formatting to build the SQL query with user input directly concatenated." -t python -t sqlite -p demo-sql -s
forge build -p demo-sql --parallel
forge iterate -p demo-sql --max-iterations 5
```

**What happens:**

1. **Generation** — Forge creates the function with vulnerable code:
   ```python
   query = f"SELECT * FROM users WHERE username = '{username}'"
   ```

2. **Review** — 12 agents analyze in parallel. SecurityReviewer flags:
   ```
   ┌─[CRITICAL] SQL Injection vulnerability─────────┐
   │ failure_type: security_vulnerability           │
   │ confidence: 92%                                │
   │ relevant_patterns: ["operations/security.md"]  │
   └────────────────────────────────────────────────┘
   ```

3. **Pattern Match** — Hybrid search (FTS5 + semantic) finds the fix pattern

4. **Fix Applied** — Parameterized query:
   ```python
   cursor.execute("SELECT * FROM users WHERE username = ?", (username,))
   ```

5. **Re-test** — All green. Vulnerability eliminated.

**Time:** ~45 seconds, zero human intervention.

---

### Division by Zero

**The Setup:** Simple division function with no input validation.

**Run it:**
```bash
./run-demo.sh div
```

**What happens:**

1. **Generation** — Minimal implementation:
   ```python
   def divide(numerator, denominator):
       return numerator / denominator
   ```

2. **Test Failure** — `ZeroDivisionError` when denominator is 0

3. **Diagnosis** — QualityReviewer identifies missing guard:
   ```
   failure_type: zero_division_error
   suggested_fix: Add check for denominator == 0
   ```

4. **Fix Applied:**
   ```python
   def divide(numerator, denominator):
       if denominator == 0:
           raise ValueError("Cannot divide by zero")
       return numerator / denominator
   ```

5. **Re-test** — Passes with proper error handling.

**Time:** ~30 seconds. Fastest demo.

---

### Hardcoded Secret

**The Setup:** Weather API client with API key embedded in source code.

**Run it:**
```bash
./run-demo.sh secret
```

**What happens:**

1. **Generation** — Creates class with visible secret:
   ```python
   class WeatherClient:
       def __init__(self):
           self.api_key = "sk-1234567890abcdef"  # ← VISIBLE IN SOURCE
   ```

2. **Review** — SecurityReviewer catches hardcoded credential

3. **Fix Applied:**
   ```python
   class WeatherClient:
       def __init__(self):
           self.api_key = os.environ.get("WEATHER_API_KEY")
           if not self.api_key:
               raise ValueError("WEATHER_API_KEY environment variable required")
   ```

**Why this matters:** Secrets in source code end up in git history, logs, error messages. This is how breaches happen.

---

### Command Injection

**The Setup:** File compression utility using subprocess with user input.

**Run it:**
```bash
./run-demo.sh cmd
```

**What happens:**

1. **Generation** — Dangerous pattern:
   ```python
   subprocess.run(f"gzip {filename}", shell=True)
   ```

2. **The Risk** — If `filename` is `; rm -rf /`, game over.

3. **Review** — SecurityReviewer flags command injection

4. **Fix Applied:**
   ```python
   # Validate input
   if not re.match(r'^[\w\-\.]+$', filename):
       raise ValueError("Invalid filename")
   # Use list args, no shell
   subprocess.run(["gzip", filename])
   ```

**Time:** ~45 seconds.

---

### O(n²) Performance

**The Setup:** Find duplicates in a list using nested loops.

**Run it:**
```bash
./run-demo.sh perf
```

**What happens:**

1. **Generation** — O(n²) approach:
   ```python
   for i in range(len(items)):
       for j in range(len(items)):
           if i != j and items[i] == items[j]:
               duplicates.append(items[i])
   ```

2. **Review** — PerformanceReviewer flags quadratic complexity

3. **Fix Applied** — O(n) with set:
   ```python
   seen = set()
   duplicates = set()
   for item in items:
       if item in seen:
           duplicates.add(item)
       seen.add(item)
   return list(duplicates)
   ```

**Why this matters:** O(n²) with 1,000 items = 1,000,000 operations. O(n) = 1,000.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        FORGE PIPELINE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐   ┌─────────────┐   ┌────────────┐               │
│  │ Planning │ → │ Decompose   │ → │ Generation │               │
│  └──────────┘   └─────────────┘   └────────────┘               │
│                                          ↓                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    REVIEW LAYER                          │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │  │
│  │  │  Security   │ │ Performance │ │Architecture │  ...   │  │
│  │  │  Reviewer   │ │  Reviewer   │ │  Reviewer   │ (x12)  │  │
│  │  └─────────────┘ └─────────────┘ └─────────────┘        │  │
│  │         ↓               ↓               ↓                │  │
│  │                   VOTE (8/12)                            │  │
│  │              CRITICAL = VETO                             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ↓                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                 FAILURE ANALYZER                         │   │
│  │  • 16 failure types (enum, not strings)                 │   │
│  │  • Structured diagnostics (JSON, not stack traces)      │   │
│  │  • Hybrid pattern search (FTS5 + semantic)              │   │
│  │  • 18 architecture patterns                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           ↓                                     │
│                    ┌──────────┐                                │
│                    │  Deploy  │                                │
│                    └──────────┘                                │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

| Component | Count | Purpose |
|-----------|-------|---------|
| Review Agents | 12 | Parallel domain experts |
| Failure Types | 16 | Structured error taxonomy |
| Architecture Patterns | 18 | Proven fix templates |
| Embedding Dimensions | 384 | all-MiniLM-L6-v2 vectors |
| Approval Threshold | 8/12 | Voting consensus |

---

## Understanding the Output

When a demo runs, watch for these key moments:

### 1. Failure Panel (Structured Diagnostic)
```
┌─[CRITICAL] SQL Injection vulnerability─────────┐
│ Priority: CRITICAL                             │
│ Category: security                             │
│ Confidence: 92%                                │
│                                                │
│ Root Cause:                                    │
│   User input concatenated into SQL query       │
│                                                │
│ Suggested Fix:                                 │
│   Use parameterized queries with placeholders  │
│                                                │
│ Relevant Patterns:                             │
│   • operations/security.md                     │
└────────────────────────────────────────────────┘
```

### 2. Pattern Matching Logs (with --verbose)
```
[INFO] Loading relevant patterns for: security_vulnerability
[INFO] Query: "troubleshooting security_vulnerability SQL injection"
[INFO] Hybrid search returned 3 patterns
[INFO] Top match: operations/security.md (0.87 similarity)
```

### 3. Fix Application
```
Files to modify:
  • src/api/users.py (line 45)

Code changes:
  - query = f"SELECT * FROM users WHERE username = '{username}'"
  + cursor.execute("SELECT * FROM users WHERE username = ?", (username,))
```

### 4. Success
```
✓ All tests passing
✓ Security review: PASSED
✓ Performance review: PASSED
✓ 12/12 agents approved
```

---

## Creating Your Own Demos

Demo specs are YAML files that define requirements:

```yaml
name: my-demo
description: What this demo shows

requirements:
  - Requirement that will generate working code
  - Requirement that introduces a flaw (for demo purposes)

constraints:
  - Constraint that forces the flaw to appear

# Comments explaining expected failure → fix flow
```

See `demos/` for examples.

---

## Tech Stack

- **Claude Opus 4.5** — Complex reasoning, failure analysis
- **Claude Sonnet 4** — Code generation
- **Sentence Transformers** — Pattern embeddings (all-MiniLM-L6-v2)
- **SQLite** — Pattern storage with FTS5 + blob embeddings
- **Docker** — Isolated test execution
- **Python/Poetry** — Package management

---

## Links

- **Forge Repository:** [github.com/SEMalytics/forge](https://github.com/SEMalytics/forge)
- **KnowledgeForge Patterns:** Included in Forge repo under `knowledgeforge/`
- **AI Tinkerers Seattle:** [meetup.com/ai-tinkerers-seattle](https://www.meetup.com/ai-tinkerers-seattle/)

---

## License

MIT — Use these demos however you want.

---

## Questions?

Open an issue or find me at AI Tinkerers Seattle.
