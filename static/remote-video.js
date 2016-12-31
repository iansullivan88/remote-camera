(function() {

    var startButton = document.getElementById("start"),
        stopButton = document.getElementById("stop"),
        videoContainer = document.getElementById("video-container"),
        messageContainer = document.getElementById("message-container"),
        currentVideo;


    stopButton.addEventListener('click', function() {
        destroyExistingVideo();
        postJson("/api/stop", function(res) {
            if (res.success) {
                setMessage("Video stream stopped");
            } else {
                setMessage("The server could not stop the message stream, it is already stopping or starting")
            }
        }, function() {
            setMessage("An unknown error occurred when stopping the video stream")
        })
    });

    startButton.addEventListener('click', function() {
        destroyExistingVideo();
        postJson("/api/start", function(res) {
            if (res.success) {
                setMessage("Video stream started");
            } else {
                setMessage("The server could not start the message stream, it is already stopping or starting")
            }
            createVideoElement();
        }, function() {
            setMessage("An unknown error occurred when starting the video stream")
        })
    });

    function createVideoElement() {
        currentVideo = document.createElement('video');
        currentVideo.autoplay = true;
        currentVideo.controls = 'controls';


        var source = document.createElement('source');
        source.src = '/video/stream.m3u8';
        source.type = 'application/x-mpegURL';

        currentVideo.appendChild(source);
        videoContainer.appendChild(currentVideo);

        currentVideo.play();
    }

    function destroyExistingVideo() {
        if (currentVideo) {
            videoContainer.removeChild(currentVideo);
            currentVideo = null;
        }
    }

    function setMessage(message) {
        messageContainer.innerHTML = message;
    }


    // Adapted from https://mathiasbynens.be/notes/xhr-responsetype-json#browser-support
    function postJson(url, successHandler, errorHandler) {
    	var xhr = new XMLHttpRequest();
    	xhr.open('post', url, true);
    	xhr.responseType = 'json';
    	xhr.onload = function() {
    		var status = xhr.status;
    		if (status == 200) {
    			successHandler && successHandler(xhr.response);
    		} else {
    			errorHandler && errorHandler(status);
    		}
    	};
    	xhr.send();
    };

})()
