#!/bin/bash

# Tried and tested on MacOS
# Adapted from https://unix.stackexchange.com/a/568840
# Recommend installing MKVToolNix via Homebrew (for MacOS) so you can use the
# mkvmerge command.

# Then add this script to your PATH so you can run it from anywhere. Or make
# it an alias if you don't wanna do that.

# Do note that here I'm assuming the srt files end with `.en.srt`.

# If you have an issue where some files have spaces that aren't replaced with
# underscores, you can use the following command to replace all spaces with
# underscores in the current directory:
# for f in *\ *; do mv "$f" "${f// /_}"; done

for i in *.mkv; do
    # if the directory merge does not exist this will create it
    mkdir -p merged

    if [ -f "${i%.*}".en.srt ] && [ ! -e ./merged/"${i%.*}".mkv ]; then
        echo "${i%.*} merging srt"
        mkvmerge -o ./merged/"${i%.*}".mkv "$i" --default-track 0 --language 0:en "${i%.*}".en.srt
    fi

    # if no SRT present, ususally there was no dialog, still copy for convenience
    if [ ! -f "${i%.*}".en.srt ] && [ ! -e ./merged/"${i%.*}".mkv ]; then
        echo "${i%.*} no srt present"
        cp "$i" ./merged/"${i%.*}".mkv
    fi
done