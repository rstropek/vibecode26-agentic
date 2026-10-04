Set up our test harness, before any feature exists: Vitest for unit and integration tests (`npm test`) and Playwright for end-to-end tests (`npm run test:e2e`, Chromium only, starting its own dev server on a spare port). This Next.js version may differ from what you know, so read its testing guides in node_modules/next/dist/docs/ first. Add one real smoke test for each. Write tech-docs/testing.md (strategy, commands, gotchas) and add it to the AGENTS.md index.

Done when `npm test`, `npm run test:e2e`, and `npm run lint` pass. Then commit directly to main and push.
