Give Lissie tools for the signed-in user's todo list: listTodos, addTodo, setTodoDone, as one more adapter on the todo service (see tech-docs/architecture.md). Use your mastra skill for the current tools API.

- The user id comes from the server-side session through Mastra's request context, never from the model or the client.
- Persona: Lissie comments on every todo she adds and on every todo marked done, in character. Mark "feed the cat" as done and she has opinions.
- Next to the chat, a read-only sidebar with the open and done todos that refreshes when Lissie changes something. Lissie is the browser's write path for now.
- Render her tool calls in the chat so the user sees what she did: one readable line per call, not raw JSON. Tool calls survive the history replay after a restart.
- Tests: the tool executors on a temp database, with per-user isolation; the LLM e2e (its own npm script, outside QA and CI) asks Lissie to add "buy milk" and finds it in the sidebar.

Done when the QA script is green. Commit on the current branch, push, and open a pull request against main with a description a reviewer can use: what changed, how the user id reaches the tools, how to test it.
