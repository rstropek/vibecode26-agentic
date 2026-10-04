A reviewer found the issues below in this branch. Check each one against the code; fix the ones that hold, say why for the ones that don't. Done when the QA script is green. Then commit on this branch and push.

The review covered `worktree-a2ui-card` (cce28ab against main), using the A2UI middleware and CopilotKit sources in `node_modules`. No CLAUDE.md exists for this repo, so the conventions angle found nothing. Findings are not verified (high effort, no verify pass), but the top two are traced in the middleware source.

```json
[
  {
    "file": "lib/lissie.ts",
    "line": 131,
    "summary": "Replay names the surface `a2ui-surface-<showProgress toolCallId>`, but the live A2UI middleware names it after `h ?? toolCallId`. With `a2uiToolNames: []`, `h` is the most recently *started* tool call, so live and replayed ids differ whenever showProgress runs in parallel with another tool.",
    "failure_scenario": "The model calls showProgress and listTodos in one step. The stream is START showProgress (h=S), START listTodos (h=L), then RESULT S. The middleware emits ACTIVITY_SNAPSHOT `a2ui-surface-L`, attached to listTodos's id. After a reload or restart, loadLissieHistory emits `a2ui-surface-S`, so the same card has two different ids. This breaks the 'same id live and replayed' invariant that tech-docs/agent.md and the route test rely on, and a chat that merges live and replayed messages can show the card twice."
  },
  {
    "file": "lib/lissie.ts",
    "line": 128,
    "summary": "Replay re-implements the middleware's tool-result to activity mapping in a narrower form. It uses the showProgress-specific schema to detect A2UI on any tool's result, and always emits one activity. `@ag-ui/a2ui-middleware` already exports `tryParseA2UIOperations` and the grouping and id logic (`createA2UIActivityEvents`) that this should reuse.",
    "failure_scenario": "A future card tool (the doc invites adding more) returns operations for two surfaceIds. Live, the middleware emits two activities, `a2ui-surface-<surfaceId>-<callId>` each. Replay emits one `a2ui-surface-<callId>` holding both, so the ids and the split differ after a reload. A double-encoded string result (which the middleware accepts) produces no surface at all on replay."
  },
  {
    "file": "app/lissie-tool-calls.tsx",
    "line": 173,
    "summary": "showProgress gets no tool-call renderer. CopilotKit returns null for it, so the chat shows nothing while the tool runs and nothing when it fails; the docs call the dev warning 'expected' instead of registering a renderer.",
    "failure_scenario": "The tool throws (no user in the request context, DB error) or returns something the middleware can't parse. No ACTIVITY_SNAPSHOT is emitted and, with no renderer, the user sees a blank gap with no '…' running line and no '✗ Couldn't …' line, unlike every other Lissie tool. Every dev session also logs the 'no renderer is registered' warning."
  },
  {
    "file": "lib/copilot-runtime.ts",
    "line": 123,
    "summary": "`a2uiToolNames: []` makes the middleware treat every ordinary tool start as the 'outer call' that later A2UI results attach to. That is the mechanism behind the id mismatch. The root-cause fix is to compute the replay id the same way, or keep A2UI results from attaching to unrelated calls, not to special-case `a2ui-surface-${toolCallId}`.",
    "failure_scenario": "Any multi-tool step where a non-A2UI tool starts after showProgress and before its result routes the surface to the wrong call id, so replay (which assumes the call's own id) diverges."
  },
  {
    "file": "lib/lissie-tools.ts",
    "line": 152,
    "summary": "showProgress loads every todo row for the user and filters in JS just to get three counts.",
    "failure_scenario": "A user with a long history (many done todos) makes every 'how am I doing?' read and serialize every row through listTodos. A COUNT / SUM(done) query in todo-service would return the same numbers with constant transfer."
  },
  {
    "file": "lib/lissie-tools.ts",
    "line": 155,
    "summary": "The whole A2UI payload (createSurface, the full component tree, the data model) is the tool result. That result goes to the model, is stored in Mastra memory, and is resent in the context of every later turn, though the model only needs three numbers.",
    "failure_scenario": "Each showProgress call adds several hundred tokens of component JSON to the thread permanently. After a few calls, every later prompt carries several copies of the identical tree, which raises cost and latency for no model benefit."
  },
  {
    "file": "lib/lissie-tools.ts",
    "line": 125,
    "summary": "`progressCardOperations` and `TodoProgress` are exported but used nowhere outside this file, and `placeholder()` is a one-use helper for a single template literal.",
    "failure_scenario": "Dead public surface and an extra indirection to maintain. Inline the operations in `execute`, drop the exports, and write the literal '${/open} still open' (escaped) directly."
  },
  {
    "file": "app/lissie-catalog.tsx",
    "line": 40,
    "summary": "ProgressBar trusts that `label` resolved to a string. If the binding or literal is missing, `aria-label` is undefined and the progressbar has no accessible name, and the visible label renders empty.",
    "failure_scenario": "A card whose label binds to a path absent from the data model (e.g. `{path: '/label'}` without that key) renders an unlabeled progressbar that screen readers announce only as 'progress bar, 0 of 0'."
  }
]
```
