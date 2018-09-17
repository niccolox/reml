import tensorflow as tf
from keras import backend as K
from tensorflow.python.client import device_lib
from tensorflow import keras
import numpy as np

#def data(data, rank, schema):
#def list_to_dict(list):

# Convert Elixir list to Python dict
def elist_to_dict(l):
    return {x[0].decode('utf-8'):x[1].decode('utf-8') for x in l}

def fit(device_type, local_rank, model_hash, x_path, y_path, config):
    if device_type.decode('utf-8') == "cpu":
        device = '/cpu:0'
    if device_type.decode('utf-8') == "gpu":
        device = '/gpu:0'

    config = elist_to_dict(config)

    model = keras.models.load_model("/ipfs/" + model_hash.decode('utf-8'))
    x = np.load("/ipfs/" + x_path.decode('utf-8'))
    y = np.load("/ipfs/" + y_path.decode('utf-8'))

    with tf.device(device):
       model.fit(x,y, epochs = 5)

    return []

def devices():
    local_device_protos = device_lib.list_local_devices()
    return [[x.name, x.device_type, x.memory_limit] for x in local_device_protos]


