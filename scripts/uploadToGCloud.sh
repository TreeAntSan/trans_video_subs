#!/bin/bash

# This script uploads all .mkv files in the current directory to Google Cloud
# https://cloud.google.com/storage/docs/uploading-objects#upload-object-cli

if [[ ! -z "$(find *.mkv -type f -size +15M)" ]]; then
  echo "An MKV file was larger than 15MB - check to make sure there are no full files present!"
else
  # Checks that the env variable GCLOUD_TRANS_BUCKET is set
  if [[ -z "${GCLOUD_TRANS_BUCKET}" ]]; then
    echo "Env var \$GCLOUD_TRANS_BUCKET not set!";
  else
    # -m = run in parallel; -o = setting the parallel limit 2*4 files at a time.
    gsutil -o "GSUtil:parallel_process_count=2" -m cp *.mkv gs://"${GCLOUD_TRANS_BUCKET}"
  fi
fi
