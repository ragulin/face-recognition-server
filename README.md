Face recognition with webrtc, websockets and opencv
==========================================
This is a webrtc, websockets and opencv experiment developed during a [athega](http://athega.se) hackday. 

How does it work?
-------------------
Frames are captured from the web camera via webrtc and sent to the server over websockets. On the server the frames are processed with opencv and a json response is sent back to the client.

Sample json response:

      {
        "face": {
          "distance": 428.53381034802453,
          "coords": {
            "y": "39",
            "x": "121",
            "height": "137",
            "width": "137"
          },
          "name": "mike"
        }
      }

Everything except `distance` is pretty self explanatory. 

* `name` is the predicted name of the person in front of the camera.

* `coords` is where the face is found in the image.

* `distance` is a measurement on how accurate the prediction is, lower is better.

If we can't get a reliable prediction (10 consecutive frames that contains a face and with a distance lower than 1000) we switch over to training mode. In training mode we capture 10 images and send them together with a name back to the server for retraining. After the training has been completed we switch back to recognition mode and hopefully we'll get a more accurate result.

Running it
----------
Make sure the dependencies are met.

* [OpenCV](http://opencv.org) with python bindings (I'm using the trunk version)
* [Tornado](www.tornadoweb.org)
* [PIL](http://www.pythonware.com/products/pil/)
* [Peewee](https://github.com/coleifer/peewee)
* [scikit-learn](http://scikit-learn.org/stable/) (for running the crossvalidation)

Download the [AT&T face database](http://www.cl.cam.ac.uk/research/dtg/attarchive/facedatabase.html) and extract it to `data/images` before the server is started. This is needed to build the initial prediction model.

Run with `python server.py`
