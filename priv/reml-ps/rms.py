import sys
sys.path.append('./gen-py')
from reml import ReMLService
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer

import os
import keras
from keras import backend as K
from keras import models
from keras import layers
import tensorflow as tf
import numpy as np

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

class ReMLServiceHandler:
    def fit(self, model, x, y):
        tf.logging.set_verbosity(tf.logging.ERROR)
        model = keras.models.load_model(model)
        x = np.load(x)
        y = np.load(y)
        x = x.reshape(-1, 28 * 28) / 255.0
        model.fit(x,y, verbose = 1, epochs = 5)
        # should be saved in IPFS end returned hash
        model.save_weights('weights')
        return "weights"

    def predict(self, model, weights, vector):
        model = keras.models.load_model(model)
        model.load_weights(weights)
        vec = np.array([vector]) / 255.0
        result = model.predict(vec, verbose=1)
        print(result[0])
        return result[0]

if __name__ == '__main__':
    handler = ReMLServiceHandler()
    processor = ReMLService.Processor(handler)
    transport = TSocket.TServerSocket(port=9090)
    tfactory = TTransport.TFramedTransportFactory()
    pfactory = TBinaryProtocol.TBinaryProtocolFactory()

    server = TServer.TSimpleServer(processor, transport, tfactory, pfactory)
    print ('Serving ...')
    server.serve()
