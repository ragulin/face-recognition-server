import logging
import tornado.escape
import tornado.ioloop
import tornado.options
import tornado.web
import tornado.websocket
import os.path
import uuid
from PIL import Image
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
    logging.info("Got message %r", type(message))
    logging.info("Got message %r", type(bytearray(message)))
    logging.info("Got message %r", message)


def main():
  tornado.options.parse_command_line()
  app = Application()
  app.listen(options.port)
  tornado.ioloop.IOLoop.instance().start()

if __name__ == "__main__":
  main()
