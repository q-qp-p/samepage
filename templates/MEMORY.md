# Shared memory

Every agent reads this at session start and appends durable facts before
finishing. One line per fact, newest last:

`- YYYY-MM-DD (agent) — the fact, in one sentence`

Durable means: decisions, constraints, gotchas, conventions. Not routine work
— git history already records that. If a new fact corrects an old line, edit
the old line instead of appending a contradiction.

## Log
