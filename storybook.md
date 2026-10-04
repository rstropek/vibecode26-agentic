# Storybook: todo-cat

**Hands-on Bootcamp Agentic Coding with Claude Code: Build a Real App in Two Days**

Presenter guide, not a book to follow alone. Improvisation is the plan. We build
**todo-cat** from an empty folder: a to-do list kept by **Lissie**, a cat with the
attitude you'd expect. Errands that need a dog go to **Sindi**, the dog next door, over
A2A.

Per step: goal, the script or prompt (copyable), a demo block, a few bullets to
discuss, and one line for "if it breaks". Start every prompt in a **fresh session** in
the repo root unless the step says otherwise.

Rehearsed headless with `claude -p` (Opus 5.5, effort high, auto mode), one fresh
session per prompt. The finished app after every step is tagged in
[rstropek/vibecode26-agentic-rehearsal](https://github.com/rstropek/vibecode26-agentic-rehearsal)
(`step04`, `step06`, …). Rehearsal scripts, prompts, and logs are in
[`rehearsal/`](rehearsal/README.md).

## Timing

Wall-clock time per prompt in the headless rehearsal (Opus 5.5, effort high). Costs are
API list prices from `claude -p`, less with a subscription.

| Step | Prompt | Time | Turns | Cost |
| --- | --- | ---: | ---: | ---: |
| 4 | script: scaffold | ~30 s | – | – |
| 5 | script: onto GitHub | ~5 s | – | – |

## Before the workshop

- Claude Code **2.1.277 or newer**, auto-update off for both days:
  ```bash
  claude --version
  echo 'export DISABLE_AUTOUPDATER=1' >> ~/.bashrc    # or ~/.zshrc
  ```
- Node.js 24, `gh` logged in, Docker running, Aspire dashboard image pulled. On Linux,
  `bubblewrap` and `socat` for the sandbox demo:
  ```bash
  node --version && gh auth status && docker info --format '{{.ServerVersion}}'
  docker pull mcr.microsoft.com/dotnet/aspire-dashboard:latest
  which bwrap socat
  ```
- Playwright's Chromium pre-installed (not over conference wifi):
  ```bash
  npx -y playwright@1 install chromium
  ```
- OpenRouter keys ready to hand out, each with a spend cap.
- Lissie slides: `her_majesty.jpeg` and `danger.jpeg` from
  [microsoft-agent-framework-intro](https://github.com/rstropek/microsoft-agent-framework-intro).
- Terminal at 20 pt or larger, browser zoom at 125 to 150 %.
- Fallback for every step that commits: the rehearsal repo has one tag per step. Recovery
  is more than a reset, because `node_modules` and the SQLite file aren't in git:
  ```bash
  gh repo clone rstropek/vibecode26-agentic-rehearsal todo-cat && cd todo-cat
  git reset --hard step10      # the tag of the last step you want to keep
  npm ci
  cp .env.example .env         # then fill in BETTER_AUTH_SECRET and OPENROUTER_API_KEY
  npm run db:reset             # exists from step 10 on
  ```
  Attendees who fell behind use the same commands at the start of each half day.

---

# Day 1 morning: mental model, first slice, and the QA loop

## Step 1: welcome and setup check

**Goal:** everybody knows how to take part and has a working toolchain.

```bash
claude --version     # 2.1.277 or newer
node --version       # 24 or newer
gh auth status
```

- Two ways to take part: watch and ask, or build alongside with your own Claude
  subscription. Building alongside? Effort medium saves quota: `/effort medium`.
- OpenRouter keys get handed out now. They go into `.env` in step 4, never into git.
- Windows: work in WSL2. The QA script, SQLite, and the sandbox demo need a Linux shell.

## Step 2: agent = model + harness

**Goal:** the mental model for the two days.

```bash
mkdir -p /tmp/empty && cd /tmp/empty && claude
```

Then, in the session: `/context`.

- **The model you rent, the harness you build.** The model predicts tokens. The harness
  (Claude Code) runs the loop: the model asks for a tool (read, edit, run), the harness
  executes it, the result goes back in, and so on until the task is done.
- **What the agent sees:** the system prompt, `AGENTS.md`, skill descriptions, tool
  results, your prompt. `/context` in an empty folder shows the baseline before you
  typed a word.
- **What it doesn't see:** your screen, your intent, anything it hasn't read. Everything
  we build in two days (tech docs, skills, QA script, CI, tests) exists to fill that gap.
- **Effort is model-specific.** Opus 5.5 at `medium` thinks roughly as much as Opus 5 at
  `high`. We rehearsed at `high`, which buys more research per prompt.

## Step 3: Claude Code basics

**Goal:** the five things you need before the first prompt.

- `Shift+Tab` cycles the permission modes: default (asks), accept edits, plan, auto.
  **Plan mode** reads and proposes but touches no file.
- `/model` and `/effort` switch model and effort, `/status` shows account, model, and
  mode.
- `!` runs a shell command whose output lands in the conversation:
  ```text
  !git status
  ```
- `Esc` stops the agent, `Esc Esc` (or `/rewind`) jumps back to an earlier message.
- `/context` and `/usage` (alias `/cost`) are the two numbers to keep an eye on.

## Step 4: scaffold without an agent

**Goal:** a Next.js 16 app with Biome, an npm workspaces root, and `.env`. Generators
only, no agent.

Script ([`materials/scaffold.sh`](materials/scaffold.sh)), run where `todo-cat/` should
be created:

```bash
#!/usr/bin/env bash
# Step 4: scaffold todo-cat with generators only, no agent.
# Usage: scaffold.sh [directory]   (default: todo-cat; the OpenRouter key comes from $OPENROUTER_API_KEY if set)
set -euo pipefail
DIR=${1:-todo-cat}

# Next.js 16 with TypeScript, Tailwind, Biome, App Router; AGENTS.md from Next's agent rules
npx -y create-next-app@16.3.8 "$DIR" \
  --ts --tailwind --biome --app --no-src-dir --no-react-compiler \
  --import-alias "@/*" --use-npm --agents-md --disable-git --yes
cd "$DIR"
git init -q -b main
npm pkg set name=todo-cat
# Claude Code reads AGENTS.md natively; a CLAUDE.md next to it would replace it
rm CLAUDE.md

# npm workspaces root: shared zod contract and the CLI, declared now, filled later
mkdir -p contract cli
printf '{ "name": "@todo-cat/contract", "version": "0.1.0", "private": true }\n' > contract/package.json
printf '{ "name": "todo-cat-cli", "version": "0.1.0", "private": true }\n' > cli/package.json
npm pkg set 'workspaces[0]=contract' 'workspaces[1]=cli'
npm install --silent

# Local SQLite file lives in data/ (folder in git, content not)
mkdir -p data && printf '*\n!.gitignore\n' > data/.gitignore

# Secrets: .env stays local (create-next-app ignores .env*), .env.example documents it
cat > .env.example <<'EOF'
# SQLite file used by Drizzle, Better Auth and Mastra memory
DATABASE_URL=file:./data/app.db
# OpenRouter key for Lissie (Day 2)
OPENROUTER_API_KEY=sk-or-v1-...
# Better Auth: secret (openssl rand -base64 32) and the app's base URL
BETTER_AUTH_SECRET=change-me
BETTER_AUTH_URL=http://localhost:3000
EOF
sed -e "s|^OPENROUTER_API_KEY=.*|OPENROUTER_API_KEY=${OPENROUTER_API_KEY:-sk-or-v1-...}|" \
    -e "s|^BETTER_AUTH_SECRET=.*|BETTER_AUTH_SECRET=$(openssl rand -base64 32)|" .env.example > .env
printf '!.env.example\n' >> .gitignore

git add -A
git commit -qm "Scaffold todo-cat (create-next-app, npm workspaces)"
git log --oneline
```

Demo:

```bash
cd todo-cat
cat AGENTS.md                          # Next's agent rules: "This is NOT the Next.js you know"
ls node_modules/next/dist/docs/        # the docs that block points to, exact for this version
cat package.json                       # workspaces: contract, cli
npm run dev                            # http://localhost:3000
```

- **Deterministic work goes to generators, judgment goes to the agent.** Faster, cheaper,
  same result every time. If there's no generator, let the agent *write a script* and
  review it.
- The workspaces are declared now, empty, so the QA script and CI (step 9) never have
  to be rebuilt for a monorepo.
- `AGENTS.md` ships with Next.js. The framework puts its current docs into the package
  because models keep writing outdated Next.js code. `next dev` re-adds the block if
  you delete it.
- `.env` is git-ignored and only server-side code reads it. Secrets never reach the
  repo or the browser.

If it breaks: `create-next-app` asks questions → a flag is missing; add it, don't answer
by hand.

## Step 5: onto GitHub right away

**Goal:** a public repo from minute one. Every step from here on ends with commit and
push.

```bash
gh repo create todo-cat --public --source . --push
gh repo view --web
```

- Public, because required status checks (branch protection, Day 2) on private repos
  need a paid GitHub plan.
- One commit per step: every diff stays small enough to review what the agent did.

If it breaks: name taken → `gh repo create todo-cat-<initials> --public --source . --push`.

## Step 6: `AGENTS.md` and tech docs

**Goal:** a small, self-maintaining project memory. `AGENTS.md` is the map, the tech docs
hold decisions and gotchas.

<!-- prompt: step06 -->
```text
Turn AGENTS.md into a short map for future agent sessions. Keep the nextjs-agent-rules block unchanged.

- What todo-cat is, in two sentences: a to-do list web app kept by Lissie, a cat with attitude (an AI agent, coming later). Next.js 16 App Router; npm workspaces contract/ (shared zod schemas) and cli/ (the todo-cat CLI), both still empty.
- Exact commands for what exists today (dev server, build, Biome). Nothing for things that don't exist yet.
- The technologies here are newer than your training data. Verify APIs with current docs, don't rely on memory.
- A "Tech docs" section. tech-docs/ holds project-specific technical docs; agents are the primary audience. Rules: describe approach, principles, design decisions with their reasons, and gotchas; point to the central files instead of copying code; leave out anything an agent finds out by reading the code; current state only, delete outdated content instead of adding caveats. Then an index, one line per article. First article: tech-docs/workspaces.md, the workspace layout and why it exists before its content does.
- End with a maintenance rule addressed to you, the agent: update AGENTS.md and the tech docs in the same change whenever a change invalidates a line or teaches a costly lesson. Prefer deleting over adding, pointers over prose, one sentence per bullet.

Done when `npm run lint` passes. Then commit directly to main and push.
```

Demo:

```bash
cat AGENTS.md
cat tech-docs/workspaces.md
ls CLAUDE.md                           # gone on purpose: Claude Code reads AGENTS.md natively
```

Then, in a fresh `claude` session: `/context` → "Memory files" lists `AGENTS.md`.

- `AGENTS.md` is in **every** request. Short and dense beats complete. Each line has to
  pass one test: would an agent still get this wrong after reading the file it points
  to?
- **Constrain shape, not count.** "Under 60 lines" gets gamed by packing four sentences
  into a bullet. "One sentence per bullet" can't be.
- The maintenance rule is the trick: nobody edits this file by hand from now on. Watch
  for `AGENTS.md` and `tech-docs/` in every later diff.
- **`CLAUDE.md` and auto memory** in two sentences: `CLAUDE.md` is Claude Code's own name
  for the same kind of file, and it wins if both exist, so we have none. Auto memory is
  what Claude writes down about you and the project by itself (`/memory`); it lives in
  your home directory, not in the repo, so your team doesn't get it.
- Skills vs. tech docs: skills are reusable across projects, tech docs are this
  project's decisions.

If it breaks: the agent works on a branch → `git switch main && git merge -` and push.
