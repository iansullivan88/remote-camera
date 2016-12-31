#!/bin/bash

filePath=$1

echo "Streaming video to $filePath"

raspivid -n -w 720 -h 405 -fps 25 -t 86400000 -b 1800000 -ih -k -o - \
| ffmpeg -y \
    -i - \
    -c:v copy \
    -map 0:0 \
    -segment_wrap 20 \
    -f ssegment \
    -segment_time 1 \
    -vcodec libx264 \
    -x264-params keyint=25:no-scenecut=1 \
    -segment_format mpegts \
    -segment_list "$filePath/stream.m3u8" \
    -segment_list_size 720 \
    -segment_list_flags live \
    -segment_list_type m3u8 \
    "$filePath/%08d.ts"

echo "Finished streaming"
