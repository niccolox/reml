import cv2
import numpy
from scipy import ndimage

def shift(img):
  cy, cx = ndimage.measurements.center_of_mass(img)
  rows, cols = img.shape
  sx = numpy.round(cols / 2.0 - cx).astype(int)
  sy = numpy.round(rows / 2.0 - cy).astype(int)
  rows, cols = img.shape
  m = numpy.float32([[1, 0, sx],[0, 1, sy]])
  shifted = cv2.warpAffine(img, m, (cols, rows))
  return shifted

def crop(img):
  if numpy.count_nonzero(img) <= 20: return []

  while numpy.sum(img[0]) == 0: img = img[1:]
  while numpy.sum(img[:,0]) == 0: img = numpy.delete(img,0,1)
  while numpy.sum(img[-1]) == 0: img = img[:-1]
  while numpy.sum(img[:,-1]) == 0: img = numpy.delete(img,-1,1)

  rows, cols = img.shape
  diff = abs(rows - cols)
  half_sm = int(diff / 2)
  half_big = half_sm if half_sm * 2 == diff else half_sm + 1
  if rows > cols:
    img = numpy.lib.pad(img, ((0, 0), (half_sm, half_big)), 'constant')
  else:
    img = numpy.lib.pad(img, ((half_sm, half_big), (0, 0)), 'constant')

  img = cv2.resize(img, (20, 20))
  img = numpy.lib.pad(img, ((4, 4), (4, 4)), 'constant')
  return img

def process(file):
  file = file.decode("utf-8") if type(file) is bytes else file
  img = cv2.imread(file, 0)
  _, gray = cv2.threshold(img, 128, 255, cv2.THRESH_BINARY_INV | cv2.THRESH_OTSU)
  cropped = crop(gray)
  if not len(cropped): return False

  shifted = shift(cropped)
  # cv2.imwrite("out/file.png", shifted)

  vector = shifted.flatten() / 255.0
  vector = vector.tolist()
  return vector

