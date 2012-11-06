import cv2
import logging

def detect(img, cascade):
  gray = toGrayscale(img)
  rects = cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=4, minSize=(30, 30), flags = cv2.cv.CV_HAAR_SCALE_IMAGE)
  if len(rects) == 0:
    return []
  return rects

def detectFaces(img):
  cascade = cv2.CascadeClassifier("data/haarcascade_frontalface_alt.xml")
  return detect(img, cascade)

def toGrayscale(img):
  gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
  gray = cv2.equalizeHist(gray)
  return gray

def containsFace(img):
  return len(detectFaces(img)) > 0

def save(path, img):
  cv2.imwrite(path, img)
  
def cropFaces(img, faces):
  for face in faces:
    x, y, h, w = [result for result in face]
    return img[y:y+h,x:x+w]

