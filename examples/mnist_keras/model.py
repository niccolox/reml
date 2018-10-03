import keras
import tensorflow as tf
from tensorflow.python.client import device_lib
#from tensorflow import keras

def create_model():
  model = keras.models.Sequential([
    keras.layers.Dense(512, activation=tf.nn.relu, input_shape=(784,)),
    keras.layers.Dropout(0.2),
    keras.layers.Dense(10, activation=tf.nn.softmax)
  ])

  model.compile(optimizer=keras.optimizers.Adam(),
                loss=keras.losses.sparse_categorical_crossentropy,
                metrics=['accuracy'])

  return model

model = create_model()
model.save("model.h5")
