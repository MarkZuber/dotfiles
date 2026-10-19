#!/usr/bin/env bash

# Sync dotfiles repo and ensure that dotfiles are linked correctly afterward

GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;30m'
NC='\033[0m'

# Navigate to the repo root, whatever the cwd. ($0's dirname is enough; readlink -f is a GNU
# flag that older macOS lacks.)
cd "$(dirname "$0")/.." || exit 1

branch="$(git rev-parse --abbrev-ref HEAD)"

echo -e "${BLUE}Stashing existing changes...${NC}"
stash_result=$(git stash push -m "sync-dotfiles: Before syncing dotfiles")
needs_pop=1
if [ "$stash_result" = "No local changes to save" ]; then
    needs_pop=0
fi

echo -e "${BLUE}Pulling updates from dotfiles repo (${branch})...${NC}"
echo
git pull --ff-only origin "$branch"
echo

if [[ $needs_pop -eq 1 ]]; then
    echo -e "${BLUE}Popping stashed changes...${NC}"
    echo
    git stash pop
fi

unmerged_files=$(git diff --name-only --diff-filter=U)
if [[ ! -z $unmerged_files ]]; then
   echo -e "${RED}The following files have merge conflicts after popping the stash:${NC}"
   echo
   printf %"s\n" $unmerged_files  # Ensure newlines are printed
else
   # Link new or repaired config into place.
   echo -e "${BLUE}Linking config into place...${NC}"
   scripts/link-dotfiles.sh
   echo -e "${GREEN}Done.${NC}"
fi
