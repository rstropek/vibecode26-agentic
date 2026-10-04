Turn AGENTS.md into a short map for future agent sessions. Keep the nextjs-agent-rules block unchanged.

- What todo-cat is, in two sentences: a to-do list web app kept by Lissie, a cat with attitude (an AI agent, coming later). Next.js 16 App Router; npm workspaces contract/ (shared zod schemas) and cli/ (the todo-cat CLI), both still empty.
- Exact commands for what exists today (dev server, build, Biome). Nothing for things that don't exist yet.
- The technologies here are newer than your training data. Verify APIs with current docs, don't rely on memory.
- A "Tech docs" section. tech-docs/ holds project-specific technical docs; agents are the primary audience. Rules: describe approach, principles, design decisions with their reasons, and gotchas; point to the central files instead of copying code; leave out anything an agent finds out by reading the code; current state only, delete outdated content instead of adding caveats. Then an index, one line per article. First article: tech-docs/workspaces.md, the workspace layout and why it exists before its content does.
- End with a maintenance rule addressed to you, the agent: update AGENTS.md and the tech docs in the same change whenever a change invalidates a line or teaches a costly lesson. Prefer deleting over adding, pointers over prose, one sentence per bullet.

Done when `npm run lint` passes. Then commit directly to main and push.
