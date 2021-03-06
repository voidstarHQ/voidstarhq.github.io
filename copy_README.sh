#!/bin/bash -eu
set -o pipefail

cat <<EOF
---
published: true
layout: default
---

<p align="center">
	<strong><code>voidstar</code></strong> projection of file <a href="https://github.com/voidstarHQ/files002/blob/main/0f0688bf17caac93008cf791f33fa063e42d150c66e24cbac617b1fd01ecd00a.pcapng"><code>files002/0f0688bf17caac93008cf791f33fa063e42d150c66e24cbac617b1fd01ecd00a.pcapng</code></a>
	<video preload=auto loop muted autoplay>
		<source src="./mp4/0f0688bf17caac93008cf791f33fa063e42d150c66e24cbac617b1fd01ecd00a.pcapng.mp4" type="video/mp4">
		Sorry, your browser does not support embedded videos.
	</video>
</p>
EOF

echo

curl -#fsSL https://raw.githubusercontent.com/voidstarHQ/voidstar/master/README.md \
| grep -vF '# `(void *)` · [voidstarhq.github.io](https://voidstarhq.github.io)' \
| grep -vF "Browse data using Conti's 2D projector as well as 3D variants." \
| sed 's%<!-- CONTI-IFRAME -->%<p align="center"><iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/XATakIdyZdk?start=1413" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></p>%' \
| sed 's%https://user-images.githubusercontent.com/278727/140719903-40c56818-0b5c-44ec-bbab-0e9b931c2023.mp4%<p align="center">\n  The actual file being represented below <a href="https://github.com/voidstarHQ/voidstar/blob/master/data/BigPictureBG.tga">is <code>data/BigPictureBG.tga</code></a> (<a href="https://vimeo.com/manage/videos/207613754">vimeo</a>)\n  <video preload=auto loop muted autoplay>\n    <source src="https://user-images.githubusercontent.com/278727/140719903-40c56818-0b5c-44ec-bbab-0e9b931c2023.mp4" type="video/mp4">\n      Sorry, your browser does not support embedded videos.\n  </video>\n</p>%' \
| grep -vF '[is data/BigPictureBG.tga]('

echo

cat <<EOF
## Gallery
Checkout the [mobile friendly gallery](./gallery/)!

Desktop-only gallery [here](./gallery-desktop/) (*might crash your phone*).
EOF

echo

cat <<EOF
## Files

[voidstarHQ/files001](https://github.com/voidstarHQ/files001)

[voidstarHQ/files002](https://github.com/voidstarHQ/files002)

EOF
