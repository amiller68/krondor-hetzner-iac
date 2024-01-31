#!/usr/bin/env bash

# Example of running a series of torrent jobs and sending a notification when done

# Get the Dataset path from the first argument
INPUT_PATH=$1
# Get the Ifttt webhook key from the first argument
IFTTT_TEST_WEBHOOK_KEY=$2

# Start the torrent job in a new tmux session
aria2c -d $INPUT_PATH --seed-time=0 -Z -i $INPUT_PATH/torrents.txt;
curl -X POST -H \"Content-Type: application/json\" -d \
  "{\"Title\": \"Torrent done\"}" \
  https://maker.ifttt.com/trigger/dataprep_event/with/key/"$IFTTT_TEST_WEBHOOK_KEY";