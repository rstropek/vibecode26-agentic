Add the REST adapter from tech-docs/architecture.md: /api/todos for non-browser clients (a CLI comes next), covering every use case of the todo service.

- Write the 401 tests together with the endpoints: one per endpoint without a token and one with an invalid token.
- Integration tests call the route handlers on a temp database: one flow with a real bearer token that adds a todo, lists it, marks it done, filters, and deletes it; another user's todo id gives 404; invalid input gives 400 with the error code.
- Write tech-docs/rest-api.md: one line per endpoint (method, path, contract schemas, status codes) and how to get a bearer token with curl.

Done when the QA script is green. Then commit directly to main and push.
