TreeAntSan here. It's incredible to think that I've cracked it. In a single Saturday late afternoon I went from knowing nothing about Google Compute Cloud to making translated SRT files for my favorite Japanese videos.

Now, not afraid to say it here, but these are Japanese Adult Videos (JAVs for short).

On a Macbook Pro and using nothing but free tools I've managed to get this working.

I use the Serverless Model. And I had to patch a bit of code myself, but it works.

I can get a 2+ hour JAV translated (well enough) with just a few minutes of manual interaction and at the cost of PENNIES. Seriously. After my first 10 of video transcription and translation my free $300 trial credit was only down about $3. This is honestly incredible. You might be able to translate a JAV for **less than a dollar**, which is perfectly worth the price of admission.

## Summary of How I Do This

### Tools

1 - MKVToolNix (GUI and CLI)

- `brew install mkvtoolnix` on MacOS

2 -GCloud CLI

### General steps

1 - I take my JAV video

- Format mostly doesn't matter at all. It has worked with h.264, MPEG, DivX, XviD
- But if you run into really strange, old codecs, I'd recommend throwing it through HandBrake first
- I even had a video in the ancient Real Player codec and I ran into issues trying to re-merge the resulting files

2 - I throw it into MKVToolsNix in Multiplex Mode and split the video into 5-minute chunks

- I only leave the Audio track, but still name the .mkv extension (.mka won't work)
- Follow this guide: https://www.simplehelp.net/2019/11/27/how-to-split-an-mkv-file/

3 - I upload the files to the target bucket

- Do NOT accidentally upload the original file. You're gonna break your instance by running out of memory and just mess up your groove (this happened to me)
- Also who knows what systems at Google would look poorly on your uploading of a copyright JAV!

4 - When the transcribing and translations are done, I download all the resulting .en.srt files

- Batch downloading requires gcloud CLI
- Double check all the srt files are being batched. Check the count! You might miss some and have to correct mistakes!

5 - I place all the srt files in the same directory of all the 5-minute chunks

6 - I run my `mergeSrtToMKV.sh` script

7 - I place the first `-sub.mkv` in MKVToolNix and then I drag the remaining on top of the first chunk

- I choose the option to let me append on that first file (might need to select the dropdown)

8 - I make sure the resulting file is .mkv format and place it in a separate directory

9 - I run my `extractSrtFromMKV.sh` script

10 - I test the results

11 - I clear out the `-in` and `-tmp`

### Common issues

- If you can't seem to get a chunk to translate and you see the error "Total codepoints from input is 0", that means there's no dialog in that chunk!

### Suggested aliases

Add these lines to your bash/zsh profile/rc:

```bash
## MKV Projects
export GCLOUD_TRANS_BUCKET="bucket_name_to_upload_to_goes_here"
alias mkvsplit="~/git/trans_video_subs/scripts/splitVideo.sh"
alias mkvupload="~/git/trans_video_subs/scripts/uploadToGCloud.sh"
# This is the part where you download the files from Google to ./split with the script they let you copy
alias srtmerge="~/git/trans_video_subs/scripts/mergeSrtToMKV.sh && cd ./merged"
alias mkvjoin="~/git/trans_video_subs/scripts/joinVideo.sh && cd ./joined"
alias srtext="~/git/trans_video_subs/scripts/extractSrtFromMKA.sh"
```

- It's ordered in the general order of execution
- I added helpful `cd` commands where a new directory is created.
- You'll still need to select and batch download the resulting files.
