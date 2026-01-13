# Forge Demo - Speaker Notes

**Event:** AI Tinkerers Seattle · Dev Tools Track  
**Date:** January 12, 2026  
**Time:** 5 min demo + 3 min Q&A

---

## Navigation

- [1. Title](#1-title)
- [2. The Problem](#2-the-problem)
- [3. The Solution](#3-the-solution)
- [4. Architecture](#4-architecture)
- [5. Demo](#5-demo)
- [6. Recap](#6-recap)
- [7. Links & Q&A](#7-links--qa)

---

# 1. Title

```
⚒️ FORGE
Multi-Agent Code Fixes

David Pedersen · AI Tinkerers Seattle · Jan 2026
github.com/SEMalytics/forge
```

**SAY:** *"Hi, I'm David. I built Forge to solve a problem we all have."*

---

# 2. The Problem

```
AI code generation is FAST and WRONG

→ No verification — you verify
→ No memory — same mistakes, every time  
→ No self-repair — can't diagnose failures
→ No patterns — proven fixes forgotten
```

**SAY:**

> "AI code generation is fast and wrong. Cursor, Copilot, Claude Code—they generate in seconds, then you spend hours fixing their mistakes.
>
> The fundamental issue: they generate but can't verify. They have no feedback loop. When code fails, they can't diagnose why. When patterns work, they don't remember them. Every generation starts from scratch."

**TIME:** 30 seconds

---

# 3. The Solution

```
AGENTS THAT FIX THEIR OWN MISTAKES

Planning → Decomposition → Generation → Testing → Review → Deploy
                                                      ↓
                                    Diagnose → Pattern Match → Fix → Loop
```

**SAY:**

> "Forge is a multi-agent orchestration system. Six sequential layers—planning through deploy. Within the review layer, twelve specialized agents run in parallel: security, performance, architecture, concurrency, data validation.
>
> They vote. Eight of twelve must approve. Any critical finding vetoes.
>
> When tests fail, the failure analyzer categorizes into sixteen structured types. It searches eighteen architecture patterns. Finds the fix. Applies it. Loops until every test passes—automatically."

**TIME:** 45 seconds

---

# 4. Architecture

```
┌─────────────────────────┬─────────────────────────┐
│     12 REVIEW AGENTS    │     PATTERN MATCHING    │
├─────────────────────────┼─────────────────────────┤
│ → Security              │ → 16 failure types      │
│ → Performance           │ → 18 architecture       │
│ → Architecture          │   patterns              │
│ → Concurrency           │ → FTS5 + semantic       │
│ → Data Validation       │   search                │
│ → ...7 more             │ → 384-dim embeddings    │
│                         │                         │
│ 8/12 must approve       │ Proven fixes,           │
│ CRITICAL vetoes         │ not generated guesses   │
└─────────────────────────┴─────────────────────────┘
```

**SAY (if time, else skip):**

> "Twelve agents. Voting threshold. Pattern matching with sentence transformers. SQLite—no external vector DB."

**TIME:** 15 seconds (or skip)

---

# 5. Demo

```
🔴 LIVE DEMO

SQL Injection → Caught → Fixed → Passing

~45 seconds, zero human intervention
```

## BEFORE DEMO:

**SAY:**

> "Let me show you. I'm going to generate code with a deliberate SQL injection vulnerability. Watch the terminal."

## DEMO COMMAND:

```bash
# Full demo from scratch:
./run-demo.sh sql

# If project already exists, just iterate (stable ID):
./run-demo.sh sql --iterate-only

# Or run manually (demo-sql is the stable project ID):
forge iterate -p demo-sql --max-iterations 5
```

## DURING DEMO - POINT AT:

### A) Failure Panel

```
┌─[CRITICAL] SQL Injection vulnerability─────────┐
│ failure_type: security_vulnerability           │  ← POINT: "Structured type"
│ confidence: 92%                                │  ← POINT: "Confidence score"
│ relevant_patterns: ["operations/security.md"]  │  ← POINT: "Pattern matched"
└────────────────────────────────────────────────┘
```

**SAY:**

> "There. SecurityReviewer caught it. Look—structured diagnostic. Not a stack trace. Failure type enumerated. Confidence 92%. And the pattern's already matched."

### B) Pattern Match Logs

```
[INFO] Query: "troubleshooting security_vulnerability SQL injection"
[INFO] Top match: operations/security.md (0.87 similarity)
```

**SAY:**

> "Hybrid search—keyword plus semantic. Finds the proven fix."

### C) Code Change

```python
# Before:
f"SELECT * FROM users WHERE username = '{username}'"

# After:
cursor.execute("SELECT * FROM users WHERE username = ?", (username,))
```

**SAY:**

> "F-string to parameterized query. Classic fix."

### D) Success

**SAY:**

> "All green. SQL injection caught, diagnosed, fixed, verified. Twelve agents voted. No human in the loop."

**TIME:** 3 minutes total demo

---

# 6. Recap

```
BY THE NUMBERS

┌────────┬────────┬────────┐
│   12   │   16   │   18   │
│ Agents │ Failure│Patterns│
│(parallel)│ Types │        │
└────────┴────────┴────────┘

Claude Opus 4.5 · Sentence Transformers · SQLite · Docker
```

**SAY:**

> "Twelve agents. Eighteen patterns. Sixteen failure types. Open source."

**TIME:** 10 seconds

---

# 7. Links & Q&A

```
TRY IT

Forge:       github.com/SEMalytics/forge
These Demos: github.com/SEMalytics/forge-demo

Questions?
```

**SAY:**

> "Clone the repo, try it yourself. Questions?"

---

# Q&A Cheat Sheet

## "How is this different from Cursor/Copilot?"

> "Those are single-agent, single-pass. Forge has six layers and twelve parallel review agents. They vote. They veto. When code fails, it categorizes into sixteen failure types and searches a pattern library. The loop continues until tests pass. Cursor generates and hopes. Forge generates, tests, diagnoses, fixes, verifies."

## "What LLMs?"

> "Claude Opus 4.5 for complex reasoning—diagnosis and architecture. Sonnet for generation. Sentence transformers for pattern embeddings—runs locally."

## "How does pattern matching work?"

> "SQLite with blob embeddings—no external vector DB. Sentence transformer, all-MiniLM-L6-v2, 384 dimensions. Hybrid search combines FTS5 keyword matching with cosine similarity."

## "Cost?"

> "Depends on complexity. Simple demo: $0.10-0.50. Complex system: a few dollars. Compare to engineer hours debugging AI-generated code."

## "Hallucinations?"

> "Tests. The testing agents don't hallucinate—they execute real code in Docker. If code is wrong, tests fail. If tests fail, the system iterates. Hallucinations get caught, not shipped."

## "12 agents—what do they do?"

> "Security, performance, architecture, concurrency, data validation, error handling, API design, code style, maintainability, documentation, quality, integration. Each has domain expertise. They run in parallel via ThreadPoolExecutor."

## "You said 28 patterns?"

> "Started with 28 in the proposal, currently 18 deployed. Growing as we encode more fixes."

---

# Timing Cheat Sheet

| Section | Time | Cumulative |
|---------|------|------------|
| Title + Problem | 0:30 | 0:30 |
| Solution | 0:45 | 1:15 |
| Architecture (optional) | 0:15 | 1:30 |
| Demo transition | 0:15 | 1:45 |
| Demo | 2:30 | 4:15 |
| Recap + Links | 0:15 | 4:30 |
| Buffer | 0:30 | 5:00 |

---

# Backup Plans

## If demo hangs:

> "Live demos. Let me show you the recording instead."

Have screen recording ready.

## If demo fails differently than expected:

> "Different failure this time—let's see what it caught."

Roll with it. Any failure → fix → pass is a valid demo.

## If no time for questions:

> "Find me after—happy to chat. Repos are in the slides."

---

# Pre-Flight Checklist

```
□ Slides loaded (slides.html)
□ Terminal ready (large font, dark theme)
□ Demo tested (./run-demo.sh sql)
□ Backup tested (./run-demo.sh div)
□ Recording ready (if demo fails)
□ Links in slides (github repos)
□ Notifications OFF
□ Docker running
```
