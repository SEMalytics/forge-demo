# Frequently Asked Questions

## General

### What is Forge?

Forge is a multi-agent system that automatically generates, tests, diagnoses, and fixes code. Unlike single-pass AI code generators, Forge uses 12 specialized review agents and an automated iteration loop to produce production-ready code.

### How is this different from Cursor / Copilot / Claude Code?

| Feature | Cursor/Copilot | Forge |
|---------|---------------|-------|
| Agents | 1 (generates) | 12 (generate + review) |
| Verification | Human does it | Automated |
| Self-repair | No | Yes (iterate until pass) |
| Pattern memory | None | 18 searchable patterns |
| Failure diagnosis | Stack trace | 16 structured types |

### Is this open source?

Yes. MIT license.

- Forge: [github.com/SEMalytics/forge](https://github.com/SEMalytics/forge)
- This demo repo: [github.com/SEMalytics/forge-demo](https://github.com/SEMalytics/forge-demo)

---

## Technical

### What LLMs does Forge use?

- **Claude Opus 4.5** — Complex reasoning, failure analysis
- **Claude Sonnet 4** — Code generation
- **Sentence Transformers** — Pattern embeddings (local, no API)

### What's the pattern matching architecture?

SQLite with:
- **FTS5** — Full-text keyword search
- **Blob embeddings** — 384-dimensional vectors (all-MiniLM-L6-v2)
- **Hybrid search** — Combines keyword + semantic scores
- **LRU cache** — Fast repeat queries

No external vector database (Pinecone, Chroma, etc.) required.

### How does voting work?

12 review agents run in parallel. Each votes:
- **APPROVE** — No issues found
- **REJECT** — Issues found (with severity)
- **ABSTAIN** — Agent error, doesn't count

Thresholds:
- **8/12** must approve for deployment
- **Any CRITICAL** finding vetoes regardless of votes

### What are the 16 failure types?

```
SYNTAX_ERROR, IMPORT_ERROR, ASSERTION_ERROR, TYPE_ERROR,
NAME_ERROR, ATTRIBUTE_ERROR, KEY_ERROR, INDEX_ERROR,
VALUE_ERROR, ZERO_DIVISION_ERROR, TIMEOUT_ERROR, NETWORK_ERROR,
SECURITY_VULNERABILITY, PERFORMANCE_DEGRADATION, UNKNOWN
```

### How fast is it?

Typical demo: 30-60 seconds for generate → fail → diagnose → fix → pass.

Production projects vary. A complex multi-file system might take several minutes with multiple iteration loops.

---

## Cost

### What does it cost to run?

Depends on complexity:
- Simple demo (like these): ~$0.10-0.50
- Moderate project: ~$1-5
- Complex multi-file system: ~$5-20

Compare to engineer hours debugging AI-generated code.

### Can I use cheaper models?

The architecture is model-agnostic. You could swap Claude for:
- GPT-4o
- Local LLMs (with quality tradeoffs)
- Mixed (cheap model for generation, expensive for diagnosis)

---

## Demos

### Which demo should I run first?

**SQL Injection** (`./run-demo.sh sql`) — Most dramatic, universally understood.

### Why do demos deliberately introduce flaws?

To show the failure → diagnosis → fix loop. In real usage, you wouldn't request flaws — Forge catches the ones you don't realize you're introducing.

### Can I create my own demos?

Yes. See [CONTRIBUTING.md](../CONTRIBUTING.md).

---

## Troubleshooting

### Demo hangs on generation

Check:
1. API key set? (`ANTHROPIC_API_KEY`)
2. Network connectivity
3. Rate limits

### Demo fails but doesn't fix

Check:
1. Pattern library indexed? (`forge index`)
2. Verbose mode for diagnostics (`--verbose`)
3. `.forge/logs/` for detailed errors

### "forge: command not found"

Install Forge:
```bash
pip install forge-ai
```

Or if using from source:
```bash
cd /path/to/forge
pip install -e .
```

See [docs/troubleshooting.md](troubleshooting.md) for more.
