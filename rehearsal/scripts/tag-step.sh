#!/usr/bin/env bash
# After a rehearsed step: check ../solution is clean on main, tag it, push code and tags,
# then commit the storybook + rehearsal files in this repo with the same tag and push.
# Usage (from rehearsal/): scripts/tag-step.sh <step-id> [message]
set -euo pipefail
ID=$1; MSG=${2:-"Step $1"}
TAG="step$ID"
cd ../solution
echo "solution: branch=$(git branch --show-current) head=$(git log --oneline -1)"
[ "$(git branch --show-current)" = main ] || { echo "not on main"; exit 1; }
[ -z "$(git status --porcelain)" ] || { git status --short; echo "solution not clean"; exit 1; }
git tag -f "$TAG"
if git remote get-url origin >/dev/null 2>&1; then git push -q origin main && git push -q -f origin "$TAG"; fi
cd ..
git add -A
git commit -q -m "$MSG" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" || echo "nothing to commit"
git tag -f "$TAG"
git push -q origin main && git push -q -f origin "$TAG"
echo "tagged and pushed $TAG"
