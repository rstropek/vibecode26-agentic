#!/usr/bin/env bash
# Step 7: install skills (project scope) for Claude Code. Run in the repo root.
set -euo pipefail
A=(--agent claude-code -y)

# Tech: current docs for any library (ctx7 CLI), the vendors' own playbooks for Mastra and CopilotKit
npx -y skills@1.7.0 add upstash/context7 --skill find-docs "${A[@]}"
npx -y skills@1.7.0 add mastra-ai/skills --skill mastra "${A[@]}"
npx -y skills@1.7.0 add CopilotKit/CopilotKit --skill copilotkit "${A[@]}"

# Meta (write your own skills) and design (taste for UI work)
npx -y skills@1.7.0 add anthropics/skills --skill skill-creator --skill frontend-design "${A[@]}"

# impeccable: design commands (init, critique, polish, ...). No hooks: we enforce quality with the QA script.
npx -y impeccable@4.1.0 install --project --providers=claude --no-hooks --yes
# its engine binary is platform-specific (18 MB); the launcher downloads it on first use
printf '\n# impeccable engine binary (platform-specific, downloaded on first use)\n.claude/skills/impeccable/scripts/bin/\n' >> .gitignore

# Skills are vendored code: Biome must not lint or reformat them
node -e 'const fs=require("fs");const j=JSON.parse(fs.readFileSync("biome.json","utf8"));j.files.includes.push("!.claude","!.agents");fs.writeFileSync("biome.json",JSON.stringify(j,null,2)+"\n")'
npx biome format --write biome.json > /dev/null
npm run lint --silent

git add -A
git commit -qm "Install skills"
git push -q
ls .claude/skills
