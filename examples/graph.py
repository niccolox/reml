import tensorflow as tf

a = tf.placeholder(tf.float32, name='a')
b = tf.placeholder(tf.float32, name='b')
c = tf.sqrt(tf.add(tf.square(a), tf.square(b)), name='c')

with tf.Session() as session:
    tf.train.write_graph(session.graph_def,
                         './',
                         'graph.pb',
                         as_text=False)
