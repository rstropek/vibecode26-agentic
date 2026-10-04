Use the skill-creator skill to write a project skill `todo-cat-cli` that teaches an agent to manage a person's to-do list with our CLI.

- Workflows and pitfalls, not a copy of --help: when to use it; the login prerequisite and what to tell the user when it's missing (never work around it); finding todos by title before acting on an id; `--json` plus jq for questions about the list; due dates versus creation dates ("last week"); destructive commands only when the user asks for them.
- `todo-cat --help` is the source of truth when the skill and the help disagree.
- Keep the evaluation light: two realistic requests run by a subagent with the skill and a shell, against the running dev server where the CLI is already logged in. No benchmark, no review viewer. Don't leave test todos behind.

Done when the QA script is green. Then commit directly to main and push.
