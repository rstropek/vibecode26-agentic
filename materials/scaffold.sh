#!/usr/bin/env bash
# Step 4: scaffold todo-cat with generators only, no agent.
# Usage: scaffold.sh [directory]   (default: todo-cat; the OpenRouter key comes from $OPENROUTER_API_KEY if set)
set -euo pipefail
DIR=${1:-todo-cat}

# Next.js 16 with TypeScript, Tailwind, Biome, App Router; AGENTS.md from Next's agent rules
npx -y create-next-app@16.3.8 "$DIR" \
  --ts --tailwind --biome --app --no-src-dir --no-react-compiler \
  --import-alias "@/*" --use-npm --agents-md --disable-git --yes
cd "$DIR"
git init -q -b main
npm pkg set name=todo-cat
# Claude Code reads AGENTS.md natively; a CLAUDE.md next to it would replace it
rm CLAUDE.md

# npm workspaces root: shared zod contract and the CLI, declared now, filled later
mkdir -p contract cli
printf '{\n  "name": "@todo-cat/contract",\n  "version": "0.1.0",\n  "private": true\n}\n' > contract/package.json
printf '{\n  "name": "todo-cat-cli",\n  "version": "0.1.0",\n  "private": true\n}\n' > cli/package.json
npm pkg set 'workspaces[0]=contract' 'workspaces[1]=cli'
npm install --silent

# Local SQLite file lives in data/ (folder in git, content not)
mkdir -p data && printf '*\n!.gitignore\n' > data/.gitignore

# Secrets: .env stays local (create-next-app ignores .env*), .env.example documents it
cat > .env.example <<'EOF'
# SQLite file used by Drizzle, Better Auth and Mastra memory
DATABASE_URL=file:./data/app.db
# OpenRouter key for Lissie (Day 2)
OPENROUTER_API_KEY=sk-or-v1-...
# Better Auth: secret (openssl rand -base64 32) and the app's base URL
BETTER_AUTH_SECRET=change-me
BETTER_AUTH_URL=http://localhost:3000
EOF
sed -e "s|^OPENROUTER_API_KEY=.*|OPENROUTER_API_KEY=${OPENROUTER_API_KEY:-sk-or-v1-...}|" \
    -e "s|^BETTER_AUTH_SECRET=.*|BETTER_AUTH_SECRET=$(openssl rand -base64 32)|" .env.example > .env
printf '!.env.example\n' >> .gitignore

npm run lint --silent
git add -A
git commit -qm "Scaffold todo-cat (create-next-app, npm workspaces)"
git log --oneline
