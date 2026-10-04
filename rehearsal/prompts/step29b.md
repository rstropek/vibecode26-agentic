This is a fresh worktree: run npm install and npm run db:migrate first. Other agents work in sibling worktrees and the main checkout at the same time: if you start the web app, use PORT=3104.

Send Lissie's traces to the Aspire dashboard: @mastra/otel-exporter on Lissie's Mastra setup, with a custom OTLP endpoint over HTTP/protobuf (OTEL_EXPORTER_OTLP_ENDPOINT in .env, default http://localhost:4318) and service name todo-cat. Tracing is off when the variable is empty, so tests and CI export nothing. Use the mastra skill for the current observability API, and pin any new @mastra package to the version that matches @mastra/core 1.74.0. Add npm scripts that start and stop the dashboard in Docker (mcr.microsoft.com/dotnet/aspire-dashboard:13.5.2, UI on 18888, OTLP gRPC on 4317 and HTTP on 4318, anonymous access). Don't touch Lissie's agent definition, tools, or persona; another agent is wiring a subagent into her right now.

Verify it yourself: start the dashboard, run one chat turn against the real model, and check that the trace with the agent run and its model and tool spans arrived. Write tech-docs/observability.md.

Done when the QA script is green. Commit on this worktree's branch and push it. No pull request yet.
