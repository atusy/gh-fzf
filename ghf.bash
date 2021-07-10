function _ghFzf() {
  subcommand="$1"
  shift
  local choice="$(
    set -o pipefail
    command gh "$subcommand" list "$@" \
      | command fzf --preview "command echo {} \
                                 | command grep -oE '^\S+' \
                                 | command xargs gh '$subcommand' view" \
      | command grep -oE '^\S+'
  )"
  command echo "$choice"
}

function _ghFzfView() {
  local choice="$( _ghFzf "$@" )"
  if [[ $choice == "" ]]; then
    echo "No $1 has chosen to view."
    return 1
  fi
  command gh "$1" view --web "$choice"
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
  
