# Contributing to Forge Demo

Want to add a new demo? Here's how.

## Adding a New Demo

### 1. Create the Spec File

Create a YAML file in `demos/`:

```yaml
name: my-new-demo
description: What this demo shows

requirements:
  - Requirement that will generate working code
  - Requirement that deliberately introduces a flaw
  - Be specific about the flaw you want to trigger

constraints:
  - Constraint that forces the flaw to appear
  - Be explicit about what NOT to do

# Document the expected flow
# 1. Generation produces [specific code]
# 2. [Which agent] catches [which issue]
# 3. Pattern match: [which pattern]
# 4. Fix: [what changes]
# 5. Pass on retry
```

### 2. Add to run-demo.sh

Add a case to the script:

```bash
my-demo|myalias)
    print_header "MY NEW DEMO"
    print_info "FAILURE_TYPE" "AgentName" "pattern/file.md"
    echo "Scenario: What this demonstrates"
    echo "Expected: Failure → Fix description"
    echo ""
    run_demo "demo-my-new" "$DEMO_DIR/my-new-demo.yaml"
    ;;
```

### 3. Update the README

Add your demo to the table in README.md:

```markdown
| [My New Demo](#my-new-demo) | `./run-demo.sh my-demo` | What it shows |
```

And add a walkthrough section.

### 4. Test It

```bash
# Run your demo
./run-demo.sh my-demo --verbose

# Verify:
# - Generation produces the flaw
# - Correct agent catches it
# - Pattern match is logged
# - Fix is applied
# - Tests pass on retry
```

## Demo Design Principles

### Good Demos

- **One clear failure** — Focus on a single issue
- **Obvious flaw** — Audience should recognize the problem
- **Visible pattern match** — Show the semantic search working
- **Clean fix** — Before/after should be immediately understandable
- **Fast** — Under 60 seconds ideally

### What to Avoid

- Multiple unrelated failures
- Obscure edge cases
- Long generation times
- Flaky failures (must be reproducible)

## Failure Types to Target

These are the 16 failure types in Forge:

| Type | Good Demo Candidate? | Notes |
|------|---------------------|-------|
| SECURITY_VULNERABILITY | ✅ Excellent | SQL injection, command injection, secrets |
| ZERO_DIVISION_ERROR | ✅ Good | Simple, fast, reliable |
| PERFORMANCE_DEGRADATION | ✅ Good | O(n²), memory leaks |
| TYPE_ERROR | ✅ Good | Type mismatches |
| IMPORT_ERROR | ⚠️ Okay | Less dramatic |
| ASSERTION_ERROR | ⚠️ Okay | Test-focused |
| NAME_ERROR | ⚠️ Okay | Typos, less interesting |
| SYNTAX_ERROR | ❌ Avoid | Too simple |
| UNKNOWN | ❌ Avoid | Unpredictable |

## Review Agents to Showcase

Target demos that highlight specific agents:

| Agent | Good Demo Topics |
|-------|-----------------|
| SecurityReviewer | Injection, secrets, auth |
| PerformanceReviewer | Complexity, memory, async |
| ConcurrencyReviewer | Race conditions, deadlocks |
| DataValidationReviewer | Input sanitization |
| ErrorHandlingReviewer | Missing try/catch |
| QualityReviewer | Edge cases, coverage |

## Submitting

1. Fork the repo
2. Add your demo files
3. Test locally
4. Submit a PR with:
   - Demo spec YAML
   - Updated run-demo.sh
   - Updated README.md
   - Brief description of what it shows

## Questions?

Open an issue or start a discussion.
