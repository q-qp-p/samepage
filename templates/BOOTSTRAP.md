# samepage bootstrap

You are the coding agent the user trusts most. Set up the *other* coding
agents on this machine so all of them share this project's context — no gap.

The shared layer already exists:

- `AGENTS.md` — single source of truth. `CLAUDE.md` and `GEMINI.md` are
  symlinks to it.
- `.samepage/skills/` — shared skills. `.claude/skills` links here.
- `.samepage/memory/MEMORY.md` — shared memory; protocol in `AGENTS.md`.

In order, talking to the user as you go:

1. **Ask** which agents they want (claude / codex / gemini / opencode / amp /
   goose / aider / other) and check what's already installed.
2. **Install** what's missing. Show each command, get a yes first. Unsure of
   the current method? Check the provider's docs, don't guess.
3. **Authenticate.** Logins belong to the user: print the exact command
   (`codex login`, `gemini`, `opencode auth login`, …) and wait for
   confirmation. Never touch credentials.
4. **Wire** each agent to the shared layer. Most read `AGENTS.md` natively;
   if one wants its own file, symlink that file to `AGENTS.md`. Link its
   skills directory to `.samepage/skills/` if supported. Link, never copy.
5. **Verify** — this is the point. Run each agent non-interactively
   (`claude -p`, `codex exec`, `gemini -p`) asking: "Per your project
   context, where is shared memory stored and what must you do before
   finishing a session?" Right answer: `.samepage/memory/MEMORY.md`, append
   durable facts. Can't answer → not wired. Fix and re-verify.
6. Inside tmux or cmux? Offer one pane per agent, in this directory.
7. Append the verified roster to `.samepage/memory/MEMORY.md`.

One agent at a time. Commands before running them. Finish with a one-screen
summary: installed, authenticated, wired, verified.
