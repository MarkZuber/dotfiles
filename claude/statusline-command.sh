#!/usr/bin/env bash
input=$(cat)

dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // empty')

# git branch (skip optional locks to avoid blocking)
branch=""
if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi

# context usage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# build left side: dir [branch]
left=""
left="${left}$(printf '\033[34m%s\033[0m' "$dir")"
if [ -n "$branch" ]; then
  left="${left} $(printf '\033[33m(%s)\033[0m' "$branch")"
fi

# build right side: model and context
right=""
if [ -n "$model" ]; then
  right="${right}$(printf '\033[36m%s\033[0m' "$model")"
fi
if [ -n "$used_pct" ]; then
  pct_int=$(printf '%.0f' "$used_pct")
  if [ -n "$right" ]; then
    right="${right} "
  fi
  right="${right}$(printf '\033[35mctx:%s%%\033[0m' "$pct_int")"
fi

if [ -n "$right" ]; then
  printf '%s  |  %s\n' "$left" "$right"
else
  printf '%s\n' "$left"
fi
