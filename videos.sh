#!/bin/bash -eu
set -o pipefail

FILES_REPO=${FILES_REPO:-../files001.git}
FILES_SLUG=${FILES_SLUG:-$(basename "$FILES_REPO" .git)}
OUTPUT_DIR=${OUTPUT_DIR:-mp4}

echo FILES_REPO "$FILES_REPO"
echo FILES_SLUG "$FILES_SLUG"
echo OUTPUT_DIR "$OUTPUT_DIR"

url=https://api.github.com/repos/VoidstarHQ/"$FILES_SLUG"/git/trees/main
echo url "$url"
errors=0
for file in $(curl -fsSL# "$url" \
      | jq -r '.tree[]|.path' \
      | sort -u \
      ); do

    echo file "$file"
    [[ "$file" =~ ^[0-9a-f]{64}. ]] || continue

    out="$OUTPUT_DIR"/"$file".mp4
    echo out "$out"
    [[ -f "$out" ]] && continue

    tmp=$(mktemp --directory --quiet)
    url=https://github.com/voidstarHQ/"$FILES_SLUG"/raw/main/"$file"
    echo url "$url"
    set +o errexit
    DOCKER_BUILDKIT=1 \
      docker build \
        --output="$tmp"/ \
        --target=video-gcc \
        --build-arg FILE="$url" \
        https://github.com/voidstarHQ/voidstar.git
    failed=$?
    set +o errexit
    if [[ $failed -ne 0 ]]; then
        ((errors++))
        continue
    fi

    mv "$tmp"/video.mp4 "$out"
done
exit "$errors"
