# Rehearsal

Every prompt of [storybook.md](../storybook.md) is rehearsed headless with `claude -p`
(Opus 5.5, effort high, auto mode, auto memory off), one fresh session per prompt, in
`../solution`.

| Path | Content |
| --- | --- |
| `prompts/` | the prompts, byte-identical to the `<!-- prompt: stepNN -->` blocks in the storybook (`scripts/check-prompts.py`) |
| `scripts/run-agent.sh` | runs one prompt in `../solution`, writes the stream-json log, prints a summary |
| `scripts/summarize-log.py` | duration, turns, cost, tools, research, errors, result of a log |
| `scripts/tag-step.sh` | tags `../solution` and this repo with `stepNN` and pushes both (refuses to commit if a log contains the OpenRouter key) |
| `scripts/cli-login.sh` | logs the `todo-cat` CLI in as the demo user without a browser (approves the device code through Better Auth's API) |
| `scripts/check-prompts.py` | checks the prompt files against the storybook |
| `mcp-stdio.json` | MCP config for the MCP-only runs (steps 32, 34) |
| `logs/` | gzipped transcripts (`stepNN-<run>.jsonl.gz`) |

`../solution` is a symlink to `~/vibecode26-rehearsal/todo-cat`, so the agent's parent
folder doesn't contain this storybook. It is the rehearsal app, its own repository:
[rstropek/vibecode26-agentic-rehearsal](https://github.com/rstropek/vibecode26-agentic-rehearsal),
one tag per step. The OpenRouter key comes from `../.env` (git-ignored).

```bash
cd rehearsal
scripts/run-agent.sh prompts/step06.md step06-r1
scripts/tag-step.sh 06 "Step 6: AGENTS.md and tech docs"
AGENT_DIR=../solution/.claude/worktrees/polish scripts/run-agent.sh prompts/step28b.md step28b-r1   # in a worktree
scripts/run-agent.sh prompts/step26a.md step26a-r1 --worktree a2ui-card                            # new worktree
XDG_CONFIG_HOME=/tmp/xdg scripts/run-agent.sh prompts/step32.md step32-mcp-r1 --mcp-config "$PWD/mcp-stdio.json" --tools ""
```

The agent may print `.env`; `run-agent.sh` redacts the OpenRouter key from the log before
it is gzipped, and the raw `.jsonl` files are git-ignored.
