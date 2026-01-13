# Forge Demo Commands - AI Tinkerers Seattle

## Pre-Demo Setup (run once before presenting)

```bash
cd /Users/dp/Scripts/forge-demo

# Clean environment
unset CODEGEN_API_KEY
export FORGE_BACKEND=anthropic

# Remove any stray repos from demos/
rm -rf demos/flask demos/requests demos/.forge
```

## Live Demo Commands

### 1. Show the Review Panel (12 Agents)

```bash
forge review panel
```

**Talking point:** "12 expert agents, each with domain expertise. 8 of 12 must approve. Critical findings auto-veto."

---

### 2. Review a Single Vulnerable File

```bash
# Show the vulnerable code first
cat demos/sql_injection.py

# Run the 12-agent review
forge review file demos/sql_injection.py --format full
```

**Talking point:** "Watch the SecurityExpert catch the SQL injection on line 6."

---

### 3. Review All Demo Files at Once

```bash
forge review directory demos --pattern "*.py" --format full --threshold 8
```

**Expected output:**
- Decision: **REJECTED**
- Votes: ~57 approve, ~3 reject
- Blocking Issues:
  - CRITICAL: Hardcoded secret (hardcoded_secrets.py:3)
  - HIGH: Command injection (command_injection.py:4)
  - HIGH: SQL injection (sql_injection.py:6)

**Talking point:** "57 approve, 3 reject, but those 3 are blocking issues - security veto. No human in the loop."

---

### 4. Show Individual File Reviews (if time)

```bash
# Hardcoded API key
forge review file demos/hardcoded_secrets.py --format full

# Command injection
forge review file demos/command_injection.py --format full

# Performance issue (O(n²))
forge review file demos/performance.py --format full
```

---

## Quick Reference

| Command | What it shows |
|---------|---------------|
| `forge review panel` | The 12 expert agents |
| `forge review file <path>` | Single file review with voting |
| `forge review directory <dir> --pattern "*.py"` | Multi-file review |
| `forge review file <path> --format json` | Machine-readable output |

---

## Key Numbers for Q&A

- **12 agents** running in parallel (ThreadPoolExecutor)
- **8/12** approval threshold (configurable)
- **4 severity levels**: CRITICAL > HIGH > MEDIUM > LOW
- **Critical/High = blocking** (auto-veto regardless of vote count)
- **~0.01 seconds** review time for 5 files (static analysis, no LLM calls)
- **Anthropic Claude** for complex reasoning (diagnostics, fix generation)
- **Sentence Transformers** for pattern matching (local, no API)

---

## If Something Breaks

```bash
# Reset environment
unset CODEGEN_API_KEY
export FORGE_BACKEND=anthropic

# Check forge is working
forge --version
forge review panel
```

---

## Demo Files

```
demos/
├── sql_injection.py      # f-string SQL query
├── command_injection.py  # os.system() with user input
├── hardcoded_secrets.py  # API key in source code
├── division.py           # Missing zero-division check
└── performance.py        # O(n²) nested loops
```
