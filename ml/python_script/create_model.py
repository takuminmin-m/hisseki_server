import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, optimizers, losses

import os
import sys
import numpy as np
import random
import matplotlib.pyplot as plt
import pathlib

from ml_tools import *

model_type = sys.argv[1]
if model_type != "classification" && model_type != "certification":
    raise Exception("Unexpected commandline arguments")

RAILS_ROOT = str(pathlib.Path(__file__).resolve().parents[2])

AUTOTUNE = tf.data.experimental.AUTOTUNE

def preprocess_image(image):
    image_4ch = tf.image.decode_image(image, channels=4, expand_animations=False)
    image_4ch = tf.image.resize(image_4ch, [128, 128])
    image = tf.cast(tf.reduce_sum(image_4ch, 2, keepdims=True), tf.float32)
    image /= 255.0

    return image

def load_and_preprocess_image(path):
    image = tf.io.read_file(path)
    return preprocess_image(image)

def mix_and_split(list, slice_index):
    shuffled_list = list
    random.shuffle(shuffled_list)
    return shuffled_list[:slice_index], shuffled_list[slice_index:]

def separate_image_and_label(list):
    images = []
    labels = []
    for i in range(len(list)):
        images.append(list[i]["image"])
        labels.append(list[i]["label"])
    return images, labels

def separate_2images_and_label(list):
    images1 = []
    images2 = []
    labels = []
    for i in range(len(list)):
        images1.append(list[i]["image1"])
        images2.append(list[i]["image2"])
        labels.append(list[i]["label"])
    return images1, images2, labels

def test():
    print(test)


images = []
labels = []

model = make_model(images, labels)
# model.save(RAILS_ROOT + "ml/" + )
