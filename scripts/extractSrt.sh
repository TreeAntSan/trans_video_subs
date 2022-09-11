#!/bin/bash

# Tried and tested on MacOS
# Recommend installing MKVToolNix via Homebrew (for MacOS) so you can use the
# mkvmerge command.

# Then add this script to your PATH so you can run it from anywhere. Or make
# it an alias if you don't wanna do that.

# Do note that here I'm assuming the subtitle track is track 2


for i in *.mkv; do
    if [ ! -e "${i%.*}".srt ]; then
        echo "${i%.*} ok"
        mkvextract tracks "$i" 2:"${i%.*}".srt
    fi
done
