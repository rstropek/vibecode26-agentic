Add authentication with Better Auth, email and password only. Use better-auth and @better-auth/drizzle-adapter at exactly 1.7.7.

- Drizzle adapter on lib/db.ts. Generate the auth schema with Better Auth's CLI and apply it through our migration flow (secret and URL are already in .env).
- Enable now the plugins this afternoon needs: bearer (the REST API and the CLI will send `Authorization: Bearer <token>`) and device authorization (the CLI will log in like `gh auth login`). Their pages and clients come later.
- One server-side helper that maps a request to the signed-in user's id (session cookie or bearer token), or null. Every adapter we add later (REST, agent tools, MCP) uses it; nothing else reads sessions.
- /signup and /login pages with Tailwind. Shared form styling lives in components/ui/, no repeated class strings. / requires a session, checked server-side, and shows the user's name and a sign-out button.
- Tests: Vitest integration tests with Better Auth's test-utils plugin on a temp database (sign-up works, the right password signs in, a wrong one is rejected, the helper returns the user id for a cookie and for a bearer token and null without either), plus one Playwright e2e of the real sign-up, sign-out, and sign-in flow.
- Better Auth is newer than your training data. Start at https://better-auth.com/llms.txt and follow its Next.js, Drizzle adapter, email and password, bearer, device authorization, and test-utils pages.
- Write tech-docs/auth.md.

Done when the QA script is green. Then commit directly to main and push.
