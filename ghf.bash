if [[ "${_GHF_SOURCE_DIR}" == "" ]]; then
  _GHF_SOURCE_DIR="$( cd "$( dirname "$0" )" && pwd )"
fi
source "${_GHF_SOURCE_DIR}/ghf-view-url.bash"
source "${_GHF_SOURCE_DIR}/bitly.bash"

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

  # Remove MR prefix for glab
  if [[ "$SUBCOMMAND" == "mr" ]]; then
    command echo "${CHOICE#\!}"
    return 0
  fi

  command echo "$CHOICE"
}

function _ghfFzfView() {
  local CHOICE="$( _ghfFzf "$@" )"
  if [[ $CHOICE == "" ]]; then
    echo "No $2 has chosen to view."
    return 1
  fi

  case "${_GH_FZF_VIEWER:-web}" in
    "web" ) # run e.g. gh issue view 1 --web
            "$1" "$2" view --web "$CHOICE";;
    "text" ) "$1" "$2" view "$CHOICE";;
    "id" ) echo "$CHOICE";;
    "url" ) echo "$( _ghf_view_url "$CHOICE" "$@" )";;
    "short_url" )
      local PATH_TOKEN="$( _bitly_path )"
      if [[ ! -f "$PATH_TOKEN" ]] || \
         [[ "$(command cat "$PATH_TOKEN" )" == "" ]]
      then
        bitly login
      fi
      echo "$( _ghf_view_url "$CHOICE" "$@" )";;
  esac
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
  local COMMAND="$(
    unalias "$1" &> /dev/null
    command -v "$1"
  )" # typically `gh`
  shift

  # stdin goes to original gh
  if [ -p /dev/stdin ]; then
    "$COMMAND" "$@" "$(command cat -)"
    return $?
  fi

  if [[ $# -gt 0 ]] && "$COMMAND" "$1" list --help &> /dev/null; then
    _ghfWrapper "$COMMAND" "$@"
    return $?
  fi

  "$COMMAND" "$@"
}

if command -v gh > /dev/null; then
  function ghf() {
    _ghf gh "$@"
  }
fi

if command -v glab > /dev/null; then
  function glabf() {
    _ghf glab "$@"
  }
fi
