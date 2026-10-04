Use the frontend-design skill to give todo-cat its first real design: one deliberate aesthetic direction for a to-do list kept by a cat with attitude. Name the direction and its key choices (type, color, layout, one signature detail) before you build.

- A real todo list next to the chat, on the todo service: add (with an optional due date), check off, reopen, and delete with a confirmation. It replaces the read-only sidebar and still refreshes when Lissie changes something. Same adapter rules as everything else (tech-docs/architecture.md).
- The header, the auth pages, the device page, and the chat follow the same design, in light and dark mode, at desktop and phone width.
- Check the result yourself in screenshots of the running app before you commit.
- Tests: Playwright for add, check off, and delete on the list.
- Write tech-docs/ui.md: the direction, where tokens and shared components live, the CopilotKit styling gotchas.

Done when the QA script is green. Commit on the current branch, push, and open a pull request against main.
