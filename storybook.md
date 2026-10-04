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
| 6 | `AGENTS.md` and tech docs | 0.8 min | 7 | $0.26 |
| 7 | script: skills | ~30 s | – | – |
| 8 | test harness | 3.1 min | 22 | $0.79 |
| 9 | QA script and CI | 4.3 min | 27 | $0.88 |
| 10 | Drizzle, grounding | 5.9 min | 50 | $1.87 |
| 11 | authentication | 9.1 min | 65 | $3.06 |
| 12 | architecture first: todo core | 5.3 min | 28 | $1.51 |
| 13 | REST API | 3.1 min | 21 | $0.93 |

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
printf '{\n  "name": "@todo-cat/contract",\n  "version": "0.1.0",\n  "private": true\n}\n' > contract/package.json
printf '{\n  "name": "todo-cat-cli",\n  "version": "0.1.0",\n  "private": true\n}\n' > cli/package.json
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

npm run lint --silent
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

Rehearsal: 0.8 min, 7 turns, $0.26.

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

## Step 7: install skills

**Goal:** current expertise for the fast-moving parts of the stack, and some taste.

Script ([`materials/skills.sh`](materials/skills.sh)), in the repo root:

```bash
#!/usr/bin/env bash
# Step 7: install skills (project scope) for Claude Code. Run in the repo root.
set -euo pipefail
A=(--agent claude-code -y)

# Tech: current docs for any library (ctx7 CLI), the vendors' own playbooks for Mastra and CopilotKit
npx -y skills@1.7.0 add upstash/context7 --skill find-docs "${A[@]}"
npx -y skills@1.7.0 add mastra-ai/skills --skill mastra "${A[@]}"
npx -y skills@1.7.0 add CopilotKit/CopilotKit --skill copilotkit "${A[@]}"

# Meta (write your own skills) and design (taste for UI work)
npx -y skills@1.7.0 add anthropics/skills --skill skill-creator --skill frontend-design "${A[@]}"

# impeccable: design commands (init, critique, polish, ...). No hooks: we enforce quality with the QA script.
npx -y impeccable@4.1.0 install --project --providers=claude --no-hooks --yes
# its engine binary is platform-specific (18 MB); the launcher downloads it on first use
printf '\n# impeccable engine binary (platform-specific, downloaded on first use)\n.claude/skills/impeccable/scripts/bin/\n' >> .gitignore

# Skills are vendored code: Biome must not lint or reformat them
node -e 'const fs=require("fs");const j=JSON.parse(fs.readFileSync("biome.json","utf8"));j.files.includes.push("!.claude","!.agents");fs.writeFileSync("biome.json",JSON.stringify(j,null,2)+"\n")'
npx biome format --write biome.json > /dev/null
npm run lint --silent

git add -A
git commit -qm "Install skills"
git push -q
ls .claude/skills
```

Rehearsal: ~30 s.

Demo:

```bash
npx -y skills@1.7.0 add mastra-ai/skills -l     # what a repo offers before you install
head -5 .claude/skills/mastra/SKILL.md          # name + description: the only part in context
cat skills-lock.json                            # pinned like a lockfile
```

Then a fresh `claude` and `/context` → the skills line is small.

- **A skill is a folder with a `SKILL.md`**: name and description in the front matter,
  instructions in the body, optional scripts. Only name and description sit in
  context; the body loads when the task matches. Progressive disclosure, so many
  skills cost little. `/skill-doctor` shows which ones never fire.
- Kinds: **tech** (`find-docs` = Context7 for any library, `mastra` and `copilotkit`
  from the vendors themselves), **meta** (`skill-creator`, we use it on the afternoon),
  **design** (`frontend-design` and impeccable carry taste, Day 2).
