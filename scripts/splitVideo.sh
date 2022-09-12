#!/bin/bash

# This script takes a video file name as an argument. It then splits it into
# 5 minute segments using mkvmerge. It outputs it into a sub directory named
# ./split.
file="$1"
mkdir -p ./split

# See https://mkvtoolnix.download/doc/mkvmerge.html#mkvmerge.description section 2.7
mkvmerge -o ./split/"${file%.*}"_%03d.mkv \
  --split duration:00:05:00 \
  --no-video --no-subtitles --no-buttons --no-track-tags --no-chapters \
  --no-attachments --no-global-tags \
  "$file"

cd ./split
