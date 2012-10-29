import logging
import tornado.escape
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.websocket
import os.path
import uuid
from PIL import Image
import time
import StringIO
import uuid
import cv2
import numpy
import json
from tornado.options import define, options

define("port", default=8888, help="run on the given poort", type=int)

class Application(tornado.web.Application):
  def __init__(self):
    handlers = [
        (r"/", MainHandler),
        (r"/socket", SocketHandler)
        ]

    settings = dict(
        template_path=os.path.join(os.path.dirname(__file__), "templates"),
        static_path=os.path.join(os.path.dirname(__file__), "static"),
        xsrf_cookies=True,
        autoescape=None,
        debug=True
        )
    tornado.web.Application.__init__(self, handlers, **settings)

class MainHandler(tornado.web.RequestHandler):
  def get(self):
    self.render("index.html")

class SocketHandler(tornado.websocket.WebSocketHandler):

  def open(self):
    logging.info('new connection')


  def detect(self, img, cascade):
    rects = cascade.detectMultiScale(img, scaleFactor=1.3, minNeighbors=4, minSize=(30, 30), flags = cv2.cv.CV_HAAR_SCALE_IMAGE)
    if len(rects) == 0:
      return []
    rects[:,2:] += rects[:,:2]
    return rects

  def on_message(self, message):
    image = Image.open(StringIO.StringIO(message))
    n = numpy.array(image)
    gray = cv2.cvtColor(n, cv2.COLOR_RGB2GRAY)
    gray = cv2.equalizeHist(gray)
    #cv2.imwrite("foo.png", gray)
    cascade = cv2.CascadeClassifier("data/haarcascade_frontalface_alt.xml")
    faces = self.detect(gray, cascade)
    if len(faces) > 0:
      result = json.dumps(faces.tolist())
      self.write_message(result)

  def on_close(self):
    logging.info('connection closed')

def main():
  tornado.options.parse_command_line()
  app = Application()
  app.listen(options.port)
  tornado.ioloop.IOLoop.instance().start()

if __name__ == "__main__":
  main()
