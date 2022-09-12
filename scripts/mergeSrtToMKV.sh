#!/bin/bash

# Requires installing MKVToolNix's library of tools.
# If you're on Linux I'm sure you can figure it out, on MacOS use Homebrew.

# Tried and tested on MacOS
# Adapted from https://unix.stackexchange.com/a/568840

# Do note that here I'm assuming the srt files end with `.en.srt`. And that
# we're translating to English. You're of course welcome to change that.

# If you have an issue where some files have spaces that aren't replaced with
# underscores, you can use the following command to replace all spaces with
# underscores in the current directory:
# for f in *\ *; do mv "$f" "${f// /_}"; done;

# If you want to use a different language, simply provide it as an argument.
# ex: `./mergeSrtToMKV.sh fr`
DEFAULT_LANGUAGE="en"
LANGUAGE="${1:-$DEFAULT_LANGUAGE}"

for i in *.mkv; do
    # if the directory merge does not exist this will create it
    mkdir -p merged

    if [ -f "${i%.*}".en.srt ] && [ ! -e ./merged/"${i%.*}".mkv ]; then
        echo "${i%.*} merging srt"
        mkvmerge -o ./merged/"${i%.*}".mkv "$i" --default-track 0 --language 0:"${LANGUAGE}" "${i%.*}"."${LANGUAGE}".srt
    fi

    # If no SRT present, ususally there was no dialog, still copy for convenience
    if [ ! -f "${i%.*}".en.srt ] && [ ! -e ./merged/"${i%.*}".mkv ]; then
        echo "${i%.*} no srt present"
        cp "$i" ./merged/"${i%.*}".mkv
    fi
done

# Recommend adding `&& cd ./merged` to your alias to save you a step
