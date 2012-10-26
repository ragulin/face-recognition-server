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
import cv
from tornado.options import define, options

define("port", default=8888, help="run on the given poort", type=int)

class Application(tornado.web.Application):
  def __init__(self):
    handlers = [
        (r"/", MainHandler),
        (r"/socket", SocketHandler)
        ]

    settings = dict(
        cookie_secret="__TODO:_GENERATE_YOUR_OWN_RANDOM_VALUE_HERE__",
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

  def on_message(self, message):
    image = Image.open(StringIO.StringIO(message))
    cvImage = cv.CreateImageHeader(image.size, cv.IPL_DEPTH_8U, 3)
    cv.SetData(cvImage, image.tostring())
    dst = cv.CreateImage(cv.GetSize(cvImage), cv.IPL_DEPTH_16S, 3)
    laplace = cv.Laplace(cvImage, dst)
    cv.SaveImage("foo-test.png", dst)
    cv.SaveImage("laplace.png", laplace)
    cv.SaveImage("foo.png", cvImage)
    image.save("test.jpg")


def main():
  tornado.options.parse_command_line()
  app = Application()
  app.listen(options.port)
  tornado.ioloop.IOLoop.instance().start()

if __name__ == "__main__":
  main()
