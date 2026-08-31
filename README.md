# samepage

**Coding with Claude Code, Codex, and Gemini side by side is easy now.**
--
**1.Authenticate the one coding agent you trust. 
2.It sets up all the others so they're 'on the same page'. 
3. shared context, memory, skills etc.**
 
--
## Overview
- **One shared layer per project.** `AGENTS.md` is the single source of
   truth; `CLAUDE.md`, `GEMINI.md`, … are symlinks to it. Skills live in
   `.samepage/skills/`, memory in `.samepage/memory/MEMORY.md`. Every agent
   reads memory at session start and appends durable facts before finishing.
   No copies, no drift.
   
- **One trusted agent bootstraps the rest.** `samepage bootstrap` hands
   your chosen agent a short prompt. It installs the other CLIs (asking
   first), walks you through each login, wires each to the shared layer, and
   verifies each can answer from it before calling it done. Inside tmux or
   [cmux](https://cmux.com), it offers one pane per agent.

## Requirements

- macOS or Linux (Windows via WSL). Any terminal; tmux/cmux optional.
- git.
- One coding-agent CLI, installed and authenticated. The rest come later.

## Quick start

```sh
git clone https://github.com/shreyasnivas/samepage
ln -s "$PWD/samepage/bin/samepage" ~/.local/bin/samepage

cd your-project
samepage init         # create the shared layer
samepage bootstrap    # pick your provider — it takes it from there
```

## Commands

| command | does |
| --- | --- |
| `samepage init [dir]` | create `AGENTS.md`, `.samepage/`, and the symlinks |
| `samepage bootstrap [provider]` | hand setup of the other agents to the one you trust |
| `samepage doctor` | what's installed, is the layer intact |
| `samepage sync` | re-create the symlinks after a fresh clone |

## The adapter table is a prompt, not code

Config-sync tools hardcode every agent's file format and chase changes
forever. samepage keeps the deterministic core tiny — symlinks for the big
three — and delegates the long tail to the model you trust, at setup time,
against current docs, with verification. A new agent CLI ships tomorrow?
Nothing here changes; your bootstrap agent reads its docs and wires it in.

The prompt is [`templates/BOOTSTRAP.md`](templates/BOOTSTRAP.md). That's the
product. The bash is plumbing.

## Glue, not a platform

- Panes and worktrees: [cmux](https://github.com/manaflow-ai/cmux),
  [claude-squad](https://github.com/smtg-ai/claude-squad),
  [amux](https://github.com/mixpeek/amux). samepage runs inside any of them.
- Maintained per-agent config sync:
  [ruler](https://github.com/intellectronica/ruler). `samepage sync` points
  you at it for agents it doesn't link natively.
- Real shared-memory servers:
  [agentmemory](https://github.com/rohitg00/agentmemory),
  [OpenViking](https://github.com/volcengine/OpenViking). Graduate when a
  markdown file isn't enough.

## Caveats

- Install/auth hints are snapshots; the bootstrap agent verifies against
  current provider docs instead of trusting them.
- Symlinked context assumes the agent follows symlinks (the big three do).
  `doctor` flags a link replaced by a real file.
- Memory is a markdown file with a protocol, not a database. A feature,
  until it isn't.

MIT
