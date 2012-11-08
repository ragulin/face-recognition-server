# from http://bytefish.de/blog/validating_algorithms
import os
import sys
import cv2
import numpy as np

from sklearn.base import BaseEstimator
from sklearn import cross_validation as cval
from sklearn.metrics import precision_score

def read_images(path, sz=None):
  """Reads the images in a given folder, resizes images on the fly if size is given.

  Args:
  path: Path to a folder with subfolders representing the subjects (persons).
  sz: A tuple with the size Resizes 

  Returns:
  A list [X,y]

  X: The images, which is a Python list of numpy arrays.
  y: The corresponding labels (the unique number of the subject, person) in a Python list.
  """
  c = 0
  X,y = [], []

  for dirname, dirnames, filenames in os.walk(path):
    for subdirname in dirnames:
      subjectPath = os.path.join(dirname, subdirname)
      for filename in os.listdir(subjectPath):
        try:
          img = cv2.imread(os.path.join(subjectPath, filename), cv2.IMREAD_GRAYSCALE)
          if sz is not None:
            img = cv2.resize(img, sz)
          X.append(np.asarray(img, dtype=np.uint8))
          y.append(c)
        except IOError, (errno, strerror):
          print "IOError({0}): {1}".format(errno, strerror)
        except:
          print "Unexpected error:" , sys.exc_info()[0]
          raise
      c += 1
  return [X,y]


class FaceRecognizer(BaseEstimator):
  def __init__(self):
    #self.model = model
    #self.model = cv2.createFisherFaceRecognizer()
    self.model = cv2.createEigenFaceRecognizer()

  def fit(self, X, y):
    self.model.train(X, y)

  def predict(self, T):
    return [self.model.predict(T[i]) for i in range(0, T.shape[0])]

if __name__ == "__main__":
  [X, y] = read_images(sys.argv[1], (100,100))

  #print len(os.listdir("../data/images/"))
  y = np.asarray(y, dtype=np.int32)
  cv = cval.StratifiedKFold(y, 10)

  estimator = FaceRecognizer()

  precision_scores = cval.cross_val_score(estimator, X, y, score_func=precision_score, cv=cv)
  print precision_scores
  print sum(precision_scores)/len(precision_scores)


