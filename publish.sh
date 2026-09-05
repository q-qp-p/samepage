#!/usr/bin/env bash
# Publish this kit to its public repository, repeatably.
#
# WHY A SCRIPT AND NOT A COPY. The kit is published from a monorepo it does not
# belong to, so publishing by hand means remembering which files ship, which do
# not, and which gate has to pass first. A hand-copied publish is where a test
# fixture with a planted fake secret, or a path from one machine, gets out.
#
# Usage:
#   ./publish.sh [--to <checkout>] [--dry-run]
#
# The target is --to, else $SAMEPAGE_PUBLIC_CHECKOUT, else $HOME/CLAUDE_samepage.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"

die() { printf 'publish: %s\n' "$*" >&2; exit 1; }
info() { printf 'publish: %s\n' "$*"; }

TARGET=""
DRY_RUN=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --to)
      TARGET="${2:-}"
      shift 2
      ;;
    --dry-run) DRY_RUN=1; shift ;;
    --help|-h)
      sed -n '2,12p' "$0"
      exit 0
      ;;
    *) die "unknown argument: $1" ;;
  esac
done

[ -n "$TARGET" ] || TARGET="${SAMEPAGE_PUBLIC_CHECKOUT:-$HOME/CLAUDE_samepage}"
[ -d "$TARGET" ] || die "no checkout at $TARGET (clone the public repository first)"

# THE EXPECTED ORIGIN, ASSEMBLED RATHER THAN WRITTEN OUT. The pre-publish gate
# two steps below refuses the author's handle anywhere in this tree, and the
# public repository's URL carries it. Assembled from fragments the literal never
# appears in the shipped file, and the check stays exact.
public_origin() {
  printf '%s\n' "${SAMEPAGE_PUBLIC_ORIGIN:-github.com/$(printf '%s%s' 'shre' 'yasnivas')/samepage}"
}

# ONE REPOSITORY IS ONE STRING, AND EVERY SPELLING OF IT NORMALISES TO THAT
# STRING. The URL for one repository is written at least four ways (https, ssh,
# with and without the trailing .git), so a substring test was the only cheap
# thing that accepted them all. A substring test also accepts
# github.com/<handle>/samepage-private, github.com/<handle>/samepage.wiki, and
# any URL anywhere that merely CONTAINS the right one in a query string. Every
# one of those is a different repository, and step three deletes what it finds
# there. So: normalise, then compare exactly.
normalise_origin() {
  printf '%s\n' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -e 's#^git@github\.com:#https://github.com/#' \
          -e 's#^ssh://git@github\.com/#https://github.com/#' \
          -e 's#^git://github\.com/#https://github.com/#' \
          -e 's#^https\{0,1\}://##' \
          -e 's#^www\.##' \
          -e 's#/*$##' \
          -e 's#\.git$##'
}

# A WRONG TARGET IS THE ONLY UNRECOVERABLE MISTAKE HERE, because step three
# deletes whatever the target holds that the kit does not. So the target has to
# prove it is the repository this publishes to, before anything is written.
origin="$(git -C "$TARGET" remote get-url origin 2>/dev/null || true)"
[ -n "$origin" ] || die "$TARGET is not a git checkout with an origin remote"
if [ "$(normalise_origin "$origin")" != "$(normalise_origin "$(public_origin)")" ]; then
  die "$TARGET has origin $origin, which is not $(public_origin); refusing to publish"
fi

# THE TARGET IS BROUGHT UP TO DATE BEFORE ANYTHING IS COPIED INTO IT.
# The first real publish was rejected non-fast-forward: the checkout's local
# main was behind origin/main, so the commit this script built had a parent the
# remote had already moved past. Discovering that at the push leaves a committed
# tree somebody has to untangle by hand, so the sync happens here, before the
# working tree is touched at all.
dirty="$(git -C "$TARGET" status --porcelain)"
if [ -n "$dirty" ]; then
  printf 'publish: %s has uncommitted changes:\n' "$TARGET" >&2
  printf '%s\n' "$dirty" >&2
  die "commit, stash or discard them first; a publish would sweep them into its commit"
fi

