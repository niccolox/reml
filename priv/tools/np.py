import numpy

# type = np.uint8
def fromstring(data, type):
    #base64.b64decode(encoded_data)
    return numpy.fromstring(data, type)
