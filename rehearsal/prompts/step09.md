Add a QA script and CI that give agents (and humans) fast, deterministic feedback.

- scripts/qa.sh runs Biome, typecheck (all workspaces), production build, Vitest, and Playwright. One section per tool with PASS/FAIL; output of passing sections goes only to a log file, output of failing sections is printed; a summary at the end; non-zero exit code on failure. Write the output for agents: short, plain, no colors. Also available as `npm run qa`.
- Playwright must never collide with `npm run dev` or with another checkout of this repo running at the same time: its port, its Next.js dist dir, and its database file are overridable via environment variables. The database arrives in a later step; make DATABASE_URL a temp file in the e2e server's env now.
- AGENTS.md rule: run the QA script before you call a task done; fix the code instead of suppressing findings.
- Prove that it works: temporarily plant two typical mistakes (a lint error and a type error), run the script, check that both are caught with file and line, then revert them.
- A GitHub Actions workflow runs the same script on every push and pull request: Node 24, npm ci, cached Playwright browsers, generated dummy secrets in .env (never real ones). No deployment.
- Document the QA script and CI in tech-docs/testing.md.

Commit directly to main and push. Done when the QA script is green locally and the CI run of your push is green (watch it with gh).
