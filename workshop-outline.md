# Workshop outline

**Hands-on Bootcamp Agentic Coding with Claude Code: Build a Real App in Two Days**

Two consecutive full days, four half days. We build **todo-cat** from an empty folder.
The to-do list is kept by **Lissie**, a cat who manages your list with the attitude
you'd expect. She comments on every new todo and on every "done" (mark "feed the cat" as
done and you'll hear about it), and she declines everything that isn't about your list.
Errands that need a dog go to **Sindi**, the dog next door. The two ladies know each
other through the fence, and Lissie reaches her over A2A.

The stack is the one from the classroom in `../2026-claude-classroom`: Next.js 16, Better
Auth, SQLite through Drizzle, Mastra agents on OpenRouter, CopilotKit and AG-UI, Vitest
and Playwright, GitHub Actions. Everybody gets an OpenRouter key on day 1.

## Source material

All three were given live, so their prompts, commands, and gotchas are proven. When you
write a step of this workshop, look up the referenced step in the source first and
reuse what works. References in brackets point to them.

- **`[S1/5]`, the Heise classroom** (session 1, step 5). Local folder
  `/home/rainer/github/2026-claude-classroom` (sibling of this repo). Storybooks
  `storybook-01.md` to `storybook-05.md`, the finished app after each session in
  `session-N-result/` (same stack as todo-cat, same app under the name `ai-tutor`),
  sandbox demos in `session-3-presentation/demos/`, diagrams in `images/`.
- **`[CS/4]`, the C# workshop** (step 4). GitHub
  <https://github.com/rstropek/2026-agentic-csharp-workshop>, clone with
  `gh repo clone rstropek/2026-agentic-csharp-workshop`. `storyboard.md` is the script.
  `rehearsal/` has the rehearsal setup (`scripts/rehearse.sh`, prompts, git bundle with
  one tag per step), and `rehearsal/snapshot/scripts/qa.sh` is the QA script that ours is
  modeled on.
- **`[MAF/05]`, the Agent Framework talk** (step 05). GitHub
  <https://github.com/rstropek/microsoft-agent-framework-intro>, clone with
  `gh repo clone rstropek/microsoft-agent-framework-intro`. `storybook.md` is the
  presenter cheat sheet. Source of the Lissie persona (slides `her_majesty.jpeg`,
  `danger.jpeg`), the raw-protocol-first beats, the MCPJam CLI checks, and the Aspire
  dashboard setup (`scripts/start-backends.sh`).

## Before the workshop

- Rehearse every prompt headless with `claude -p` and keep the result as a git bundle
  with one tag per step, so any step can be skipped on stage with
  `git reset --hard <tag>` `[CS rehearsal]`. Publish the tags as a repo, too: each
  half day starts with an optional catch-up sync point for builders who fell behind.
- Freeze the dependency matrix. The rehearsal's lockfile and `skills-lock.json` are the
  reference, and fragile prompts (CopilotKit, AG-UI, Mastra, Better Auth, MCP SDK) name
  exact versions. Claude Code 2.1.277 or newer with auto-update off for both days.
  Playwright browsers and the Docker image pre-installed, not over conference wifi.
- Recovery means more than `git reset --hard <tag>`: also `npm ci` and a fresh database
  (`npm run db:reset`), because SQLite state isn't in git.
- OpenRouter keys ready to hand out, with a spend cap per key. Two models vetted for
  `gh auth status` OK.
- Docker running, Aspire dashboard image pulled. On Linux, `bubblewrap` and `socat` for
  the sandbox demo.
- Lissie slides ready (`her_majesty.jpeg`, `danger.jpeg` from the Agent Framework repo).
- Terminal at 20 pt or larger, browser zoom at 125 to 150 %.

## Day 1 morning: mental model, first slice, and the QA loop

- **Welcome and setup check.** The two ways to take part, OpenRouter keys handed out,
  `claude --version`, `node --version`, `gh auth status`. Windows attendees work in
  WSL2 (`qa.sh`, SQLite, sandbox). Build-alongside tip: effort medium saves quota.
- **Agent = model + harness.** The tool-use loop (read, edit, run). What the agent sees:
  system prompt, `AGENTS.md`, skill descriptions, tool results. What it doesn't see:
  your screen, your intent, anything it hasn't read. `/context` on an empty session.
  Effort as a model-specific setting `[CS/3]`.
