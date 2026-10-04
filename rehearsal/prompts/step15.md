Add the todo-cat CLI in the cli/ workspace (package todo-cat-cli, binary `todo-cat`): a client of the REST API, built on commander.js 15. Its main users are AI agents working for a human; humans use it too.

- Commands: one per REST use case with short names (e.g. `todo-cat list`, `add`, `done`, `delete`), plus `login`, `logout`, `whoami`. Requests and responses use the contract schemas; nothing is re-declared.
- `login` uses Better Auth's device authorization flow, like `gh auth login`: print the code and the URL, never open a browser, poll until approved. The web app gets the page where a signed-in user approves the code. The token lives in a file with owner-only permissions in the user's config directory, never in the repo and never printed. `logout` also revokes the session on the server.
- Agent-friendly: `--json` output besides readable text, errors on stderr with the API's error code, meaningful exit codes (listed in --help), never prompts, `delete` requires `--yes`, --help with examples.
- The server URL defaults to http://localhost:3000, overridable with an environment variable. Runnable as `npx todo-cat` from the repo root after npm install.
- Tests: a Vitest integration test drives the built CLI end to end against a real server that the test starts on a spare port with a temp database and a redirected config directory: login (approve the device code through Better Auth's test utils, no browser), whoami, add, list, done, delete, logout, and whoami failing afterwards.
- Write tech-docs/cli.md. The QA script covers the cli workspace.

Done when the QA script is green. Then commit directly to main and push.
