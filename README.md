# Forge Demo

Interactive walkthroughs demonstrating [Forge](https://github.com/SEMalytics/forge) — a multi-agent system that automatically generates, tests, diagnoses, and fixes code.

## What is Forge?

Forge solves the fundamental problem with AI code generation: tools generate fast but have no quality control, no institutional memory, and can't fix their own mistakes.

**Forge is different:**
- **12 specialized review agents** run in parallel (security, performance, architecture, concurrency...)
- **Voting system** — 8/12 must approve, any critical finding vetoes
- **Automated iteration** — scans code, diagnoses issues, applies fixes, loops until all tests pass

## Quick Start

```bash
# Clone this demo repo
git clone https://github.com/SEMalytics/forge-demo.git
cd forge-demo

# Install Forge (from the main repo)
cd ../forge
pip install -e .
cd ../forge-demo

# Show the 12 review agents
forge review panel

# Review vulnerable files (shows voting)
forge review directory demos --pattern "*.py" --format full --threshold 8

# Full auto-fix loop
forge init "Demo" -i demo -d "Vulnerable code"
forge iterate -p demo -d demos --max-iterations 3
```

## Demo Files

The `demos/` directory contains intentionally vulnerable Python files:

| File | Vulnerability | What Forge Detects |
|------|---------------|-------------------|
| `sql_injection.py` | f-string SQL query | CRITICAL: SQL injection |
| `hardcoded_secrets.py` | API key in source | CRITICAL: Hardcoded secret |
| `command_injection.py` | os.system() with user input | HIGH: Command injection |
| `division.py` | No zero-division check | MEDIUM: Missing validation |
| `performance.py` | O(n²) nested loops | MEDIUM: Performance issue |

---

## Commands

### 1. Review Panel — Show the 12 Agents

```bash
forge review panel
```

Output:
```
               Review Panel - 12 Expert Agents
┏━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ Agent                 ┃ Expertise                         ┃
┡━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩
│ SecurityExpert        │ Security & Vulnerability Analysis │
│ PerformanceExpert     │ Performance & Optimization        │
│ ArchitectureExpert    │ Architecture & Design Patterns    │
│ TestingExpert         │ Testing & Quality Assurance       │
│ DocumentationExpert   │ Documentation & Clarity           │
│ ErrorHandlingExpert   │ Error Handling & Recovery         │
│ CodeStyleExpert       │ Code Style & Conventions          │
│ APIDesignExpert       │ API Design & Contracts            │
│ ConcurrencyExpert     │ Concurrency & Threading           │
│ DataValidationExpert  │ Data Validation & Sanitization    │
│ MaintainabilityExpert │ Maintainability & Readability     │
│ IntegrationExpert     │ Integration & Compatibility       │
└───────────────────────┴───────────────────────────────────┘

Default threshold: 8/12 approvals required
Blocking issues: Critical and High severity findings
```

### 2. Review Files — Multi-Agent Voting

```bash
# Review a single file
forge review file demos/sql_injection.py --format full

# Review all demo files
forge review directory demos --pattern "*.py" --format full --threshold 8
```

Output:
```
Decision: REJECTED
Votes: 57 approve, 3 reject
Threshold: 8/12 required

BLOCKING ISSUES:
  [CRITICAL] secrets: Hardcoded secret detected (hardcoded_secrets.py:12)
  [HIGH] injection: Command injection via os.system() (command_injection.py:15)
  [HIGH] sql: SQL injection with f-string (sql_injection.py:17)
```

### 3. Iterate — Full Auto-Fix Loop

```bash
# Initialize project
forge init "Demo" -i demo -d "Vulnerable code"

# Run iterate with directory flag
forge iterate -p demo -d demos --max-iterations 3
```

Output:
```
Found 5 code files

Iteration 1/3
  Security scan: 4 vulnerabilities (3 critical, 1 high)
  Generated 4 fix suggestions
  Applied 3 fixes

✓ All tests passing!

Final Summary:
┌──────────────────┬────────┐
│ Total Iterations │ 1      │
│ Final Status     │ PASSED │
│ Success          │ ✓ Yes  │
│ Total Duration   │ 27.3s  │
└──────────────────┴────────┘
```

---

## What Gets Fixed

### SQL Injection

**Before:**
```python
query = f"SELECT * FROM users WHERE username = '{username}'"
cursor.execute(query)
```

**After:**
```python
query = "SELECT * FROM users WHERE username = ?"
cursor.execute(query, (username,))
```

### Hardcoded Secrets

**Before:**
```python
API_KEY = 'sk_live_abc123xyz789'
```

**After:**
```python
API_KEY = os.getenv('PAYMENT_API_KEY')
if not API_KEY:
    raise ValueError("PAYMENT_API_KEY environment variable is required")
```

### Command Injection

**Before:**
```python
os.system(f"cat {filename}")
```

**After:**
```python
subprocess.run(["cat", filename], check=True)
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        FORGE PIPELINE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
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
│  │  • Structured diagnostics (not stack traces)            │   │
│  │  • Pattern matching via semantic search                 │   │
│  │  • Automatic fix generation                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           ↓                                     │
│                    ┌──────────┐                                │
│                    │  FIXED   │                                │
│                    └──────────┘                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

- **Claude Opus 4.5** — Complex reasoning, failure analysis, fix generation
- **Sentence Transformers** — Pattern embeddings (all-MiniLM-L6-v2)
- **SQLite** — Pattern storage with FTS5 + blob embeddings
- **Docker** — Isolated test execution (optional)

---

## Links

- **Forge Repository:** [github.com/SEMalytics/forge](https://github.com/SEMalytics/forge)
- **Demo Repository:** [github.com/SEMalytics/forge-demo](https://github.com/SEMalytics/forge-demo)

---

## License

MIT — Use these demos however you want.