- **Claude Code basics** `[S2/8]`. Permission modes and `Shift+Tab`, plan mode, `/model`,
  `/status`, `!` for shell commands that land in the conversation.
- **Scaffold without an agent** `[S1/1]` `[CS/1]`. `create-next-app` with Biome, `.env`,
  and the npm workspaces root (`contract/`, `cli/` declared now, filled later), so the
  QA script and CI never have to be rebuilt for a monorepo. Deterministic work goes to
  generators, judgment goes to the agent.
- **Onto GitHub right away.** `gh repo create todo-cat --public --source . --push`.
  Public, because required status checks on private repos need a paid GitHub plan.
  From here on, every step ends with commit and push.
- **`AGENTS.md` plus tech docs** `[S1/2]` `[CS/2-3]`. `AGENTS.md` stays small: overview,
  exact commands, an index of `tech-docs/*.md`. Tech docs hold decisions, principles,
  and gotchas with pointers to code, never copies of it, and the agent maintains them.
  Claude Code reads `AGENTS.md` natively (2.1.277 or newer), so there's no `CLAUDE.md`
  next to it. Prove it in `/context`, and say in two sentences what `CLAUDE.md` and auto
  memory are, because the published description names them.
- **Install skills** `[S1/3]` `[CS/2]`. One copyable script. Tech (`find-docs`,
  `mastra`, CopilotKit), meta (`skill-creator`), design
  (`frontend-design`, plus `npx impeccable install`). Progressive disclosure, so many
  skills cost little.
- **Anatomy of a prompt that holds up** `[S1/4]`. Outcome, constraints, docs pointer,
  verification, completion condition. Built live on the test harness prompt: Vitest
  and Playwright before any feature.
- **The QA script and CI, one prompt** `[CS/4]`. `scripts/qa.sh` runs Biome, typecheck,
  build, Vitest, and Playwright, with one section per tool, PASS/FAIL, a summary, and a
  non-zero exit code. Output is written for agents. Playwright gets its own port and a
  temp database, overridable per worktree, so it never collides with `npm run dev`.
  `AGENTS.md` rule: run it before you call a task done. The agent proves the script
  works with two planted mistakes. A GitHub Actions workflow calls the same script on
  every push and pull request, with generated dummy secrets and cached Playwright
  browsers. No CD. From here on, every prompt ends with "Done when the QA script is
  green. Then commit and push." Hooks get a mention as the deterministic way to enforce
  this, but we don't build any.
- **Grounding in current docs** `[S1/5]`. Drizzle and SQLite with `lib/db.ts` as the
  only seam, the migration flow, a migration test on a temp database. No domain table
  yet: `todos` arrives with the architecture in the afternoon, owned by a user from
  the start. `llms.txt`, docs in `node_modules`, skills, and Context7. First change
  through the QA loop and CI.

## Day 1 afternoon: business logic, auth, and a CLI to drive it

- **Authentication** `[S1/6]`. Better Auth with email and password, server-side session
  gate, `components/ui/` discipline, test-utils plugin for fast auth tests. The prompt
  names the plugins the afternoon needs (bearer, device authorization) and one helper
  that maps a request to a user id, reused by REST, agent tools, and MCP.
- **Architecture first** `[CS/6]`, and this is where "planning before coding" lives. A short `tech-docs/architecture.md`, written by you
  ahead of time and shipped with the storybook, copied into the repo here: one todo service
  with per-user queries, a shared `contract` workspace with the zod schemas, and thin
  adapters around it (REST, CLI, later agent tools and MCP). Hexagonal, without the
  ceremony. Then plan mode and the prompt, which now only has to name the task: the
  `todos` table with its owner, the service, the contract, per-user isolation tests.
- **A REST API with bearer tokens** `[S3/15]`. `/api/todos`, the 401 tests in the same
  prompt as the feature.
- **Raw protocol first** `[MAF/07]`. Sign in and call `/api/todos` with `curl` and the
  bearer token before any client exists. Copyable commands.
- **The `todo-cat` CLI** `[S3/16]` `[CS/8]`. Its own npm workspace, commander.js,
  device login like `gh auth login` (approval page, polling, token in the user's config
  directory). Agent-friendly: JSON output, errors on stderr,
  meaningful exit codes, never prompts, `--yes` for destructive commands.
