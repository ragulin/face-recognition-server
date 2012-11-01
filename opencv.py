import cv2

def detect(img, cascade):
  gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
  gray = cv2.equalizeHist(gray)
  rects = cascade.detectMultiScale(img, scaleFactor=1.3, minNeighbors=4, minSize=(30, 30), flags = cv2.cv.CV_HAAR_SCALE_IMAGE)
  if len(rects) == 0:
    return []
  rects[:,2:] += rects[:,:2]
  return rects

def detectFaces(img):
  cascade = cv2.CascadeClassifier("data/haarcascade_frontalface_alt.xml")
  return detect(img, cascade)

