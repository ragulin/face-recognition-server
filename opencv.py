import os
import sys
import cv2
import numpy as np
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

def load_images(path):
  images, labels = [], []
  c = 0
  print "test " + path
  for dirname, dirnames, filenames in os.walk(path):
    print "test"
    for subdirname in dirnames:
      subjectPath = os.path.join(dirname, subdirname)
      for filename in os.listdir(subjectPath):
        try:
          img = cv2.imread(os.path.join(subjectPath, filename), cv2.IMREAD_GRAYSCALE)
          images.append(np.asarray(img, dtype=np.uint8))
          labels.append(c)
        except IOError, (errno, strerror):
          print "IOError({0}): {1}".format(errno, strerror)
        except:
          print "Unexpected error:" , sys.exc_info()[0]
          raise
      c += 1
    return images, labels

def train():
  images, labels = load_images("data/images/")
  model = cv2.createFisherFaceRecognizer()
  model.train(images,np.asarray(labels))
  model.save("fishermodel.mdl")

def predict():
  model = cv2.createFisherFaceRecognizer()
  model.load("fishermodel.mdl")
  images, labels = load_images("data/images/")
  import random
  r = random.randrange(0, len(images))
  print labels[r] 
  print model.predict(images[r])



if __name__ == "__main__":
  predict()
  #train()
