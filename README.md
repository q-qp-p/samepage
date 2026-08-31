# samepage

**Authenticate the one coding agent you trust. It sets up all the others — on
the same page, with no context gap.**

Running Claude Code, Codex, and Gemini CLI side by side is easy now (tmux,
[cmux](https://cmux.com), [claude-squad](https://github.com/smtg-ai/claude-squad)).
What's still annoying is that each agent has its own context file, its own
skills folder, its own memory — so what one agent learns, the others never
see. And setting up agents two through seven is the same tedious dance every
time.

samepage is a small fix for both:

1. **One shared layer per project.** `AGENTS.md` is the single source of
   truth; `CLAUDE.md`, `GEMINI.md`, etc. are symlinks to it. Skills live in
   `.samepage/skills/`, shared memory in `.samepage/memory/MEMORY.md`, and
   every agent's context file tells it to read memory at session start and
   append durable facts before finishing. No copies, no drift, no gap.
2. **One trusted agent bootstraps the rest.** You authenticate a single
   provider — whichever you trust — and `samepage bootstrap` hands it a short
   prompt. That agent then installs the other CLIs (asking first), walks you
   through each login, wires each one to the shared layer, and **verifies**
   each agent can actually answer questions from the shared context before
   calling it done. If you're in tmux or cmux, it offers to open one pane per
   agent.

## Quick start

```sh
git clone https://github.com/YOURNAME/samepage
ln -s "$PWD/samepage/bin/samepage" ~/.local/bin/samepage   # or anywhere on your PATH

cd your-project
samepage init         # create the shared layer, link the agent files to it
samepage bootstrap    # pick the provider you trust — it takes it from there
```

That's it. `samepage doctor` shows the state of the world at any time;
`samepage sync` re-creates the symlinks after a fresh clone.

## How it works

There are only three moving parts, all of them boring on purpose:

- **`templates/AGENTS.md`** — the shared-context contract. It includes "the
  samepage protocol": where memory lives, where skills live, and the rule
  that agents append durable facts before finishing a session. Ships with a
  `remember` skill that any skills-capable agent can use.
- **`bin/samepage`** — ~200 lines of dependency-free bash. It creates the
  layer, makes the symlinks for the common agents, and knows how to launch
  your chosen provider with the bootstrap prompt.
- **`templates/BOOTSTRAP.md`** — the prompt. This is the actual product.

### The adapter table is a prompt, not code

Tools that sync config across agents maintain a hardcoded table of every
agent's file format, and chase it as the tools change weekly. samepage keeps
the deterministic core tiny (symlinks for the big three) and delegates the
long tail to the model you already trust — at setup time, against the
providers' current docs, with a verification step so "wired up" is something
proven, not assumed. When a new agent CLI ships next month, nothing here
needs an update: your bootstrap agent reads its docs and wires it in.

## What it deliberately doesn't do

samepage is glue, not a platform. If you need more, these are good and
compose with it:

- [cmux](https://github.com/manaflow-ai/cmux) / [claude-squad](https://github.com/smtg-ai/claude-squad) /
  [amux](https://github.com/mixpeek/amux) — the panes, tabs, and worktrees.
  samepage runs happily inside any of them.
- [ruler](https://github.com/intellectronica/ruler) — maintained per-agent
  config distribution for ~17 agents. `samepage sync` detects it and points
  you at `ruler apply` for agents it doesn't link natively.
- [agentmemory](https://github.com/rohitg00/agentmemory) /
  [OpenViking](https://github.com/volcengine/OpenViking) — real shared-memory
  servers over MCP. samepage's markdown memory file is the zero-dependency
  version; graduate when you outgrow it.

## Caveats

- The install/auth hints in `samepage doctor` are best-effort snapshots; the
  bootstrap agent is told to verify against current provider docs rather than
  trust them.
- Symlinked context files assume the agent follows symlinks (the big three
  do). `samepage doctor` will tell you if a link got replaced by a real file.
- Shared memory is a plain markdown file with a protocol, not a database.
  That's a feature until it isn't; see the upgrade paths above.

## Commands

| command | what it does |
| --- | --- |
| `samepage init [dir]` | create `AGENTS.md`, `.samepage/{memory,skills}`, and the symlinks |
| `samepage bootstrap [provider]` | hand setup of all other agents to the one you trust |
| `samepage doctor` | which agents are installed, and is the shared layer intact |
| `samepage sync` | re-create the symlinks (after cloning, or adding agents) |

## License

MIT
