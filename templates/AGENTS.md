# Project context

<!--
Describe the project: what it is, the stack, conventions, how to run and
test it. Every coding agent in this repo reads this file — directly, or via
a symlink like CLAUDE.md / GEMINI.md.
-->

## The samepage protocol (all agents)

One shared context layer. Nothing you learn or decide here is invisible to
the other agents.

- **Memory**: `.samepage/memory/MEMORY.md`. Read it at session start. Before
  finishing, append durable facts — decisions, gotchas, conventions — one
  dated line each. Not routine work; git history covers that.
- **Skills**: `.samepage/skills/` (one directory per skill, `SKILL.md`
  inside). Shared by every agent that supports skills.
- **One source of truth**: `CLAUDE.md`, `GEMINI.md`, etc. are symlinks here.
  Edit `AGENTS.md`; never replace a symlink with a copy.
