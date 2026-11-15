# codex-prune - delete Codex sessions whose rollout file has not been written
# to in more than N days (default 30). Codex has no built-in retention, and
# `mo clean` deliberately protects ~/.codex/sessions.
#
# Dry run by default; pass --yes to delete. Deletion goes through
# `codex delete --force <uuid>` rather than rm, so the state DB and
# session_index.jsonl stay consistent with the files on disk.
#
# The age check uses the rollout file mtime: Codex appends to the file on every
# turn, including after `codex resume`, so mtime is the last activity time.
codex-prune() {
  emulate -L zsh
  setopt extended_glob

  local days=30 apply=0
  while (( $# )); do
    case $1 in
      --yes) apply=1 ;;
      --days)
        [[ $2 == <-> ]] || { print -u2 "codex-prune: --days needs a whole number"; return 2 }
        days=$2; shift ;;
      -h|--help)
        print "usage: codex-prune [--days N] [--yes]"
        print "  Lists Codex sessions idle for more than N days (default 30)."
        print "  --yes  delete them via 'codex delete --force'"
        return 0 ;;
      *) print -u2 "codex-prune: unknown argument: $1"; return 2 ;;
    esac
    shift
  done

  (( $+commands[codex] )) || { print -u2 "codex-prune: codex not found in PATH"; return 1 }

  local sessions_dir=${CODEX_HOME:-$HOME/.codex}/sessions
  # m+N: modified more than N days ago, same semantics as find -mtime +N.
  # The trailing * also matches compressed rollouts (rollout-*.jsonl.zst).
  local -a files=( $sessions_dir/**/rollout-*.jsonl*(N.m+$days) )
  if (( ! $#files )); then
    print "No Codex sessions idle for more than $days days."
    return 0
  fi

  local uuid_re='[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
  local f
  for f in $files; do
    print -r -- "$(stat -f '%Sm' -t '%Y-%m-%d' $f)  $(du -h $f | cut -f1)	${f:t}"
  done
  local total=$(du -ch $files | tail -1 | cut -f1)
  print "\n$#files sessions idle for more than $days days, $total total."

  if (( ! apply )); then
    print "Dry run. Re-run with --yes to delete them."
    return 0
  fi

  local -i deleted=0 failed=0
  local id
  for f in $files; do
    if [[ ! ${f:t} =~ $uuid_re ]]; then
      print -u2 "skip (no session id in name): ${f:t}"
      (( failed++ )); continue
    fi
    id=$MATCH
    # A parent delete may already have removed this file.
    [[ -e $f ]] || { (( deleted++ )); continue }
    if codex delete --force $id >/dev/null; then
      (( deleted++ ))
    else
      print -u2 "failed: $id"
      (( failed++ ))
    fi
  done
  print "Deleted $deleted sessions, $failed failed."
  (( failed == 0 ))
}
