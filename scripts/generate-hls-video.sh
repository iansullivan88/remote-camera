#!/bin/bash

# Record video using radpivid and pipes it through ffmpeg to generate an hls stream
# Adapted from http://raspberrypi.stackexchange.com/a/7615

filePath=$1

echo "Streaming video to $filePath"

raspivid -n -w 720 -h 405 -ex night -fps 25 -t 0 -b 2000000 -ih -k -o - \
| ffmpeg -y \
    -i - \
    -c:v copy \
    -map 0 \
    -f ssegment \
    -segment_time 1 \
    -segment_format mpegts \
    -segment_list "$filePath/stream.m3u8" \
    -segment_list_size 2 \
    -segment_wrap 20 \
    -segment_list_flags +live \
    -segment_list_type m3u8 \
    "$filePath/%03d.ts"

echo "Finished streaming"
