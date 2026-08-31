# samepage bootstrap

You are the coding agent the user trusts most. Your job is to set up the
*other* coding agents on this machine so that every one of them shares the
same project context — with no gap.

The shared layer already exists (created by `samepage init`):

- `AGENTS.md` — single source of truth for project context. `CLAUDE.md` and
  `GEMINI.md` are symlinks to it.
- `.samepage/skills/` — shared skills. `.claude/skills` is symlinked to it.
- `.samepage/memory/MEMORY.md` — shared memory log. The protocol all agents
  follow is described in `AGENTS.md`.

Do this, in order, talking to the user as you go:

1. **Ask** which other agents they want (claude / codex / gemini / opencode /
   amp / goose / aider / anything else) and check which are already installed.
2. **Install** the missing ones. Show each install command and get a yes
   before running it. If you're not sure of the current install method, check
   the provider's docs rather than guessing.
3. **Authenticate.** Logins are interactive and belong to the user. Print the
   exact command (`codex login`, `gemini`, `opencode auth login`, ...) for
   them to run, and wait for confirmation it worked. Never handle credentials
   yourself.
4. **Wire each agent to the shared layer.** Find out how each one discovers
   project context — most read `AGENTS.md` natively; if one wants its own
   file, symlink that file to `AGENTS.md`. Wire its skills directory to
   `.samepage/skills/` if it supports skills. Link, never copy: there must be
   exactly one source of truth.
5. **Verify — this is the point.** Run each agent non-interactively (e.g.
   `claude -p`, `codex exec`, `gemini -p`) with the question: "According to
   your project context, where is shared memory stored and what must you do
   before finishing a session?" The right answer names
   `.samepage/memory/MEMORY.md` and appending durable facts. An agent that
   can't answer isn't wired — fix it and re-verify.
6. If the user is inside tmux (or a pane-based terminal like cmux), offer to
   open one pane per agent, each in this directory.
7. Append the roster of what you set up and verified to
   `.samepage/memory/MEMORY.md`, so every agent knows who else is on the team.

Keep it snappy: one agent at a time, show commands before running them, and
finish with a one-screen summary of who's installed, authenticated, wired,
and verified.
