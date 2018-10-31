import tensorflow as tf
import numpy as np

from cassandra.cluster import Cluster
from cassandra.query import BatchStatement, SimpleStatement

(train_images, train_labels), (test_images, test_labels) = tf.keras.datasets.mnist.load_data()

cluster = Cluster()
session = cluster.connect()

session.execute(
    """
    CREATE KEYSPACE datasets WITH REPLICATION = {
                      'class' : 'SimpleStrategy',
                      'replication_factor' : 1 }
    """
)

session.set_keyspace('datasets')

session.execute(
    """
    CREATE TABLE mnist_train (id int, vector list<frozen <list<int>>>, label int, PRIMARY KEY (id))
    """
)

for idx, vec in enumerate(train_images):
    session.execute("""INSERT INTO mnist_train (id, vector, label) VALUES (%s, %s, %s)""", (idx, vec.tolist(), train_labels[idx]))

session.execute(
    """
    CREATE TABLE mnist_test (id int, vector list<frozen <list<int>>>, label int, PRIMARY KEY (id))
    """
)

for idx, vec in enumerate(test_images):
    session.execute("""INSERT INTO mnist_test (id, vector, label) VALUES (%s, %s, %s)""", (idx, vec.tolist(), test_labels[idx]))
