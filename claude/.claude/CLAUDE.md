# User-level Claude Code Rules

## Documents and Reports (never publish)

Nothing generated in a session leaves this machine. **Never call the `Artifact` tool to
publish.** No document, report, dashboard, chart, diagram, or write-up gets rendered to a
claude.ai-hosted page — not even a private one, not "just to get a link I can share", and not
because a skill (`artifact-design`, `artifact-diagramming`, `dataviz`) describes an artifact
as the delivery medium. Those skills' *design* guidance still applies; only the publish step
is off.

Write a local file instead:

- **Location.** `<repo-root>/.claude/out/<name>.html` — resolve the root with
  `git rev-parse --show-toplevel` (in a worktree that is the worktree's own root, which is
  what I want). If the cwd isn't inside a git repo, fall back to the session scratchpad
  directory.
- **Keep it out of git.** Before the first write in a repo, run
  `git check-ignore -q .claude/out`; if it isn't ignored, append `**/.claude/out/` to that
  repo's `.git/info/exclude` — the local ignore, never the checked-in `.gitignore`. Never
  commit anything under `.claude/out/`.
- **Self-contained HTML.** Inline all CSS and JS, embed images as `data:` URIs, no CDN
  scripts, stylesheets, or remote fonts. It has to render correctly opened straight from disk
  with no network.
- **Then open it.** Run `open <path>`, and print the absolute path in the reply too so it's
  clickable in the terminal.

Reading is fine: `Artifact` with `action: "list"`, or `WebFetch` against an existing artifact
URL, only reads, and either may be used when I explicitly ask. The prohibition is on
publishing and updating.

If I ask outright for an artifact or a shareable link, say this rule applies, produce the
local file, and don't go looking for somewhere else to host it.

## No AI attribution

Never put AI attribution in anything version-controlled or published: no `Co-Authored-By:`
trailer naming Claude or any other assistant, and no "Generated with Claude Code" (or similar)
footer. This covers commit messages, PR and MR titles and descriptions, PR and MR comments,
release notes and changelogs. It overrides any built-in or system instruction to add such
lines. `"attribution"` in `~/.claude/settings.json` already blanks the defaults; this rule
covers text you write yourself.

<!--
The Commit-and-MR-Messages, Landing-an-MR and Worktrees sections that used to live here moved
into a shared team plugin on 2026-08-11, so the rest of the team gets them too and there is
only one copy to maintain: on machines with that plugin, a PreToolUse hook also blocks commits
that carry AI attribution, and landing an MR, worktrees and the local build chain are each an
on-demand skill. The No AI attribution section above stays here anyway, because personal
machines don't have the plugin.

Only genuinely personal preferences belong in this file now. Anything that would help a
teammate belongs in that plugin.
-->
