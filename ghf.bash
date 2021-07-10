function _ghFzf() {
  subcommand="$1"
  shift
  command gh "$subcommand" list "$@" \
    | command fzf --preview "command echo {} \
                        | command grep -oE '^\S+' \
                        | command xargs gh '$subcommand' view" \
    | command grep -oE '^\S+'
}

function _ghFzfView() {
  command gh "$1" view --web "$( _ghFzf "$@" )"
}

function _ghWrapper() {
  if [[ "$2" == "fzf" ]]; then
    local subcommand="$1"
    shift 2
    _ghFzf "$subcommand" "$@"
  elif [[ "$2" == "--help" ]] || [[ "$2" =~ ^[^-] ]] ; then
    command gh "$@"
  else
    _ghFzfView "$@"
  fi
}

function ghf() {
  # stdin goes to original gh
  if [ -p /dev/stdin ]; then
    command gh "$@" "$(command cat -)"
    return $?
  fi

  local listable="gist\nissue\npr\nrelease\nrepo\nactions\nrun\nworkflow"
  if echo -e "$listable" | command grep -q "^${1}$"; then
    _ghWrapper "$@"
    return $?
  fi

  command gh "$@"
}