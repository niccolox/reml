import cv2

import base64

def imdecode(array):
    #encoded_data = raw.decode('utf-8').split(',')[1]
    #cv2.CV_LOAD_IMAGE_GRAYSCALE
    img = cv2.imdecode(array, cv2.IMREAD_COLOR)
    return img

def resize():
    #255-gray, (28, 28)
    return cv2.resize(255-gray, (28, 28))

def flatten(v):
    return v.flatten()
