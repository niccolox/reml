import tensorflow as tf
import ipfsapi
from tensorflow.python.client import device_lib
from tensorflow import keras
import numpy as np

api = ipfsapi.connect('127.0.0.1', 5001)

def fit(model_hash, x_path, y_path):
    model = keras.models.load_model("/ipfs/" + model_hash.decode('utf-8'))
    x = np.load("/ipfs/" + x_path.decode('utf-8'))
    y = np.load("/ipfs/" + y_path.decode('utf-8'))
    model.fit(x, y, epochs=1)
    return []

def devices():
    local_device_protos = device_lib.list_local_devices()
    return [[x.name, x.device_type, x.memory_limit] for x in local_device_protos]