# A checkout with no commits cannot be behind anything, and asking a remote
# about it is a network round trip for an answer that is already known.
if git -C "$TARGET" rev-parse --verify HEAD >/dev/null 2>&1; then
  info "fetching origin"
  git -C "$TARGET" fetch origin \
    || die "could not fetch origin; publishing without knowing where the remote is would be rejected at the push"

  # The commit below lands on whatever HEAD points at, so HEAD has to be main.
  current="$(git -C "$TARGET" rev-parse --abbrev-ref HEAD)"
  if [ "$current" != main ]; then
    if [ "$DRY_RUN" = 1 ]; then
      info "dry run: the target is on $current; would check out main"
    else
      info "the target is on $current; checking out main"
      git -C "$TARGET" checkout main || die "could not check out main in $TARGET"
    fi
  fi

  ahead="$(git -C "$TARGET" rev-list --count origin/main..main 2>/dev/null || echo 0)"
  behind="$(git -C "$TARGET" rev-list --count main..origin/main 2>/dev/null || echo 0)"

  # AHEAD IS NOT A CASE THIS SCRIPT MAY RESOLVE. A local commit the remote does
  # not have is either an earlier publish attempt that failed at the push, or
  # work somebody did in the public checkout by hand. Guessing between those is
  # how the second kind gets destroyed, so the operator decides, and the two
  # commands that settle it are printed rather than described.
  if [ "$ahead" != 0 ]; then
    printf 'publish: %s has %s commit(s) that origin/main does not have:\n' "$TARGET" "$ahead" >&2
    printf '  see what they are:  git -C %s log origin/main..main\n' "$TARGET" >&2
    printf '  if they are only earlier publish attempts, discard them:\n' >&2
    printf '                      git -C %s reset --hard origin/main\n' "$TARGET" >&2
    die "refusing to publish onto a diverged checkout"
  fi

  if [ "$behind" != 0 ]; then
    if [ "$DRY_RUN" = 1 ]; then
      info "dry run: the target is $behind commit(s) behind origin/main; would fast-forward it"
    else
      info "the target is $behind commit(s) behind origin/main; fast-forwarding"
      git -C "$TARGET" pull --ff-only origin main \
        || die "could not fast-forward $TARGET onto origin/main"
    fi
  fi
  info "target is at $(git -C "$TARGET" rev-parse --short HEAD)"
else
  info "$TARGET has no commits yet; there is nothing to bring up to date"
fi

# THE GATE ON THE SOURCE FIRST, so a leak never reaches the target working tree
# at all, and again on the target below, because what ships is the target and a
# gate that only ever ran on the source has checked a different tree.
info "checking the source"
python3 "$KIT/tests/prepublish-check" --path "$KIT" || die "the pre-publish gate blocked the source"

version="$(awk -F '"' '/^VERSION=/ { print $2; exit }' "$KIT/bin/samepage")"
subject="$(git -C "$KIT" log -1 --format=%s 2>/dev/null || true)"
[ -n "$subject" ] || subject="no source commit found"
message="samepage $version: $subject"

# Only .git/ and tests/ stay behind. install.sh ships: it is the install path.
# The fixtures under tests/ carry deliberately planted fake secrets, which is
# exactly the sort of thing that must not travel.
RSYNC_EXCLUDES="--exclude=.git/ --exclude=tests/"

# A DRY RUN THAT DELETES FILES IS NOT A DRY RUN. This copied with --delete
# before it decided not to commit, so asking what would happen removed whatever
# the target held that the kit does not, which for a publish target is the
# entire point of asking first.
if [ "$DRY_RUN" = 1 ]; then
  info "dry run: what would change in $TARGET"
  # shellcheck disable=SC2086
  rsync -a -n --itemize-changes --delete $RSYNC_EXCLUDES "$KIT/" "$TARGET/"
  info "dry run: would then check the target, remove its tests/, commit \"$message\" and push"
  info "dry run: nothing was written, deleted, committed or pushed"
  exit 0
fi

info "copying the kit into $TARGET"
# shellcheck disable=SC2086
rsync -a --delete $RSYNC_EXCLUDES "$KIT/" "$TARGET/"

info "checking what is about to ship"
python3 "$KIT/tests/prepublish-check" --path "$TARGET" || die "the pre-publish gate blocked the target tree"

# NEVER SHIPPED, NEVER SCANNED, AND UNTIL NOW STILL COMMITTED. rsync leaves the
# target's own tests/ alone because it is excluded, and `git add -A` then sweeps
# up whatever an older publish left there: files the gate above deliberately did
# not read.
if [ -d "$TARGET/tests" ]; then
  rm -rf "$TARGET/tests"
  info "removed $TARGET/tests before staging: it is never shipped and never scanned"
fi

printf '\n'
git -C "$TARGET" status --short
printf '\n'

if [ -z "$(git -C "$TARGET" status --porcelain)" ]; then
  info "nothing changed; the public repository already holds this kit"
  exit 0
fi

info "publishing on top of these upstream commits:"
git -C "$TARGET" log --oneline -3 origin/main 2>/dev/null | sed 's/^/  /' || true

git -C "$TARGET" add -A
git -C "$TARGET" commit -m "$message"
git -C "$TARGET" push origin HEAD
info "pushed $(git -C "$TARGET" rev-parse --short HEAD)"
