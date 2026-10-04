# Agentic Coding with Claude Code: Build a Real App in Two Days

Material for a two-day, hands-on bootcamp on agentic software development with
[Claude Code](https://code.claude.com). Over four half days we build **todo-cat** from an
empty folder: a to-do list web app kept by **Lissie**, an AI agent with the attitude of a
cat. She comments on every todo you add or finish, and she declines everything that isn't
about your list. Errands that need a dog go to **Sindi**, the dog next door, over the A2A
protocol.

The app is the vehicle. The lesson is **how to drive a coding agent**, and how to build the
harness around it (project memory, tech docs, skills, a QA script, CI, an architecture,
worktrees, reviews, a sandbox) so that the agent's output is something you can trust.

## What's in this repository

| Path | What it is |
| --- | --- |
| [`storybook.md`](storybook.md) | The presenter's guide: 37 steps, each with a goal, a copyable script or prompt, demo commands, talking points, and "if it breaks". Timing and cost per prompt from the rehearsal, a ports table, and troubleshooting. |
| [`workshop-outline.md`](workshop-outline.md) | The outline the storybook was written from: what each half day covers, the source material, and what was deliberately cut. |
| [`materials/`](materials) | Files the steps use: `scaffold.sh` (step 4), `skills.sh` (step 7), `architecture.md` (step 12), `check-chat-isolation.sh` (step 21), and the sandbox demo helper (step 35). |
| [`rehearsal/`](rehearsal/README.md) | How every prompt was rehearsed headless with `claude -p`: the prompts (identical to the storybook's), the scripts, and the gzipped agent transcripts. |

The app that comes out of the rehearsal lives in its own repository,
[**rstropek/vibecode26-agentic-rehearsal**](https://github.com/rstropek/vibecode26-agentic-rehearsal),
with one git tag per step (`step04` … `step36`).

## The two days at a glance

| Half day | Topics | The app afterwards |
| --- | --- | --- |
| Day 1 morning | Agent = model + harness, Claude Code basics, scaffolding with generators, `AGENTS.md` and tech docs, skills, anatomy of a good prompt, QA script and CI, grounding in current docs | Next.js 16 app with Vitest, Playwright, Biome, Drizzle/SQLite, GitHub Actions |
| Day 1 afternoon | Authentication, architecture first and plan mode, a REST API, raw protocols with `curl`, a CLI built for agents, a skill for it, the agent as a user, staying in control, context hygiene | Better Auth, a todo service with a shared contract, `/api/todos`, the `todo-cat` CLI with device login |
| Day 2 morning | Lissie (Mastra + CopilotKit over AG-UI), per-user isolation as a security requirement, tool calling, branches and pull requests, a first design (`frontend-design`, impeccable), parallel agents in worktrees, a background code review | A chat with Lissie next to an editable list, an A2UI progress card |
| Day 2 afternoon | The CLI as a local MCP server, testing MCP without an agent, MCP vs. CLI + skill, the app as a remote MCP server with OAuth, prompt injection through tool results, sandboxing, two side quests: Sindi over A2A and OpenTelemetry into the Aspire dashboard | stdio and Streamable HTTP MCP servers, Sindi, traces in Aspire |

**Stack:** Next.js 16, TypeScript, Tailwind, Biome, SQLite via Drizzle, Better Auth,
Mastra agents on OpenRouter, CopilotKit and AG-UI, MCP (TypeScript SDK v2), A2A, Vitest,
Playwright, GitHub Actions.

## How to use it

**As the presenter:** follow [`storybook.md`](storybook.md). Start with
[Before the workshop](storybook.md#before-the-workshop) (tool versions, keys, Docker, Playwright
browsers). The storybook is written for live improvisation: every command and prompt is
in a copyable block, and the rehearsal numbers tell you how long each prompt takes.

**As an attendee building along:** you need Claude Code (2.1.277 or newer), Node.js 24,
`gh`, Git, and an OpenRouter key (handed out on day 1). On Windows, work in WSL2. If you
fall behind, catch up from the rehearsal repo at the start of any half day:

```bash
gh repo clone rstropek/vibecode26-agentic-rehearsal todo-cat && cd todo-cat
git reset --hard step20      # the tag of the last step you want to keep
npm ci
cp .env.example .env         # then fill in BETTER_AUTH_SECRET and OPENROUTER_API_KEY
npm run db:reset
```

**To re-rehearse a step**, for example after a dependency update, see
[`rehearsal/README.md`](rehearsal/README.md). The prompts are checked against the storybook
with `rehearsal/scripts/check-prompts.py`.

## Rehearsal at a glance

Rehearsed on 4 October 2026 with Claude Code 2.1.289 and Opus 5.5 at effort high, one fresh
session per prompt. All prompts together took about 4 hours (about 3 h 20 min with the
parallel worktree steps overlapping) and about $82 at API list prices. The per-step
numbers are in the [timing table](storybook.md#timing).

## Background

The bootcamp reuses proven material from three earlier events by the same author: a
five-session Claude Code classroom with the same stack, a full-day agentic C# workshop
(the QA script, tech docs, and rehearsal approach), and a talk on the Microsoft Agent
Framework (Lissie, the raw-protocol-first demos, MCPJam, the Aspire dashboard).
