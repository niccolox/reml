import tensorflow as tf

a = tf.placeholder(tf.float32, name='a')
b = tf.placeholder(tf.float32, name='b')
c = tf.add(a, b, name='c')

with tf.Session() as session:
    tf.train.write_graph(session.graph_def,
                         './',
                         'add.pb',
                         as_text=False)
