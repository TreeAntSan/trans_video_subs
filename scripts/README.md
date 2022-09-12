TreeAntSan here. It's incredible to think that I've cracked it. In a single Saturday late afternoon I went from knowing nothing about Google Compute Cloud to making translated SRT files for my favorite Japanese videos.

On a Macbook Pro and using nothing but free tools I've managed to get this working.

I use the Serverless Model. And I had to patch a bit of code myself, but it works.

I've been using this tool on JAVs, which don't have too much dialog compared to say, a movie or TV show, but I am able to give a general cost rundown of this tool:

## Costs
When you sign up for Google Cloud, you should get a $300, 90 day free trial credit. Which will definitely help you get started and get most of your favorite JAVs translated (probably around 280 hours worth).

- [Text-to-Speech API Pricing](https://cloud.google.com/speech-to-text/pricing)
  - In my early expereince about 90% of my costs come from transcription
  - If you [opt for data logging](https://cloud.google.com/speech-to-text/docs/enable-data-logging) you get a 33% discount
  - I updated the app to mix down stereo to mono audio, which, according to them will avoid the 100% price increase from stereo (2 channels)
    - I haven't yet figured out if this is really happening... but I hope it is
  - All together, expect to pay about ((1*60*60/15) * 0.004) = $0.96 USD per hour of audio
- [Translate API Pricing](https://cloud.google.com/translate/pricing)
  - In my early expereince about 9% of my costs come from translation
  - It's a simple $20 USD per 1,000,000 characters
  - Now, I don't know if that's a rate of 1 character incoming, or both 1 character incoming and outgoing
    - As in... does translating "こんにちは" (Kon'nichiwa) to "Hello" count just the five Japanese characters, or does it also count the five English characters for 10 in total?
  - If it's just the incoming characters, my guestimate is about $0.10 per hour in translation costs
- [Cloud Run](https://cloud.google.com/run/pricing)
  - In my early expereince less than 1% of my costs come from the cloud computing
  - I've struggled to get a grasp on the cost here, but it's small beans compared to the rest
- [Cloud Storage](https://cloud.google.com/storage/pricing)
  - This will basically amount to a few pennies
    - So long as you delete your `_tmp` and `_in` files between translation sessions
    - Seriously, every 5 minute chunk leaves behind a 25mb .flac audio file in my experience. Those can seriously add up
  - When your free trial ends you might still get charged every so often so make sure you're cool with random charges coming to you every month or whatever
  - I choose a single region, you can see the prices in the link above

### tl;dr
Basically, expect to pay about $1.00 USD an hour. I might be wrong, though. Make sure you opt to allow your audio for analysis. Google will get better anyway, haha.

## How TRANS_VIDEO_SUBS works

1. When video files are uploaded to a particular storage bucket it triggers the process
2. For each video file it uses ffmpeg to outout .flac audio files
3. Each .flac audio file is run through Google's Speech-To-Text API
4. The results are put into a ja.srt file
5. The ja.srt file is parsed and put through Google Translation API
6. The results are put back into an en.srt file

## Summary of How I Do This

### Tools

1 - MKVToolNix (CLI)

- `brew install mkvtoolnix` on MacOS

2 - GCloud CLI

### Process steps

1. Have my JAV video in a directory, let's call it `./JAV-456/JAV-456.mp4`
2. I run my script like so: `splitVideo.sh JAV-456.mp4`
  - This creates a new directory, `./split`
  - It uses mkvmerge to split the video into 5-minute chunks with only the audio track as .mkv files
  - This takes <3 seconds
  - The files look like:
```
# ./JAV-456/split/
JAV-456_001.mkv
JAV-456_002.mkv
JAV-456_003.mkv
JAV-456_004.mkv
JAV-456_005.mkv
# ...
```
  - I haven't experimented with different length segments yet. 5 minute chunks have worked well for me
  - To upload a full length audio file would likely end in failure and would take longer as it'd have to transcribe and translate the entire video in one process instead of taking advantage of multi-threading
3. In `./JAV-456/split/`, and with the GCloud CLI configured on my machine (a Mac) i run my script `uploadToGCloud.sh`
  - This uploads all the split files (depending on the audio quality this can be anywhere from 2mb to 6mb a piece - or about 50-150mb for a 2hr video)
  - This takes perhaps 2 minutes for my connection
4. I watch the GCloud logs and storage buckets are they complete their work
  - It is able to do work in parallel, so, it takes roughly 4 minutes or so to transcribe and translate a single segment, but is able to do many at the same time
  - I haven't timed it, but I can expect my 2hr video to be complete within 10 minutes or so
  - I can continue to split and upload multiple videos at once
5. I then batch download the resulting .en.srt files to `./JAV-456/split/`
  - This is the main manual part comes from having to refresh and check the _out directory for the generated .en.srt files and then batch downloading them with a pre-generated download script I simply copy-paste into my console and download to the `./split` directory
  - I could work on making this run in a script as well, but to do it would let you download files blindly and might very easily miss some srt files that haven't finished generating yet
6. Now I have a directory full of the split mkv files and en.srt files, so my file list looks a lot like this:
```
# ./JAV-456/split/
JAV-456_001.mkv
JAV-456_001.en.srt
JAV-456_002.mkv
JAV-456_002.en.srt
JAV-456_003.mkv
JAV-456_003.en.srt
JAV-456_004.mkv
JAV-456_004.en.srt
JAV-456_005.mkv
JAV-456_005.en.srt
# ...
```
7. I then run my script `mergeSrtToMKV.sh`
  - This creates a new directory `./merged​​​​`
```
# ./JAV-456/split/merged/
JAV-456_001.mkv
JAV-456_002.mkv
JAV-456_003.mkv
JAV-456_004.mkv
JAV-456_005.mkv
# ...
```
  - Using mkvmerge it embeds each srt into the corresponding mkv file
  - This takes <3 seconds
8. In `./JAV-456/split/merged/` I then run my script `joinVideo.sh`
  - This, in order, appends each mkv video into a single MKA file, re-creating the original length of the video and most importantly letting the tool take care of timing the SRT files
  - The resulting file is placed in `./JAV-456/split/merged/joined/JAV-456.mka`
```
# ./JAV-456/split/merged/joined/
JAV-456.mka
```
  - This takes <3 seconds
9. In `./JAV-456/split/merged/joined/` I run the final script `extractSrtFromMKA.sh`
  - This gets me the final .srt file
```
# ./JAV-456/split/merged/joined/
JAV-456.mka
JAV-456.srt # hell yea!
```
  - This takes <1 second
10. Finally, I move the .srt to the correct directory and then delete all my working files by deleting `./JAV-456/split/`
11. Bonus: To save hard drive space I recommend deleting the `_in` and `_tmp` buckets on GCloud to save space
  - I think the script is supposed to delete a lot of its temp data but I think it's broken
  - The tool will re-create the buckets on its own automatically
  - Don't delete the bucket you upload to, though!
  - I do recommend deleting your uploaded files afterward

### Common issues

- If you can't seem to get a chunk to translate and you see the error "Total codepoints from input is 0", that means there's no dialog in that chunk!

### Future improvement ideas
- Writing a script-of-scripts that requires running only two commands:
  - First one that splits and uploads the files
  - The second one that merges the srts, joins the files, and extracts the joined srt
- Allowing translating to multiple languages instead of just one at a time
  - This wouldn't be too hard to code I don't think
  - Each language would probably cost about $0.10 USD to translate per hour of video (ymmv)
  - To instead perform the process multiple times would incur transcription costs multiple times, which would take time and (most importantly) money
    - Scripts would need to get updated so it'd be easy to do
- Somehow tracking translation progress and make the entire thing into just one big script
- I'd say "support for Windows scripts" but it'd seriously be so much easier to use Windows Subsystem for Linux to get the Linux terminal

### Suggested aliases

Add these lines to your bash/zsh profile/rc:

```bash
## MKV Projects
export GCLOUD_TRANS_BUCKET="bucket_name_to_upload_to_goes_here"
alias mkvsplit="~/git/trans_video_subs/scripts/splitVideo.sh"
alias mkvupload="~/git/trans_video_subs/scripts/uploadToGCloud.sh"
# This is the part where you download the files from Google to ./split with the script they let you copy
alias srtmerge="~/git/trans_video_subs/scripts/mergeSrtToMKV.sh"
alias mkvjoin="~/git/trans_video_subs/scripts/joinVideo.sh"
alias srtext="~/git/trans_video_subs/scripts/extractSrtFromMKA.sh"
```

- It's ordered in the general order of execution
- You'll still need to select and batch download the resulting files.
