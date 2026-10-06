# ---------------------------------------------------------------------------
# gst - detailed git status: state, directory tree, +/- line counts, mtime
#
# Install:
#   mkdir -p ~/.config
#   mv ~/Downloads/gst-function.zsh ~/.config/gst-function.zsh
#   echo 'source ~/.config/gst-function.zsh' >> ~/.zshrc
#   exec zsh
# ---------------------------------------------------------------------------
unalias gs 2>/dev/null

gs() (
  emulate -L zsh
  setopt extended_glob pipe_fail

  zmodload -F zsh/stat b:zstat
  zmodload zsh/datetime

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    print -u2 "gst: not a git repository"; return 1
  }
  cd -- "$(git rev-parse --show-toplevel)" || return 1

  # ----- colors (auto-disabled when piped or when NO_COLOR is set) -----
  local c_rst c_bold c_dim c_red c_green c_yellow c_cyan c_mag
  if [[ -t 1 && -z ${NO_COLOR-} ]]; then
    c_rst=$'\e[0m' c_bold=$'\e[1m' c_dim=$'\e[90m'
    c_red=$'\e[31m' c_green=$'\e[32m' c_yellow=$'\e[33m' c_cyan=$'\e[36m' c_mag=$'\e[35m'
  fi
  local -A code_color=( M "$c_yellow" A "$c_green" D "$c_red" R "$c_cyan" T "$c_cyan" U "$c_red" '?' "$c_mag" )
  local -A code_rank=(  M 1           A 2          D 3        R 4         T 5         U 6        '?' 7 )

  # ----- comparison base -----
  local base=HEAD base_label=HEAD
  if ! git rev-parse -q --verify HEAD >/dev/null; then
    base=$(git hash-object -t tree /dev/null) base_label="empty tree"
  fi

  # ----- read status -----
  local -A st add del
  local -a paths
  local rec x y p code a d

  for rec in ${(0)"$(git status --porcelain=v1 -z --no-renames --untracked-files=all)"}; do
    x=${rec[1]} y=${rec[2]} p=${rec[4,-1]}
    if   [[ $x == '?' ]]; then code='?'
    elif [[ $x == ' ' ]]; then code=$y
    else                       code=$x
    fi
    st[$p]=$code
    paths+=("$p")
  done

  if (( ! $#paths )); then
    print -r -- "  ${c_dim}nothing to commit, working tree clean${c_rst}"
    return 0
  fi

  # ----- line counts: tracked files (staged + unstaged) -----
  for rec in ${(0)"$(git diff "$base" --numstat --no-renames -z)"}; do
    a=${rec%%$'\t'*}; rec=${rec#*$'\t'}
    d=${rec%%$'\t'*}; p=${rec#*$'\t'}
    add[$p]=$a del[$p]=$d
  done

  # ----- line counts: untracked files -----
  for p in $paths; do
    [[ ${st[$p]} == '?' ]] || continue
    rec=$(git diff --no-index --numstat -- /dev/null "$p" 2>/dev/null)
    [[ -n $rec ]] || continue
    a=${rec%%$'\t'*}; rec=${rec#*$'\t'}
    d=${rec%%$'\t'*}
    add[$p]=$a del[$p]=$d
  done

  # ----- helpers -----
  reltime() {
    local -a m
    REPLY=
    zstat -L -A m +mtime -- "$1" 2>/dev/null || return
    local s=$(( EPOCHSECONDS - m[1] ))
    if   (( s < 60 ));    then REPLY='just now'
    elif (( s < 3600 ));  then REPLY="$(( s / 60 ))m ago"
    elif (( s < 86400 )); then REPLY="$(( s / 3600 ))h ago"
    else                       REPLY="$(( s / 86400 ))d ago"
    fi
  }

  humansize() {   # $1 = byte count -> REPLY like "845B", "12.3K", "1.2M"
    local -F v=$1
    if   (( v < 1024 ));       then REPLY="${1}B"
    elif (( v < 1048576 ));    then REPLY=$(printf '%.1fK' $(( v / 1024 )))
    elif (( v < 1073741824 )); then REPLY=$(printf '%.1fM' $(( v / 1048576 )))
    else                            REPLY=$(printf '%.1fG' $(( v / 1073741824 )))
    fi
    REPLY=${REPLY/.0/}
  }

  filesize() {    # $1 = path -> REPLY = size in bytes in the worktree
    local -a m
    REPLY=0
    zstat -L -A m +size -- "$1" 2>/dev/null && REPLY=$m[1]
  }

  blobsize() {    # $1 = path -> REPLY = size in bytes in $base
    REPLY=$(git cat-file -s "$base:$1" 2>/dev/null)
    [[ -n $REPLY ]] || REPLY=0
  }

  numcolor() {
    case $1 in
      0) REPLY=$c_dim ;;
      *) REPLY=$2 ;;
    esac
  }

  local -a r_kind r_code r_label r_add r_del r_time
  local total_add=0 total_del=0 bin_add=0 bin_del=0

  add_file_row() {   # $1 = path, $2 = display label
    local fp=$1 fa fd newsz oldsz gap
    fa=${add[$fp]:-0} fd=${del[$fp]:-0}
    r_kind+=file; r_code+=("${st[$fp]}"); r_label+=("$2")

    if [[ $fa == '-' ]]; then
      # binary file: show the size delta instead of a line count
      filesize "$fp"; newsz=$REPLY
      blobsize "$fp"; oldsz=$REPLY
      gap=$(( newsz - oldsz ))
      if (( gap >= 0 )); then
        humansize $gap; r_add+="+$REPLY"; r_del+=0
        (( bin_add += gap ))
      else
        humansize $(( -gap )); r_add+=0; r_del+="-$REPLY"
        (( bin_del += -gap ))
      fi
    else
      r_add+=$( (( fa > 0 )) && print -r -- "+$fa" || print 0 )
      r_del+=$( (( fd > 0 )) && print -r -- "-$fd" || print 0 )
      (( total_add += fa, total_del += fd ))
    fi
    reltime "$fp"; r_time+=("$REPLY")
  }

  # ----- sort: group by status first, then by path -----
  local -a keyed sorted
  for p in $paths; do keyed+=("${code_rank[${st[$p]}]:-9}/$p"); done
  sorted=( ${(o)keyed} )
  sorted=( ${sorted#?/} )

  # ----- build the rows, grouping directories that hold 2 or more files -----
  local i=1 j k n dir
  n=$#sorted
  while (( i <= n )); do
    p=${sorted[i]}
    dir=${p:h}
    j=$i
    while (( j < n )) && [[ ${sorted[j+1]:h} == $dir ]]; do (( j++ )); done

    if [[ $dir != . ]] && (( j > i )); then
      r_kind+=dir; r_code+=''; r_label+=("$dir/"); r_add+=''; r_del+=''; r_time+=''
      for (( k = i; k <= j; k++ )); do
        if (( k < j )); then add_file_row "${sorted[k]}" "    ├── ${sorted[k]:t}"
        else                 add_file_row "${sorted[k]}" "    └── ${sorted[k]:t}"
        fi
      done
    else
      for (( k = i; k <= j; k++ )); do add_file_row "${sorted[k]}" "${sorted[k]}"; done
    fi
    i=$(( j + 1 ))
  done

  # ----- column widths -----
  local wl=0 wa=0 wd=0 s
  for s in $r_label; do (( $#s > wl )) && wl=$#s; done
  for s in $r_add;   do (( $#s > wa )) && wa=$#s; done
  for s in $r_del;   do (( $#s > wd )) && wd=$#s; done

  # ----- print the result -----
  local ca cd
  print
  for (( k = 1; k <= $#r_kind; k++ )); do
    if [[ ${r_kind[k]} == dir ]]; then
      print -r -- "    ${c_dim}${r_label[k]}${c_rst}"
      continue
    fi
    code=${r_code[k]}
    numcolor "${r_add[k]}" "$c_green"; ca=$REPLY
    numcolor "${r_del[k]}" "$c_red";   cd=$REPLY
    print -r -- " ${code_color[$code]:-$c_dim}${code}${c_rst}  ${c_bold}${(r:wl:)${r_label[k]}}${c_rst}  ${ca}${(l:wa:)${r_add[k]}}${c_rst}  ${cd}${(l:wd:)${r_del[k]}}${c_rst}  ${c_dim}${r_time[k]}${c_rst}"
  done

  local files_word=files summary ba bd
  (( n == 1 )) && files_word=file
  summary="    $n $files_word  ${c_green}+$total_add${c_rst}  ${c_red}-$total_del${c_rst}"
  if (( bin_add || bin_del )); then
    humansize $bin_add; ba=$REPLY
    humansize $bin_del; bd=$REPLY
    summary+="  ${c_cyan}+$ba${c_rst}"
    (( bin_del )) && summary+=" ${c_cyan}-$bd${c_rst}"
  fi
  print
  print -r -- "$summary  ${c_dim}against $base_label${c_rst}"
  print
)