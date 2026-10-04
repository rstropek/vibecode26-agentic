#!/usr/bin/env bash
# Run one storybook prompt headless in ../solution, like on stage: Opus 5.5, effort high.
# Usage (from rehearsal/): scripts/run-agent.sh <prompt-file> <log-name> [extra claude args...]
# Auto memory and the account's claude.ai connectors are off, so the repository (AGENTS.md, tech docs, skills) is
# the only memory between steps and no MCP server is loaded unless a step passes --mcp-config.
set -euo pipefail
PROMPT_FILE="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
LOG="$(pwd)/logs/$2.jsonl"
shift 2
cd "$(readlink -f ../solution)"   # real path: the parent folder must not contain the storybook
START=$(date +%s)
CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 ENABLE_CLAUDEAI_MCP_SERVERS=false claude -p "$(cat "$PROMPT_FILE")" --model claude-opus-5-5 --effort high \
  --permission-mode auto --strict-mcp-config "$@" --output-format stream-json --verbose > "$LOG" 2>&1 || echo "claude exited with $?"
echo "Duration: $(( $(date +%s) - START ))s"
# The agent may print .env: redact the OpenRouter key (from ../.env) before the log is kept
KEY=$(sed -n 's/^OPENROUTER_API_KEY=//p' "$OLDPWD/../.env" 2>/dev/null || true)
if [ -n "$KEY" ]; then python3 -c 'import sys;p,k=sys.argv[1:];s=open(p).read();open(p,"w").write(s.replace(k,"sk-or-v1-REDACTED"))' "$LOG" "$KEY"; fi
gzip -kf "$LOG"
python3 "$OLDPWD/scripts/summarize-log.py" "$LOG" | head -60
