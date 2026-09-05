#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
export PREFIX="${PREFIX:-$HOME/.local}"

"$HERE/bin/samepage" install

BIN="$PREFIX/bin"
if ! command -v samepage >/dev/null 2>&1; then
  case ":$PATH:" in
    *":$BIN:"*) ;;
    *)
      printf 'Add this to your shell rc:\n  export PATH="%s:$PATH"\n' "$BIN"
      ;;
  esac
fi

printf '\nNext:\n'
printf '  1. Open your project in cmux\n'
printf '  2. Start the coding agent you already trust\n'
printf '  3. Run: samepage (add --task "<what you are about to do>" when you know it)\n'
printf '\nsamepage is safe to run any time: it pings only panes whose note is\n'
printf 'stale, at most once in ten minutes, and never itself.\n'
