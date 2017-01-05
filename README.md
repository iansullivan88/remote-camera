# Remote Camera

A web app that displays a live (~10s latency) video from a raspberry pi camera. The app generates an HLS video stream using raspivid and ffmpeg, and serves the video stream and basic web page via a server written in Haskell. Web HLS support [isn't great](http://caniuse.com/#feat=http-live-streaming) but most phones can support it. Something like VLC can also play HLS streams. When the video stream is not actively watched, the camera will stop capturing. When the video stream is requested again, the camera will activate.

## Dependencies

* ffmpeg
* raspivid
* a directory called `/media/videostream` used for storing and serving video files. It's best to mount this path using tmpfs so the video files are stored in RAM. Using the default settings, this folder doesn't exceed 10MB on my machine.

## Build
Build and run using [stack]([https://docs.haskellstack.org/en/stable/README/):

    stack build
    stack exec remote-camera-exe
    
## Run
If you don't want to compile from source, compiled binaries can be downloaded from a [release](https://github.com/iansullivan88/remote-camera/releases)

There are a few configurable properties in the config.json file.
