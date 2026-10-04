Make the app itself a remote MCP server: Streamable HTTP at /api/mcp with the same tools as `todo-cat mcp --stdio`, as one more thin adapter that calls the todo service directly, like the REST routes.

- Protect it with OAuth, with Better Auth as the authorization server. Better Auth 1.7 moved MCP auth into @better-auth/mcp: use it, @better-auth/oauth-provider and @better-auth/cimd at exactly 1.7.7, with Client ID Metadata Documents so a client like Claude Code needs no registration. The app needs the consent page. Better Auth's MCP support changed recently: work from https://better-auth.com/llms.txt, not from memory.
- The user id comes from the verified access token and from nothing else in the request. Another user's todo is "not found".
- Tool names, descriptions, annotations, and input schemas are shared with the stdio server, so the two can't drift.
- @modelcontextprotocol/server at exactly 2.3.0, current spec revision only (stateless).
- Tests: /api/mcp answers 401 with the WWW-Authenticate challenge without a token; the OAuth discovery documents are served; two users with valid access tokens each see and change only their own todos through the tools.
- Write tech-docs/mcp.md: both MCP servers, how they differ, how to connect Claude Code and the MCPJam CLI.

Done when the QA script is green. Commit on the current branch, push, and open a pull request against main.
