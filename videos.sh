#!/bin/bash -eu
set -o pipefail

FILE=${FILE:-}
FILES_REPO=${FILES_REPO:-../files001.git}
FILES_SLUG=${FILES_SLUG:-$(basename "$FILES_REPO" .git)}
OUTPUT_DIR=${OUTPUT_DIR:-mp4}

echo FILE "$FILE"
echo FILES_REPO "$FILES_REPO"
echo FILES_SLUG "$FILES_SLUG"
echo OUTPUT_DIR "$OUTPUT_DIR"

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

    DOCKER_BUILDKIT=1 \
      docker build \
        --output="$tmp"/ \
        --target=video-gcc \
        --build-arg FILE="$url" \
        https://github.com/voidstarHQ/voidstar.git \
    || return 1

    mv "$tmp"/video.mp4 "$out"
}

if [[ -n "$FILE" ]]; then
    run "$FILE"
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
