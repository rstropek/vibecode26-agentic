This is a fresh worktree: run npm install and npm run db:migrate first. Other agents work in sibling worktrees and the main checkout at the same time: Sindi runs on port 4111, and if you start the web app, use PORT=3103.

Sindi is the dog next door. She does errands that need a dog (fetch the ball, bark at the mailman, guard the porch). Build her as a separate, minimal Mastra app in sindi/: its own package, not a workspace of the web app, scaffolded with create-mastra non-interactively, @mastra/core pinned to 1.74.0 like the web app. Exactly one agent, `sindi`, on OpenRouter (the same OPENROUTER_API_KEY and OPENROUTER_MODEL as Lissie), served by `mastra dev` on port 4111. Mastra publishes her agent card at /api/.well-known/sindi/agent-card.json and her A2A endpoint at /api/a2a/sindi.

Lissie gets Sindi as a subagent through A2AAgent from @mastra/core/a2a (SINDI_URL in .env, default http://localhost:4111). Lissie's persona gets exactly one exception to "only your to-do list": errands for Sindi, which she delegates with some feline disdain. If Sindi is unreachable, Lissie says so in character. Sindi's app owns its own observability config; in the web app, change nothing beyond registering the subagent and the persona exception, because another agent is adding tracing to Lissie's Mastra setup right now.

Tests: Lissie's subagent wiring against a stubbed A2A server (no model calls), and the shape of Sindi's agent card. The QA script and CI never start Sindi or call a model. Write tech-docs/a2a.md: how to start Sindi and how to call her with curl.

Done when the QA script is green. Commit on this worktree's branch and push it. No pull request yet.
