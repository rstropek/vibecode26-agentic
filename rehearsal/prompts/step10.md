Add persistence: Drizzle ORM on SQLite via @libsql/client, with DATABASE_URL from .env (already set to file:./data/app.db).

- One server-only module lib/db.ts exports the Drizzle instance; nothing else opens the database.
- Migrations with drizzle-kit: `npm run db:generate`, `npm run db:migrate`, and `npm run db:reset` (deletes the local database file and migrates a fresh one). No domain tables yet: todos arrive later together with the architecture, auth tables with authentication.
- A Vitest test migrates a temporary database file and proves the connection works. The e2e server gets its own migrated temp database.
- Drizzle's API has changed a lot. Start at https://orm.drizzle.team/llms.txt and follow the relevant links before coding.
- Add a "Researching docs" section to AGENTS.md: which source to use for what (vendor llms.txt files like Drizzle's, the docs in node_modules/next/dist/docs, the installed skills, the ctx7 CLI from the find-docs skill as the fallback for any other library).
- Write tech-docs/database.md.

Done when the QA script is green. Then commit directly to main and push.
