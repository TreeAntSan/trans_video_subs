#!/bin/bash

# Tried and tested on MacOS
# Recommend installing MKVToolNix via Homebrew (for MacOS) so you can use the
# mkvmerge command.

# Then add this script to your PATH so you can run it from anywhere. Or make
# it an alias if you don't wanna do that.

# Do note that here I'm assuming the subtitle track is track 1
# You can discover which track is the subtitle track by running the following:
# mkvmerge -i <filename>.mkv



for i in *.mkv; do
    if [ ! -e "${i%.*}".srt ]; then
        echo "${i%.*} ok"
        mkvextract tracks "$i" 1:"${i%.*}".srt
    fi
done
