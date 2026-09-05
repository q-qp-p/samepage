<!-- samepage:start -->
This project uses **samepage**. Shared brain: `.samepage/`, at the main checkout, shared by every worktree of this repository.

At session start run `samepage` (add `--task "<what you are about to do>"` when you know it). It creates the brain if this repository has none, pings the other agent panes for a one-line status, and prints a digest of at most forty lines: who is open and what each is doing, the live memory rows, the last lessons, and OVERLAP when your task touches another pane's work. If OVERLAP names a pane, tell the user which files it touches and ask before editing them. Write your own note early with `samepage wip "<one line>"`, and durable lessons with `samepage remember`. Do not re-ask the user for anything the digest already says.
<!-- samepage:end -->
