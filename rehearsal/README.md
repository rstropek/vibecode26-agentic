# Rehearsal

Every prompt of [storybook.md](../storybook.md) is rehearsed headless with `claude -p`
(Opus 5.5, effort high, auto mode, auto memory off), one fresh session per prompt, in
`../solution`.

| Path | Content |
| --- | --- |
| `prompts/` | the prompts, byte-identical to the `<!-- prompt: stepNN -->` blocks in the storybook (`scripts/check-prompts.py`) |
| `scripts/run-agent.sh` | runs one prompt in `../solution`, writes the stream-json log, prints a summary |
| `scripts/summarize-log.py` | duration, turns, cost, tools, research, errors, result of a log |
| `scripts/tag-step.sh` | tags `../solution` and this repo with `stepNN` and pushes both |
| `logs/` | gzipped transcripts (`stepNN-<run>.jsonl.gz`) |

`../solution` is the rehearsal app, its own repository:
[rstropek/vibecode26-agentic-rehearsal](https://github.com/rstropek/vibecode26-agentic-rehearsal),
one tag per step. The OpenRouter key comes from `../.env` (git-ignored).

```bash
cd rehearsal
scripts/run-agent.sh prompts/step06.md step06-r1
scripts/tag-step.sh 06 "Step 6: AGENTS.md and tech docs"
```