- **A skill for the CLI** `[S3/16]` `[CS/8]`. Written with `skill-creator`: workflows and
  pitfalls, not a copy of `--help`.
- **The agent as a user** `[CS/8]`. A fresh session gets a request in plain words ("I
  have a busy weekend: put these on my list, and tell me what's still open from last
  week") and does it with the CLI. Same agent, first developer, now user.
- **Staying in control** `[S2/9]`, woven through the afternoon. Reading diffs and the
  agent's summary, `Esc`, `Esc Esc` and `/rewind`, the two-corrections rule, analysis
  prompts about the agent's own run.
- **Context hygiene** `[S2/10]`. No separate talk: told while the CLI prompt runs.
  `/context`, `/compact` with instructions, `/clear` between tasks, `/btw`, subagents as
  a context firewall, cost follows context.
- **Day 1 close.** One audit prompt for `AGENTS.md` and the tech docs `[S2/9]`. Last CI
  run of the day green.

## Day 2 morning: Lissie moves in, and the app gets a face

- **Lissie** `[S1/7]`. Mastra agent on OpenRouter, CopilotKit over AG-UI, per-user memory
  in SQLite. The persona is product, not config. "Don't wire this from memory": the
  skills carry the three-package handshake. Memory scoping is authorization, and so is
  the CopilotKit runtime: the prompt demands tests that one user can't read, reconnect
  to, or stop another user's thread (the leak found in `[S5/34]`). The chat e2e that
  calls the model stays out of the QA script and CI.
- **Raw protocol first** `[MAF/08]`. `curl -N` against the AG-UI endpoint and read the
  event stream before CopilotKit hides it.
- **Tool calling** `[S2/11]`. `listTodos`, `addTodo`, `setTodoDone` as one more adapter on
  the todo service, user id from the server session, read-only sidebar, tool calls
  rendered in the chat. Lissie comments on what she adds and what you mark as done.
- **Branch and pull request rhythm** `[S2/11]`. `gh pr create` with a description a
  reviewer can use, `!gh pr merge` from inside the session. Branch protection makes CI
  a required check.
- **A first design with `frontend-design`.** One prompt, one deliberate aesthetic
  direction, and a real todo list page next to the chat (add, check off, delete) on the
  todo service. That's the web UI the description promises, and it gives impeccable
  something to work on. Then `impeccable init` to capture product context.
- **Parallel agents in worktrees** `[S2/13]`. `claude --worktree`, `.worktreeinclude`
  for `.env`, one port and one database per worktree. Two agents at once:
  - the A2UI progress card `[S4/20]` in the chat: a fixed component tree and one custom
    catalog component, no generated surfaces. While it runs, the room gets the
    generative UI spectrum (controlled, declarative, open-ended),
  - impeccable (`critique`, then `polish`) on the todo list and auth pages.
- Each worktree prompt names the files that agent owns, plus its own E2E port and
  database. Conflicts in `AGENTS.md` and the tech docs are expected and get resolved
  by the agent doing the rebase.
- **A review loop in the background.** When the first worktree is done, a fresh session
  reviews its branch (`/code-review`) in the background while the room watches the
  other agent. Fresh context, no memory of why the code looks the way it does. Findings
  get fixed before the merge, and a human approves it.
- **Merge one, rebase the other.** What parallel work costs in git, why disjoint write
  areas matter for agents as much as for people, and CI as the referee.

## Day 2 afternoon: agents as users, boundaries, and side quests

- **Two side quests, presenter only, started in the background.** Two extra sessions,
  each in its own worktree, run on the presenter's machine while the main thread
  continues. Build-alongside attendees skip them and keep their time for remote MCP.
  - **Sindi the dog over A2A.** A separate, minimal Mastra app with one agent. Mastra
    publishes its agent card at `/api/.well-known/<agent>/agent-card.json` and the
    endpoint at `/api/a2a/<agent>`. Lissie gets it as a subagent through `A2AAgent`
    from `@mastra/core/a2a`, and delegates "fetch the ball" to her. Lissie's persona
    gets one exception to "only your todo list": errands for Sindi. Sindi's app owns its
    own exporter config, so the two quests don't touch the same files.
  - **OpenTelemetry into the Aspire dashboard.** `@mastra/otel-exporter` with a custom
    OTLP endpoint (HTTP/protobuf) on Lissie's Mastra instance, dashboard in Docker. One
    trace across both apps only if it comes for free. Two traces side by side are fine.
- **The CLI as a local MCP server** `[S3/17]` `[CS/9]`. `todo-cat mcp --stdio`, one
  tool per CLI command, sharing the code. Tool annotations take the place of `--yes`,
  tool errors the place of exit codes. Annotations are hints for the client, not
  enforcement: the service still checks ownership.
- **Test the MCP server without an agent** `[MAF/05]` `[CS/9]`. Raw JSON-RPC over stdin
  first, then the MCPJam CLI: `server doctor`, `tools list`, `tools call`, with
  `--transport stdio`. Only then Claude Code.
- **The agent as a user, MCP only** `[CS/9]`. The weekend request again, in a session
  with only the MCP server and no shell. CLI plus skill versus MCP, cost and turns side
  by side.
- **The app as a remote MCP server** `[S3/18]` `[CS/10]`. Streamable HTTP under
  `/api/mcp`, one more thin adapter on the todo service, Better Auth as the OAuth
  server. Better Auth 1.7 moved MCP auth into `@better-auth/mcp`, so the classroom
  prompt needs checking against the current docs, with exact versions. Tests for the
  401 and for two-user isolation. Claude Code logs in through the browser, and the
  MCPJam CLI (`oauth`) is the second client. Tagged fallback for this step. stdio versus
  Streamable HTTP: one local user with local resources, or many users over the network
  with a URL and OAuth.
- **Tool results are untrusted input** `[S3/17]`. The todo that talks to the model.
- **Sandboxing** (compressed from the `[S3]` presentation). Permissions versus OS
  sandbox, one blocked write and one blocked destination. When input is untrusted, the
  sandbox limits the blast radius of Claude's shell. It does nothing about what a
  remote MCP server does on its side.
- **Side quests land.** `curl` Sindi's agent card and one `message/send` by hand, then ask
  Lissie to get the ball fetched. Open the Aspire dashboard: Lissie's run, her tool
  calls, the A2A call to Sindi.
- **Wrap-up.** Walk the harness we built (memory, tech docs, skills, QA script, CI,
  contract, worktrees, review loop, sandbox) back to "the model you rent, the harness you build".

## Cut from the source material

- Fork, clone, and run of the session starters, plus the housekeeping steps
  `[S2/8]`, `[S3/14]`, `[S4/19]`, `[S5/25]`.
- News blocks (GPT-6 Astra demo, Jev sample).
- Bartholomew. Lissie the cat replaces him.
- The heise-derived design skill `[S2/13]`, replaced by `frontend-design` and impeccable.
- The A2UI project wizard `[S4/22]` and MCP Apps `[S4/23-24]`.
- `claude -p` and the Agent SDK `[S5/26-35]`, and the Claude security review in CI
  `[S5/37]`. Possible on the fly if time allows.
- pi everywhere (`[S2/8]`, `[S2/12]`, `[S5/31]`), the mitmproxy traffic demo, the
  dependency upgrade and the dark mode fix `[S2/9]`.
- Claude Code hooks: mentioned at the QA script, not built.
- The `grilling` skill. Planning before coding happens with the architecture article
  and plan mode.
- The provider switch `[MAF/02]` and the quality pass by delegation `[S2/12]`.
  Subagents still show up as a context firewall and in the background review.
- Quarto, PDF rendering, `_style/`. Plain Markdown only.

## Storybook format

The storybook is the presenter's guide, not a book to follow alone. Improvisation is
the plan.

- Per step: goal in one line, the prompt or script in a copyable block, a demo block
  with copyable commands, a few short bullets to discuss, one line for "if it breaks".
- No command-line arguments typed on stage. Everything that needs flags, ports, or
  JSON payloads sits in a copyable block.
- Time management is the presenter's job, not the storybook's. Don't cut or reorder
  content for time. Measure every prompt in the headless rehearsal and record the
  numbers: a timing table at the top (wall-clock duration, turns, and cost per prompt)
  and the same figures in one line under each prompt `[CS timing]`.
- A ports table and a short troubleshooting section at the end `[MAF]`.
