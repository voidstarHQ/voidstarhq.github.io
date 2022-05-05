#!/bin/bash -eu
set -o pipefail

find mp4/ -type f -size -2M -o -size 2M  | while read -r f; do git add "$f"; done

cat <<EOF
<!DOCTYPE html>
<html lang="en" data-layout="responsive">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>anything can be numbers, numbers can be anything... What does data look like, in color and in 3D.</title>
        <style type="text/css">
            body {
                background-color: black;
            }
        </style>
        <script type="text/javascript">
            // From https://stackoverflow.com/a/36012192/1418165 TODO: use https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API

            // the list of our video elements
            var videos = document.querySelectorAll('video');
            // an array to store the top and bottom of each of our elements
            var videoPos = [];
            // a counter to check our elements position when videos are loaded
            var loaded = 0;

            // Here we get the position of every element and store it in an array
            function checkPos() {
              // loop through all our videos
              for (var i = 0; i < videos.length; i++) {

                var element = videos[i];
                // get its bounding rect
                var rect = element.getBoundingClientRect();
                // we may already have scrolled in the page
                // so add the current pageYOffset position too
                var top = rect.top + window.pageYOffset;
                var bottom = rect.bottom + window.pageYOffset;
                // it's not the first call, don't create useless objects
                if (videoPos[i]) {
                  videoPos[i].el = element;
                  videoPos[i].top = top;
                  videoPos[i].bottom = bottom;
                } else {
                  // first time, add an event listener to our element
                  element.addEventListener('loadeddata', function() {
                      if (++loaded === videos.length - 1) {
                        // all our video have ben loaded, recheck the positions
                        // using rAF here just to make sure elements are rendered on the page
                        requestAnimationFrame(checkPos)
                      }
                    })
                    // push the object in our array
                  videoPos.push({
                    el: element,
                    top: top,
                    bottom: bottom
                  });
                }
              }
            };
            // an initial check
            checkPos();


            var scrollHandler = function() {
              // our current scroll position

              // the top of our page
              var min = window.pageYOffset;
              // the bottom of our page
              var max = min + window.innerHeight;

              videoPos.forEach(function(vidObj) {
                // the top of our video is visible
                if (vidObj.top >= min && vidObj.top < max) {
                  // play the video
                  vidObj.el.play();
                }

                // the bottom of the video is above the top of our page
                // or the top of the video is below the bottom of our page
                // ( === not visible anyhow )
                if (vidObj.bottom <= min || vidObj.top >= max) {
                  // stop the video
                  vidObj.el.pause();
                }

              });
            };
            // add the scrollHandler
            window.addEventListener('scroll', scrollHandler, true);
            // don't forget to update the positions again if we do resize the page
            window.addEventListener('resize', checkPos);
        </script>
    </head>
    <body>
EOF

for f in mp4/*; do
  [[ "$f" = "$(git ls-files "$f")" ]] || continue

cat <<EOF
        <video preload=auto loop muted autoplay width="350">
            <source src="/${f}" type="video/mp4">
            Sorry, your browser doesn't support embedded videos.
        </video>
EOF
done

cat <<EOF
    </body>
</html>
EOF
