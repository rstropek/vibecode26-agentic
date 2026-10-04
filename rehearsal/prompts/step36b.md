main has moved: tracing and both MCP servers were merged. Rebase this branch onto origin/main and resolve the conflicts, keeping both sides' intent.

Then close the boundary you flagged: Sindi gets only the errand, never Lissie's conversation or the user's todos. Prove it with the stub A2A server: the message Sindi receives contains the errand and nothing from earlier turns. Sindi sends her traces to the same Aspire dashboard as Lissie (service name sindi, same OTEL_EXPORTER_OTLP_ENDPOINT); one trace across both apps only if it comes for free.

Done when the QA script is green. Then force-push this branch with lease and open a pull request against main.
