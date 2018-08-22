from PIL import Image
import numpy as np

image = Image.open("cropped_panda.jpg")
image_array = np.asarray(image)[:, :, 0:3]  # Select RGB channels only.

image_array.tofile('panda.csv',sep=',',format='%s')
