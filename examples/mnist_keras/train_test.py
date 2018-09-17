import tensorflow as tf
from tensorflow import keras

#def data(data, rank, schema):

def fit(device_type, rank = 0):
    if device_type == 'cpu':
        device = '/cpu:0'
    if device_type == 'gpu':
        device = '/gpu:0'

    with tf.device(device):
        model = keras.models.load_model("model.h5")
        model.fit(ti,tl, epochs = 5)

fit('cpu')
