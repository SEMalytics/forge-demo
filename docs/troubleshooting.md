# Troubleshooting

## Common Issues

### "forge: command not found"

Forge isn't installed or not in PATH.

```bash
# Install from PyPI
pip install forge-ai

# Or from source
cd /path/to/forge
pip install -e .

# Verify
forge --version
```

### "ANTHROPIC_API_KEY not set"

```bash
# Set for current session
export ANTHROPIC_API_KEY="sk-ant-..."

# Or add to shell profile
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.bashrc
source ~/.bashrc
```

### Demo hangs during generation

**Possible causes:**

1. **Network issue** — Check connectivity
2. **Rate limit** — Wait and retry
3. **Large generation** — Some demos take longer

**Debug:**
```bash
# Run with verbose logging
./run-demo.sh sql --verbose

# Check Forge logs
cat .forge/logs/latest.log
```

### Demo fails but doesn't auto-fix

**Possible causes:**

1. **Pattern library not indexed**
   ```bash
   forge index
   ```

2. **Unknown failure type** — Check if error matches one of 16 types

3. **Max iterations reached** — Default is 5 loops

**Debug:**
```bash
# Check triage output
cat .forge/triage/triage-*.json | jq .

# Manual iterate with verbose
forge iterate -p demo-sql-injection --verbose
```

### Docker errors

Forge runs tests in Docker containers.

```bash
# Check Docker is running
docker ps

# Check Docker permissions
docker run hello-world

# If permission denied, add user to docker group
sudo usermod -aG docker $USER
# Then log out and back in
```

### Pattern matching returns no results

```bash
# Re-index patterns
forge index --force

# Check pattern store
ls -la .forge/patterns/

# Verify embeddings
forge patterns list
```

### Wrong agent catches the issue

This is usually fine — multiple agents may catch the same issue. The structured failure type matters more than which agent found it.

### Fix makes things worse

Rare but possible. The iterate loop will catch it:
1. Fix applied
2. Tests re-run
3. New failure detected
4. New fix applied
5. Loop continues

If stuck in a loop, check max iterations setting or run manually:
```bash
forge iterate -p project-name --max-iterations 10
```

---

## Debug Commands

```bash
# Enable debug logging
export FORGE_LOG_LEVEL=DEBUG

# Full demo run
./run-demo.sh sql

# Just iterate (if project exists)
./run-demo.sh sql --iterate-only

# Manual steps
forge init demo-sql -d "SQL injection demo"
forge decompose "Create SQL function with f-string query" -t python -t sqlite -p demo-sql -s
forge build -p demo-sql --parallel
forge test -p demo-sql
forge iterate -p demo-sql --max-iterations 5

# Check project status
forge status -p demo-sql

# Analyze a directory
forge analyze /path/to/project --verbose

# View triage JSON
cat .forge/triage/triage-*.json | jq .
```

---

## Getting Help

1. **Check logs:** `.forge/logs/`
2. **Check triage:** `.forge/triage/*.json`
3. **Run verbose:** `--verbose` flag
4. **Open issue:** [github.com/SEMalytics/forge/issues](https://github.com/SEMalytics/forge/issues)

---

## Reset Everything

If demos are in a bad state:

```bash
# Remove all demo projects
rm -rf demo-*/
rm -rf .forge/projects/demo-*/

# Re-index patterns
forge index --force

# Try again
./run-demo.sh sql
```
