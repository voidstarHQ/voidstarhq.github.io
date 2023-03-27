#!/bin/bash -eu
set -o pipefail

FILE=${FILE:-}
FILES_REPO=${FILES_REPO:-../files001.git}
FILES_SLUG=${FILES_SLUG:-$(basename "$FILES_REPO" .git)}
OUTPUT_DIR=${OUTPUT_DIR:-mp4}
VOIDSTAR_REPO=${VOIDSTAR_REPO:-https://github.com/voidstarHQ/voidstar.git}

echo FILE "$FILE"
echo FILES_REPO "$FILES_REPO"
echo FILES_SLUG "$FILES_SLUG"
echo OUTPUT_DIR "$OUTPUT_DIR"
echo VOIDSTAR_REPO "$VOIDSTAR_REPO"

run() {
    local file=$1; shift

    echo file "$file"
    [[ "$file" =~ ^[0-9a-f]{64}. ]] || return 2

    out="$OUTPUT_DIR"/"$file".mp4
    echo out "$out"
    [[ -f "$out" ]] && return 2

    tmp=$(mktemp --directory --quiet)
    url=https://github.com/voidstarHQ/"$FILES_SLUG"/raw/main/"$file"
    echo url "$url"

    args=()
    args+=(build)
    args+=(--output="$tmp"/)
    args+=(--target=video-gcc)
    args+=(--build-arg=FILE="$url")
    args+=(--build-arg=WxHxD=800x600x24)
    if [[ "$VOIDSTAR_REPO" =~ ^https: ]]; then
        args+=("$VOIDSTAR_REPO")
    else
        [[ -d "$VOIDSTAR_REPO" ]] || return 1
        args+=(-f "$VOIDSTAR_REPO"/Dockerfile)
        args+=("$VOIDSTAR_REPO")
    fi
    DOCKER_BUILDKIT=1 docker "${args[@]}" || return 1

    mv "$tmp"/video.mp4 "$out"
}

if [[ -n "$FILE" ]]; then
    run "$FILE"
    exit
fi

url=https://api.github.com/repos/VoidstarHQ/"$FILES_SLUG"/git/trees/main
echo url "$url"
errors=0
for file in $(curl -fsSL# "$url" \
      | jq -r '.tree[]|.path' \
      | sort -u \
      ); do

    set +o errexit
    run "$file"
    failed=$?
    set -o errexit

    case $failed in
        0) ;;
        1) ((errors++)) || true ;;
        2) continue ;;
    esac
done
exit "$errors"

# https://adw0rd.github.io/instagrapi/usage-guide/media.html
