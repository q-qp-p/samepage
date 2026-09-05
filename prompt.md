# Paste this into the coding agent you already trust

You are inside cmux, in the project I care about. You are the lead. Set up a shared brain so every other coding pane (Claude Code, Codex, Grok, Gemini, OpenCode, whatever is on PATH) reads the same project context, skills, and memory.

Do this:

1. If `samepage` is not on PATH, install it from the repo that contains `tools/samepage` (`./install.sh`) or run it via `tools/samepage/bin/samepage`.
2. Run `samepage doctor`. Tell me only what is missing. Help me authenticate any extra provider I ask for; do not nag me to switch away from you.
3. Run `samepage`. That is the whole tool: it creates the brain if this repository has none, pings every agent pane I already have open on this project for a one-line status, and prints a short digest of who is open, what each is doing, the live memory rows and the last lessons. Those panes started before the brain existed and cannot see it on their own, which is why the ping is the part that matters. Tell me how many it reached and what the digest says. It pings a pane at most once in ten minutes, and only when that pane's note has gone stale, so it is safe to run as often as you like.
4. Run `samepage sync` so every other pane reaches the same MCP servers you do. Your own config is the declaration; it writes environment-variable references outward and never a key. Show me the report it prints.
5. Then stop.

Rules after that: `samepage` at session start, with `--task "<what you are about to do>"` when you know it. Read the digest, and if OVERLAP names another pane, tell me which files it touches and ask me before editing them. Write `samepage wip "<one line>"` EARLY and keep it updated, because a session that dies saves nothing. `samepage remember` for durable lessons, `samepage spawn` / `handoff` instead of raw cmux splits, `samepage sync` whenever I add an MCP server or rotate a key. The other verbs are internals you should not need to type. Follow `.samepage/PROTOCOL.md`. Do not copy that protocol into CLAUDE.md. Do not ask me to re-explain anything the digest already says. Never paste one of my keys into another tool's config file.
