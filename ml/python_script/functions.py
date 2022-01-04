import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, optimizers, losses, regularizers

import os
import sys
import numpy as np
import random
import matplotlib.pyplot as plt
import pathlib
import csv

def read_csv(filename):
    user_id = []
    image_paths = []

    with open(filename) as f:
        reader = csv.reader(f)

        for row in reader:
            user_id.append(row[0])
            image_paths.append(row[1])

    return user_id, image_paths

def preprocess_image(image):
    image_4ch = tf.image.decode_image(image, channels=4, expand_animations=False)
    image_4ch = tf.image.resize(image_4ch, [128, 128])
    image = tf.cast(tf.reduce_sum(image_4ch, 2, keepdims=True), tf.float32)
    image /= 255.0

    return image

def load_and_preprocess_image(path):
    image = tf.io.read_file(path)
    return preprocess_image(image)

def split(list, slice_ratio):
    slice_index = int(len(list) * slice_ratio)
    return list[:slice_index], list[slice_index:]

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
