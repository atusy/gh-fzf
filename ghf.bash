function _ghfFzf() {
  local COMMAND="$1"
  local SUBCOMMAND="$2"
  shift 2

  # Try list candidates
  local STDERR="$( mktemp )"
  local CANDIDATES="$( "$COMMAND" "$SUBCOMMAND" list "$@" 2> "$STDERR" )"
  if [[ ! "$( command cat "$STDERR" )" == "" ]]; then
    "$COMMAND" "$SUBCOMMAND" list "$@"
    return $?
  fi

  # Choose one with fzf
  local CHOICE="$(
    set -o pipefail
    command echo "$CANDIDATES" \
      | command fzf --preview "command echo {} \
                                 | command grep -oE '^\S+' \
                                 | command xargs '$COMMAND' '$SUBCOMMAND' view" \
      | command grep -oE '^\S+'
  )"

  command echo "$CHOICE"
}

function _ghfFzfView() {
  local CHOICE="$( _ghfFzf "$@" )"
  if [[ $CHOICE == "" ]]; then
    echo "No $2 has chosen to view."
    return 1
  fi

  # run e.g. gh issue view 1 --web
  "$1" "$2" view --web "$CHOICE"
}

function _ghfWrapper() {
  local COMMAND="$1"
  shift
  if [[ "$2" == "fzf" ]]; then
    local SUBCOMMAND="$1"
    shift 2
    _ghfFzf "$COMMAND" "$SUBCOMMAND" "$@"
  elif [[ "$2" == "--help" ]] || [[ "$2" =~ ^[^-] ]] ; then
    "$COMMAND" "$@"
  else
    _ghfFzfView "$COMMAND" "$@"
  fi
}

function _ghf() {
  local COMMAND="$( command -vp "$1" )" # typically `gh`
  shift

  # stdin goes to original gh
  if [ -p /dev/stdin ]; then
    COMMAND "$@" "$(command cat -)"
    return $?
  fi

  if [[ $# -gt 0 ]] && "$COMMAND" "$1" list --help &> /dev/null; then
    _ghfWrapper "$COMMAND" "$@"
    return $?
  fi

  "$COMMAND" "$@"
}

if command -vp gh > /dev/null; then
  function ghf() {
    _ghf gh "$@"
  }
fi

if command -vp glab > /dev/null; then
  function glabf() {
    _ghf glab "$@"
  }
fi
