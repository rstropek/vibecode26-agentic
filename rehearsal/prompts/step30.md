Turn the CLI into a local MCP server: `todo-cat mcp --stdio` runs a Model Context Protocol server over stdio with one tool per CLI command, sharing the code with the commands, so a new command becomes a tool without a second implementation.

- Use the official TypeScript SDK at exactly 2.3.0 (@modelcontextprotocol/server, and @modelcontextprotocol/client for tests). Research MCP with https://modelcontextprotocol.io/llms.txt and add it to "Researching docs" in AGENTS.md. Support the current spec revision; don't write extra code for older ones.
- Tool annotations take the place of --yes (read-only, destructive, idempotent); tool errors with the API's error code take the place of exit codes and stderr. Without a login the server still starts, and every tool call returns an error that tells the user to run `todo-cat login`. Nothing but protocol goes to stdout.
- Tool input schemas come from the contract.
- Tests: an MCP client spawns the built CLI over stdio against the same test server the CLI test uses: list the tools with their annotations, add, list, done, and an API error becoming a tool error.
- Update tech-docs/cli.md (including how to register the server in Claude Code) and the todo-cat-cli skill.

Done when the QA script is green. Commit on the current branch, push, and open a pull request against main.
