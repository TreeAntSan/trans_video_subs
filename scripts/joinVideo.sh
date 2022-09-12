#!/bin/bash

# Requires installing MKVToolNix's library of tools.
# If you're on Linux I'm sure you can figure it out, on MacOS use Homebrew.

# This script takes a list of all the videos in the current directory
# It then joins them together into a single video file
# It then outputs it into a sub directory named ./joined
mkdir -p ./joined

# Gets the name of the file that ends with _001.mkv
FIRST_FILE=$(ls | grep _001.mkv | head -n 1)

# Sets the output name by stripping the _001.mkv from the end of the file name.
OUTPUT_FILE="${FIRST_FILE%_001.mkv}".mka

# Create a string of all the .mkv files in the current directory
ALL_MKV_FILES=$(ls *.mkv | xargs)
mkvmerge -o ./joined/${OUTPUT_FILE} '[' ${ALL_MKV_FILES} ']'

cd ./joined
