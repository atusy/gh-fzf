function _bitly_path() {
  echo "${HOME}/.config/gf-fzf/bitly"
}

function _bitly_login() {
  case "$1" in
    "--stdin" ) local TOKEN="$( command cat - )";;
    "--token" ) local TOKEN="$3";;
    "-t" ) local TOKEN="$3";;
    "" )
      echo "Input bitly API token:" 
      read TOKEN;;
  esac
  local PATH_TOKEN="$( _bitly_path )"
  mkdir -p "$( dirname "$PATH_TOKEN" )"
  echo "$TOKEN" > "$PATH_TOKEN"
}

function _bitly_logout() {
  local PATH_TOKEN="$( _bitly_path )"
  mkdir -p "$( dirname "$PATH_TOKEN" )"
  echo "" > "$PATH_TOKEN"
}

function _bitly_token() {
  command cat "$( _bitly_path )"
}

function _bitly_shorten() {
  local URL="$1"
  local TOKEN="$( _bitly_token )"
  command curl \
    --silent \
    -H "Authorization: Bearer ${TOKEN}" \
    -H 'Content-Type: application/json' \
    -X POST \
    -d "{\"long_url\": \"${URL}\"}" \
    https://api-ssl.bitly.com/v4/shorten \
    | command jq .link | command sed -e 's/"//g'
}

function bitly() {
  local CMD="$1"
  shift 1
  case "$CMD" in
    login ) _bitly_login "$@";; 
    logout ) _bitly_logout "$@";;
    token ) _bitly_token "$@";;
    shorten ) _bitly_shorten "$@";;
  esac
}

