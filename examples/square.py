import tensorflow as tf

a = tf.placeholder(tf.float32, name='a')
c = tf.square(a, name='c')

with tf.Session() as session:
    tf.train.write_graph(session.graph_def,
                         './',
                         'square.pb',
                         as_text=False)
