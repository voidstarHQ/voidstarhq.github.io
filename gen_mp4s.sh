#!/bin/bash -eu
set -o pipefail

out=mp4s.json

url() {
	local mp4="$1"; shift
	echo "https://voidstarhq-mp4s.netlify.app/$mp4"
}

small_mp4s() {
	git ls-files mp4/
}

other_mp4s() {
	git ls-files --others mp4/
}


cat >"$out" <<EOF
{
EOF

cat >>"$out" <<EOF
	"small": [
EOF
max=$(small_mp4s | wc -l); i=0
for f in $(small_mp4s); do
	i=$((i+1))
	comma=','
	if [[ $i -eq $max ]]; then
		comma=''
	fi
	f="${f#mp4/}"
cat >>"$out" <<EOF
		"$(url "$f")"$comma
EOF
done
cat >>"$out" <<EOF
	],
EOF

cat >>"$out" <<EOF
	"larger": [
EOF
max=$(other_mp4s | wc -l); i=0
for f in $(other_mp4s); do
	i=$((i+1))
	comma=','
	if [[ $i -eq $max ]]; then
		comma=''
	fi
	f="${f#mp4/}"
cat >>"$out" <<EOF
		"$(url "$f")"$comma
EOF
done
cat >>"$out" <<EOF
	]
EOF

cat >>"$out" <<EOF
}
EOF

jq -S . <"$out" >"$out"~ && mv "$out"~ "$out"
