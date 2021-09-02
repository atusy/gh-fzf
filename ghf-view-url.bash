function _ghf_gh_view_url() {
  local URL=$( "$2" "$3" view "$1" --json url --jq .url )
  if [[ ${_GH_FZF_VIEWER} == "short_url" ]]; then
    local RESPONSE="$( curl --silent -i https://git.io -F "url=$URL" )"
    echo $RESPONSE \
      | command grep "Location:.*" \
      | command grep -oE "https://git\.io/.*"
  else
    echo $URL
  fi
}

function _ghf_glabf_view_url() {
  case "$3" in
    "issue" )
      local API="issues/$( echo "$1" | command grep -oE "[0-9]+" )";;
    "mr" )
      local API="merge_requests/$( echo "$1" | command grep -oE "[0-9]+" )";;
    "release" )
      local API="releases/$1";;
    * )
      echo "glabf cannot view url for '$1' of '$3'." 1>&2
      return 1
  esac
  local URL="$( 
    "$2" api -X GET "/projects/:id/${API}" \
      | command jq ".web_url" \
      | command sed -E -e 's/^\"|\"$//g' 
  )"
  if [[ ${_GH_FZF_VIEWER} == "short_url" ]]; then
    echo "$( bitly shorten "$URL" )"
  else
    echo "$URL"
  fi
}

function _ghf_view_url() {
  local CMD="$( echo "$2" | sed -E 's/.*\///' )"
  case "$CMD" in
    "gh" ) _ghf_gh_view_url "$@";;
    "glab" ) _ghf_glabf_view_url "$@";;
  esac
}

