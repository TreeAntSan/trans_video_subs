#!/bin/bash

# Requires installing MKVToolNix's library of tools.
# If you're on Linux I'm sure you can figure it out, on MacOS use Homebrew.

# Tried and tested on MacOS

# Do note that here I'm assuming the subtitle track is track 1, which should be
# the case if you follow my style of stripping out all tracks but audio (which
# will be track 0).

# If somehow you have a video with more than one audio track, well, this will fail.
# You can discover which track is the subtitle track by running the following:
#   `mkvmerge -i <filename>.mkv``
# Then, you can provide an alternative track number, just type it after the
# script name. Ex:
#   `./extractSrtFromMKA.sh 2`


DEFAULT_TRACK_NUMBER="1"
TRACK_NUMBER="${1:-$DEFAULT_TRACK_NUMBER}"

for i in *.mka; do
    if [ ! -e "${i%.*}".srt ]; then
        echo "${i%.*} ok"
        mkvextract tracks "$i" "${TRACK_NUMBER}":"${i%.*}".srt
    fi
done
