Lissie moves in: a chat with her on /. Use your mastra and copilotkit skills; don't wire this from memory. Exact versions: @mastra/core 1.74.0, @mastra/memory 1.35.0, @mastra/libsql 1.25.0, @ag-ui/mastra 1.1.6, @ag-ui/client and @ag-ui/core 1.0.1, @copilotkit/react-core and @copilotkit/runtime 1.77.0.

- One Mastra agent `lissie` with a system prompt you write: Lissie is the user's cat and keeps their to-do list, with the attitude you'd expect from a cat (dry, superior, secretly caring). She declines everything that isn't about the list, in character. Her tools come in a later session.
- Model via OpenRouter: OPENROUTER_MODEL from .env, default z-ai/glm-5.3-flash. OPENROUTER_API_KEY stays server-only.
- Mastra memory in our SQLite file, scoped by the Better Auth user id from the server-side session: one thread per user, and conversations survive a restart.
- Serve her to CopilotKit over AG-UI. The chat lives on / (keep the header with sign-out, reuse components/ui/).
- Memory scoping is authorization, and so is the CopilotKit runtime: its endpoint rejects unauthenticated requests, and one user can't read, reconnect to, or stop another user's thread. Check every route the runtime serves, not only the one the browser calls, and write a test for each rule.
- A chat e2e that calls the model is fine, but it stays out of the QA script and CI (its own npm script).
- Write tech-docs/agent.md.

Done when the QA script is green. Then commit directly to main and push.
