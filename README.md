# Remote Camera

A web app that displays a live (10s latency) video from a raspberry pi camera. The app generates an HLS video stream using raspivid and ffmpeg, and serves the video stream and basic web page via a server written in Haskell. Web HLS support [isn't great](http://caniuse.com/#feat=http-live-streaming) but most phones can use it. Something like VLC can also play HLS streams.

More info to follow...

## Build
Build and run using stack:

    stack build
    stack exec remote-camera-exe
