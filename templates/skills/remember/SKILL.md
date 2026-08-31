---
name: remember
description: Save a durable fact to the shared cross-agent memory (.samepage/memory/MEMORY.md) so every other coding agent sees it. Use when the user says "remember this", or when a durable decision, gotcha, or convention emerges.
---

Append one line to the `## Log` section of `.samepage/memory/MEMORY.md`:

`- YYYY-MM-DD (your agent name) — the fact, in one sentence`

Rules:

- Durable facts only: decisions, constraints, gotchas, conventions. Not
  routine work — git history already records that.
- If the fact corrects an earlier line, edit that line instead of appending
  a contradiction.
- One sentence. If it needs a paragraph, it probably belongs in `AGENTS.md`
  instead — put it there and log one line pointing to it.
