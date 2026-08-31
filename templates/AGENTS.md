# Project context

<!--
Describe the project here: what it is, the stack, conventions, how to run
and test it. Every coding agent working in this repo reads this file —
directly, or via a symlink like CLAUDE.md / GEMINI.md.
-->

## The samepage protocol (all agents)

This project uses samepage: one shared context layer for every coding agent,
so nothing you learn or decide here is invisible to the others.

- **Memory** lives in `.samepage/memory/MEMORY.md`. Read it at the start of a
  session. Before you finish, append any durable fact — a decision made, a
  gotcha found, a convention agreed — as a one-line dated bullet. Don't log
  routine work; git history covers that.
- **Skills** live in `.samepage/skills/` (one directory per skill, with a
  `SKILL.md` inside). They're shared: a skill added there is available to
  every agent that supports skills.
- **One source of truth.** `CLAUDE.md`, `GEMINI.md`, and friends are symlinks
  to this file. Always edit `AGENTS.md`; never break a symlink by replacing
  it with a copy.
