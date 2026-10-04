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
gzip -kf "$LOG"
python3 "$OLDPWD/scripts/summarize-log.py" "$LOG" | head -60
