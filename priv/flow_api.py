import tensorflow as tf
from tensorflow.python.client import device_lib
from tensorflow import keras

def create_model():
  model = tf.keras.models.Sequential([
    keras.layers.Dense(512, activation=tf.nn.relu, input_shape=(784,)),
    keras.layers.Dropout(0.2),
    keras.layers.Dense(10, activation=tf.nn.softmax)
  ])

  model.compile(optimizer=tf.keras.optimizers.Adam(),
                loss=tf.keras.losses.sparse_categorical_crossentropy,
                metrics=['accuracy'])

  return model

def fit():
    (train_images, train_labels), (test_images, test_labels) = tf.keras.datasets.mnist.load_data()
    train_labels = train_labels[:1000]
    test_labels = test_labels[:1000]

    train_images = train_images[:1000].reshape(-1, 28 * 28) / 255.0
    test_images = test_images[:1000].reshape(-1, 28 * 28) / 255.0

    model = create_model()
    model.fit(train_images, train_labels, epochs=5)
    model.save("/Users/xcilog/test.h5")
    return []


def devices():
    local_device_protos = device_lib.list_local_devices()
    return [[x.name, x.device_type, x.memory_limit] for x in local_device_protos]