- Skills run with the agent's permissions. Read them before you install them, like
  any dependency. [skills.sh](https://skills.sh) shows a security assessment.
- Committed with `skills-lock.json`: every teammate's agent gets the same expertise.

If it breaks: GitHub rate limit on `skills add` → `gh auth login` and rerun the line.

## Step 8: anatomy of a prompt that holds up

**Goal:** a test harness before any feature, and a prompt shape we use for the rest of
the two days.

<!-- prompt: step08 -->
```text
Set up our test harness, before any feature exists: Vitest for unit and integration tests (`npm test`) and Playwright for end-to-end tests (`npm run test:e2e`, Chromium only, starting its own dev server on a spare port). This Next.js version may differ from what you know, so read its testing guides in node_modules/next/dist/docs/ first. Add one real smoke test for each. Write tech-docs/testing.md (strategy, commands, gotchas) and add it to the AGENTS.md index.

Done when `npm test`, `npm run test:e2e`, and `npm run lint` pass. Then commit directly to main and push.
```

Rehearsal: 3.1 min, 22 turns, $0.79.

Demo:

```bash
npm test
npm run test:e2e
cat tech-docs/testing.md
git show --stat HEAD
```

- Take the prompt apart, five parts:
  - **outcome**: the harness and two npm scripts,
  - **constraints**: Chromium only, its own server, a spare port,
  - **docs pointer**: the testing guides in `node_modules`,
  - **verification**: one real test each,
  - **completion condition**: "Done when … Then commit and push." Every prompt from here
    on ends like that.
- No config files, plugins, or ports in the prompt. That's the agent's job.
- Tests before features: the tests are the agent's feedback loop, and yours when you
  review agent code.
- Read the summary: it reports the decisions it made. In the rehearsal: Next 16 refuses
  a second `next dev` in the same folder, so the e2e server builds into `.next-e2e/`
  (`NEXT_DIST_DIR`), and Playwright asks the OS for a free port. Nobody asked for that;
  the agent ran e2e next to a running `npm run dev` and found out.

If it breaks: Playwright browser missing → `npx playwright install chromium`.

## Step 9: the QA script and CI, one prompt

**Goal:** one command that tells an agent (and you, and CI) whether the work is done.

<!-- prompt: step09 -->
```text
Add a QA script and CI that give agents (and humans) fast, deterministic feedback.

- scripts/qa.sh runs Biome, typecheck (all workspaces), production build, Vitest, and Playwright. One section per tool with PASS/FAIL; output of passing sections goes only to a log file, output of failing sections is printed; a summary at the end; non-zero exit code on failure. Write the output for agents: short, plain, no colors. Also available as `npm run qa`.
- Playwright must never collide with `npm run dev` or with another checkout of this repo running at the same time: its port, its Next.js dist dir, and its database file are overridable via environment variables. The database arrives in a later step; make DATABASE_URL a temp file in the e2e server's env now.
- AGENTS.md rule: run the QA script before you call a task done; fix the code instead of suppressing findings.
- Prove that it works: temporarily plant two typical mistakes (a lint error and a type error), run the script, check that both are caught with file and line, then revert them.
- A GitHub Actions workflow runs the same script on every push and pull request: Node 24, npm ci, cached Playwright browsers, generated dummy secrets in .env (never real ones). No deployment.
- Document the QA script and CI in tech-docs/testing.md.

Commit directly to main and push. Done when the QA script is green locally and the CI run of your push is green (watch it with gh).
```

Rehearsal: 4.3 min, 27 turns, $0.88. QA script ~10 s locally, CI run ~50 s.

Demo:

```bash
npm run qa                                   # all PASS, summary at the end
echo 'export const x: number = "oops";' > app/oops.ts
npm run qa; echo "exit $?"                   # typecheck FAIL with file:line, exit 1
rm app/oops.ts
gh run list --limit 3
gh run view --web
```

- **Deterministic tools → feedback → agent fixes → repeat.** That loop is what makes
  agent output reliable. Agents ignore warnings; they don't ignore a red section.
- Output for agents: one section per tool, failures only, summary last. Live follow-up
  if it's too noisy: "make the QA output more concise".
- "Fix, don't suppress": without that line, agents like to "fix" findings by disabling
  the rule.
- The agent tested its own test: two planted mistakes, both caught, reverted.
- CI calls the **same** script. No second definition of "green". No CD on purpose.
- **Hooks** would make this deterministic (a `Stop` hook that runs the QA script). We
  don't build one; the rule in `AGENTS.md` plus CI is enough for today.
- From here on, every prompt ends with "Done when the QA script is green. Then commit
  and push."

If it breaks: CI red but local green → `gh run view --log-failed`, paste it into the
session.

## Step 10: grounding in current docs

**Goal:** Drizzle and SQLite with one seam, and an agent that looks things up instead of
remembering them.

<!-- prompt: step10 -->
```text
Add persistence: Drizzle ORM on SQLite via @libsql/client, with DATABASE_URL from .env (already set to file:./data/app.db).

- One server-only module lib/db.ts exports the Drizzle instance; nothing else opens the database.
- Migrations with drizzle-kit: `npm run db:generate`, `npm run db:migrate`, and `npm run db:reset` (deletes the local database file and migrates a fresh one). No domain tables yet: todos arrive later together with the architecture, auth tables with authentication.
- A Vitest test migrates a temporary database file and proves the connection works. The e2e server gets its own migrated temp database.
- Drizzle's API has changed a lot. Start at https://orm.drizzle.team/llms.txt and follow the relevant links before coding.
- Add a "Researching docs" section to AGENTS.md: which source to use for what (vendor llms.txt files like Drizzle's, the docs in node_modules/next/dist/docs, the installed skills, the ctx7 CLI from the find-docs skill as the fallback for any other library).
- Write tech-docs/database.md.

Done when the QA script is green. Then commit directly to main and push.
```

Rehearsal: 5.9 min, 50 turns, $1.87. The agent read `llms.txt` and six doc pages before
writing code.

Demo:

```bash
curl -s https://orm.drizzle.team/llms.txt | head -30    # what the agent read first
npm run db:reset && ls -la data/
git status --short                                      # nothing from data/
gh run watch                                            # first change through the QA loop and CI
```

- **Four ways to ground the agent**, each reaching a different source:
  - **`llms.txt`**: a vendor-curated, agent-readable index at a stable URL. One URL in
    the prompt beats twenty lines of pasted docs, and it's current every time.
  - **Docs in `node_modules`**: exact for the installed version (Next.js).
  - **Skills**: the vendor's playbook (Mastra, CopilotKit).
  - **Context7** (`ctx7` CLI from `find-docs`): the fallback for everything else.
- The "Researching docs" section makes it stick: later prompts don't have to repeat it.
- **One seam for the database**: `lib/db.ts`. Auth, todos, and agent memory land in the
  same file later, and exactly one module interprets `DATABASE_URL`.
- Tests and e2e run on temp files, dev on `data/app.db`. SQLite gives isolation for free.
- `npm run db:reset` is part of recovery: the database isn't in git.
- Rehearsal finding: Drizzle's docs describe v1 (release candidate) while npm `latest` is
  still 0.45. The agent followed the docs, pinned `1.0.0-rc.4` exactly, and said so in
  its summary. Grounding beats training data, and the summary is where you review it.
- Rehearsal finding, security: the agent printed `.env` while checking the setup, and
  then warned that the OpenRouter key had been in its output. **Everything in `.env` is
  readable by the agent and reaches the model.** Spend-capped keys only (more in the
  sandbox step).

If it breaks: `DATABASE_URL is not set` → `.env` is missing; `cp .env.example .env`.

---

# Day 1 afternoon: business logic, auth, and a CLI to drive it

Catch-up point: `git reset --hard step10` (see [Before the workshop](#before-the-workshop)).

## Step 11: authentication

**Goal:** sign-up, sign-in, sign-out with Better Auth, and the auth pieces the whole
afternoon builds on, named in one prompt.

<!-- prompt: step11 -->
```text
Add authentication with Better Auth, email and password only. Use better-auth and @better-auth/drizzle-adapter at exactly 1.7.7.

- Drizzle adapter on lib/db.ts. Generate the auth schema with Better Auth's CLI and apply it through our migration flow (secret and URL are already in .env).
- Enable now the plugins this afternoon needs: bearer (the REST API and the CLI will send `Authorization: Bearer <token>`) and device authorization (the CLI will log in like `gh auth login`). Their pages and clients come later.
- One server-side helper that maps a request to the signed-in user's id (session cookie or bearer token), or null. Every adapter we add later (REST, agent tools, MCP) uses it; nothing else reads sessions.
- /signup and /login pages with Tailwind. Shared form styling lives in components/ui/, no repeated class strings. / requires a session, checked server-side, and shows the user's name and a sign-out button.
- Tests: Vitest integration tests with Better Auth's test-utils plugin on a temp database (sign-up works, the right password signs in, a wrong one is rejected, the helper returns the user id for a cookie and for a bearer token and null without either), plus one Playwright e2e of the real sign-up, sign-out, and sign-in flow.
- Better Auth is newer than your training data. Start at https://better-auth.com/llms.txt and follow its Next.js, Drizzle adapter, email and password, bearer, device authorization, and test-utils pages.
- Write tech-docs/auth.md.

Done when the QA script is green. Then commit directly to main and push.
```

Rehearsal: 9.1 min, 65 turns, $3.06.

Demo:

```bash
npm run db:reset && npm run dev
```

Sign up at <http://localhost:3000/signup>, sign out, delete the cookies, reload `/` →
redirect to `/login`. Then:

```bash
cat tech-docs/auth.md
git show --stat HEAD
```

- **Name what the afternoon needs, now.** Bearer and device authorization have no UI
  yet, but enabling them in the auth step means one schema generation, and the request
  → user id helper is the one seam every adapter (REST, CLI, agent tools, MCP) goes
  through.
- **The session check runs server-side.** A client check is UX; the server check is the
  gate. Look for it in the diff.
- The auth schema is **generated**, not hand-written, and still flows through our one
  migration path.
- `components/ui/` now beats a refactor later: shared components, no copy-pasted
  class recipes.
- The test-utils plugin runs real auth flows in Vitest without HTTP or a browser. Fast
  tests cover the logic, one Playwright test covers the wiring.
- Exact versions in the prompt: Better Auth is one of the fragile dependencies, and
  1.7 moved things around (MCP auth, Day 2).
- Rehearsal findings worth reading out from the summary and `tech-docs/auth.md`:
  - the Better Auth CLI can't load anything that imports `server-only`, so it runs on
    its own config file and the options live in one shared module,
  - its Drizzle generator emits relations v1, which Drizzle v1 no longer has, so the
    agent switched to the relations-v2 adapter,
  - `frontend-design` fired by itself for the login pages (fonts, a color scheme, dark
    mode). Skills trigger on the task, not on a slash command.

If it breaks: `BETTER_AUTH_SECRET` missing in CI → the workflow's dummy secrets come
from `.env.example`; check the agent added nothing new without an example entry.

## Step 12: architecture first

**Goal:** planning before coding. You write the architecture, plan mode turns it into a
plan, and the prompt only has to name the task.

Copy the architecture article (written ahead of time, shipped with this storybook) into
the repo and commit it on its own, so the human-written part has its own diff:

```bash
curl -fsSL https://raw.githubusercontent.com/rstropek/vibecode26-agentic/main/materials/architecture.md -o tech-docs/architecture.md
git add tech-docs/architecture.md && git commit -m "Add architecture" && git push
```

Walk through [`materials/architecture.md`](materials/architecture.md): one todo service
with per-user queries, a shared `contract` workspace, thin adapters (REST, CLI, later
agent tools and MCP), "not found" instead of "forbidden", and a "deliberately not done"
list.

Then `Shift+Tab` into **plan mode**, paste the prompt, read the plan, approve it.

<!-- prompt: step12 -->
```text
Implement the todo core described in tech-docs/architecture.md: the todos table with its owner, the todo service, and the contract workspace with the zod schemas. No adapters yet; REST, CLI, and agent tools follow in later sessions.

- Tests: the service against a temp database, with per-user isolation for every use case.
- A dev seed, `npm run db:seed`: a demo user (demo@todo-cat.dev, password cat-person-2026) with about a dozen todos spread over the last two weeks, some done, some with due dates. Running it twice gives the same state.
- You may refine architecture.md (pointers, gotchas). If you need to deviate from its principles, ask first. Add it to the AGENTS.md index.

Done when the QA script is green. Then commit directly to main and push.
```

Rehearsal: 5.3 min, 28 turns, $1.51 (headless, without plan mode). No questions, no
deviations; 38 tests.

Demo:

```bash
git diff HEAD~1 -- tech-docs/architecture.md     # what the agent added to our article
npm run db:reset && npm run db:seed              # demo@todo-cat.dev / cat-person-2026
npx drizzle-kit studio                           # browse the todos table
```

- **Three artifacts, three jobs:** the architecture says *how* we build (human, before
  the session), the prompt says *what* to do now, the tech docs record what the agent
  learned. The prompt got short because the rules live in the article.
- Agents default to generic CRUD and repositories, because that's their training data.
  An explicit architecture and an explicit "deliberately not done" override the default.
- **Plan mode** is where you catch a wrong turn for the price of reading a page. Look
  for: does the plan put the user id into every function? Does it invent a repository?
- **Isolation tests per use case**: two users, every operation. That's the
  authorization test suite for every adapter that comes later.
- "Ask first if you deviate" turns silent drift into a question.
- The seed gives the afternoon a realistic list, including "last week".
- Read the "choices you may want to review" part of the summary. In the rehearsal:
  random UUID ids (unguessable, but long to type in a CLI), a clock parameter only
  tests and the seed use, list order, case-insensitive search for ASCII only. Each is
  a decision a reviewer should make, not discover.

If it breaks: plan looks wrong → say what's wrong in plan mode, don't approve and fix later.

## Step 13: a REST API with bearer tokens

**Goal:** the first door for non-browser clients, with the lock tests written in the
same prompt as the door.

<!-- prompt: step13 -->
```text
Add the REST adapter from tech-docs/architecture.md: /api/todos for non-browser clients (a CLI comes next), covering every use case of the todo service.

- Write the 401 tests together with the endpoints: one per endpoint without a token and one with an invalid token.
- Integration tests call the route handlers on a temp database: one flow with a real bearer token that adds a todo, lists it, marks it done, filters, and deletes it; another user's todo id gives 404; invalid input gives 400 with the error code.
- Write tech-docs/rest-api.md: one line per endpoint (method, path, contract schemas, status codes) and how to get a bearer token with curl.

Done when the QA script is green. Then commit directly to main and push.
```

Rehearsal: 3.1 min, 21 turns, $0.93. 19 tests: two 401s per endpoint, the flow, 404 for
another user's id, five kinds of bad input.

```bash
cat tech-docs/rest-api.md
cat app/api/todos/route.ts                   # thin: parse, user, service, status code
```

- **The lock tests are in the prompt, not in a follow-up.** One 401 per endpoint is
  cheap to write and expensive to forget. Count them in the diff before you look at
  anything else.
- The prompt is four lines because the architecture says how adapters work: parse with
  the contract, `getUserId`, call the service, map errors. Check the route handlers are
  thin.
- A test that can't fail proves nothing. If the summary doesn't say the agent broke its
  own auth once to see the tests go red, ask for it.
- Decisions in the summary: the user is resolved *before* the input is parsed (a bad
  request without a token is a 401, not a 400), and a malformed id is a 404 like
  another user's id. Both follow from the architecture without being in the prompt.
- Rehearsal finding for "staying in control": auto mode's safety check refused the
  agent's own cleanup, `rm -rf "$(cat /tmp/…)"`, because the target couldn't be
  resolved. The agent rewrote it with literal paths. Auto mode isn't "no checks".

If it breaks: 401 with a token you just got → the bearer plugin may want the signed
token from `set-auth-token`, not the raw session token; `tech-docs/rest-api.md` says
which.

## Step 14: raw protocol first

**Goal:** use the door with `curl` before any client exists. A protocol you've seen raw
is a protocol you can debug.

```bash
npm run db:reset && npm run db:seed && npm run dev      # terminal 1
```

Terminal 2 (field names as in the rehearsal; `tech-docs/rest-api.md` has yours):

```bash
curl -si http://localhost:3000/api/todos | head -1                     # 401
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/sign-in/email \
  -H 'content-type: application/json' \
  -d '{"email":"demo@todo-cat.dev","password":"cat-person-2026"}' | jq -r .token)
curl -s -H "authorization: Bearer $TOKEN" 'http://localhost:3000/api/todos?status=open' | jq '.[0]'
ID=$(curl -s -X POST -H "authorization: Bearer $TOKEN" -H 'content-type: application/json' \
  -d '{"title":"added from curl"}' http://localhost:3000/api/todos | jq -r .id)
curl -s -X PATCH -H "authorization: Bearer $TOKEN" -H 'content-type: application/json' \
  -d '{"done":true}' http://localhost:3000/api/todos/$ID | jq -c .
curl -s -X POST -H "authorization: Bearer $TOKEN" -H 'content-type: application/json' \
  -d '{"title":""}' http://localhost:3000/api/todos | jq -c .           # 400 validation-failed
curl -s -o /dev/null -w '%{http_code}\n' -X DELETE -H "authorization: Bearer $TOKEN" \
  http://localhost:3000/api/todos/$ID                                  # 204
```

- Sign-in returns a session token, and the bearer plugin accepts it in the
  `Authorization` header. Same session, different transport than the cookie.
- The error body is the contract's: `{ error: { code, message } }`. Stable codes are
  what clients (and agents) branch on.
- Everything the CLI does in the next step is one of these requests.

If it breaks: `jq: command not found` → `sudo apt install jq` (or drop the `| jq` parts).
