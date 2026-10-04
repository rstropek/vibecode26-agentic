Implement the todo core described in tech-docs/architecture.md: the todos table with its owner, the todo service, and the contract workspace with the zod schemas. No adapters yet; REST, CLI, and agent tools follow in later sessions.

- Tests: the service against a temp database, with per-user isolation for every use case.
- A dev seed, `npm run db:seed`: a demo user (demo@todo-cat.dev, password cat-person-2026) with about a dozen todos spread over the last two weeks, some done, some with due dates. Running it twice gives the same state.
- You may refine architecture.md (pointers, gotchas). If you need to deviate from its principles, ask first. Add it to the AGENTS.md index.

Done when the QA script is green. Then commit directly to main and push.
