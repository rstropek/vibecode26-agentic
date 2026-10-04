#!/usr/bin/env bash
# Rehearsal helper: log the todo-cat CLI in as the demo user without a browser
# (starts `todo-cat login`, approves the device code through Better Auth's API with a bearer token).
# Usage (from rehearsal/, dev server on :3000, XDG_CONFIG_HOME set): scripts/cli-login.sh
set -euo pipefail
B=${TODO_CAT_URL:-http://localhost:3000}
cd ../solution
OUT=$(mktemp)
npx todo-cat login --json > "$OUT" 2>&1 &
PID=$!
for _ in $(seq 1 30); do CODE=$(head -1 "$OUT" | jq -r '.userCode // empty' 2>/dev/null | tr -d '-'); [ -n "$CODE" ] && break; sleep 1; done
T=$(curl -s -X POST "$B/api/auth/sign-in/email" -H 'content-type: application/json' \
  -d '{"email":"demo@todo-cat.dev","password":"cat-person-2026"}' | jq -r .token)
curl -s "$B/api/auth/device?user_code=$CODE" -H "authorization: Bearer $T" > /dev/null
curl -s -X POST "$B/api/auth/device/approve" -H "authorization: Bearer $T" -H 'content-type: application/json' -d "{\"userCode\":\"$CODE\"}" > /dev/null
wait $PID
npx todo-cat whoami
