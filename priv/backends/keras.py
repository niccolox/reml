import os
import keras
from keras import backend as K
from keras import models
from keras import layers
import tensorflow as tf
from tensorflow.python.client import device_lib
#from tensorflow import keras
import numpy as np
#import erlport
from erlport.erlterms import Atom
from erlport.erlang import call

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
#def data(data, rank, schema):
#def list_to_dict(list):
def get_gradients(model):
    weights = model.trainable_weights
    #weights = [weight for weight in weights]  #if model.get_layer(weight.name).trainable]
    #weights = [model.layers[0].trainable_weights()]
    #weigths = [tensor for tensor in model.trainable_weights if model.get_layer(tensor.name[:-2]).trainable]
    #print (weights)

    gradients = model.optimizer.get_gradients(model.model.total_loss, weights)
    symb_inputs = (model._feed_inputs + model._feed_targets + model._feed_sample_weights)
    f = K.function(symb_inputs, gradients)
    x,y, sample_weight = model._standardize_user_data(np.ones((4,784)), np.ones((4,1)))
    output = f(x + y + sample_weight)

    return output

class PalliumCallback(keras.callbacks.Callback):
    def on_epoch_end(self, epoch, logs=None):
        model = self.model
        # gradients = get_gradients(model)
        print(call(Atom(b'Elixir.Pallium'), Atom(b'python'), []))
        #call(Atom("erlang"), Atom("self"), [])

   #for p in gradients:
            #c = tf.constant(p, name=None)
       #     print(p.dtype)
        #print zip(weights, g)
        #opt = model.optimizer
        return model # opt.get_gradients(model.total_loss, weights)

# Convert Elixir list to Python dict
def elist_to_dict(l):
    return {x[0].decode('utf-8'):x[1].decode('utf-8') for x in l}

def fit(device_type, local_rank, model_hash, x_path, y_path, config):
    #if device_type.decode('utf-8') == "cpu":
    #    device = '/cpu:0'
    #if device_type.decode('utf-8') == "gpu":
    #    device = '/gpu:' + str(local_rank)
    tf.logging.set_verbosity(tf.logging.ERROR)

    config = tf.ConfigProto()
    config.gpu_options.allow_growth = True
    config.gpu_options.visible_device_list = str(local_rank)
    K.set_session(tf.Session(config=config))


    #config = elist_to_dict(config)

    #model = keras.models.load_model("/ipfs/" + model_hash.decode('utf-8'))
    model = keras.models.load_model(model_hash.decode('utf-8'))
    #x = np.load("/ipfs/" + x_path.decode('utf-8'))
    #y = np.load("/ipfs/" + y_path.decode('utf-8'))
    x = np.load(x_path.decode('utf-8'))
    y = np.load(y_path.decode('utf-8'))

    #callbacks = [
    #    keras.callbacks.ModelCheckpoint('./checkpoint-{epoch}.h5')
    #]
    pc = PalliumCallback()
    model.fit(x,y, verbose = 1, batch_size = 128, epochs = 2, callbacks=[pc])
    print(pc)
    return []

def devices():
    local_device_protos = device_lib.list_local_devices()
    return [[x.name, x.device_type, x.memory_limit] for x in local_device_protos]


