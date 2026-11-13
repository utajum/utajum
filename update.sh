#!/usr/bin/env bash
# Run the profile action locally with your gh token (adds private stats), then commit and push.
# Needs: gh (logged in, repo scope), node 20+, git, curl, tar.
set -euo pipefail
cd "$(dirname "$0")"

# Same action version and time zone as the workflow
wf=.github/workflows/profile.yml
ref=$(grep -oP 'utajum/profile-readme-action@\K[0-9a-f]{40}' "$wf")
tz=$(grep -oP 'timezone:\s*\K\S+' "$wf")
token=$(gh auth token)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

git pull -q --rebase
curl -sfL "https://codeload.github.com/utajum/profile-readme-action/tar.gz/$ref" | tar -xz -C "$tmp" --strip-components=1
INPUT_TOKEN=$token INPUT_TIMEZONE=$tz GITHUB_REPOSITORY_OWNER=utajum node "$tmp/index.mjs"

git add README.md profile-3d-contrib profile
if git diff --staged --quiet; then
  echo "No changes"
else
  git commit -qm "Update profile stats with private repos"
fi
git push -q
echo "Done: $(git log --oneline -1)"
