import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, optimizers, losses

import os
import sys
import numpy as np
import random
import matplotlib.pyplot as plt
import pathlib


model_type = sys.argv[1]
if model_type != "classification" && model_type != "certification":
    raise Exception("Unexpected commandline arguments")

RAILS_ROOT = str(pathlib.Path(__file__).resolve().parents[2])


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

def conv_batchnorm_relu(x, filters, kernel_size):
    params = {
        "filters": filters,
        "kernel_size": kernel_size,
        "strides": 1,
        "padding": "same",
        "use_bias": True,
        "kernel_initializer": "he_normal"
    }

    x = layers.Conv2D(**params)(x)
    x = layers.BatchNormalization()(x)
    x = layers.ReLU()(x)

    return x

def classification_model(input_shape, output_size):
    inputs = layers.Input(input_shape)

    x = conv_batchnorm_relu(inputs, 64, 3)
    x = conv_batchnorm_relu(x, 64, 3)
    x = layers.MaxPooling2D(2, padding="same")(x)
    x = conv_batchnorm_relu(x, 128, 3)
    x = conv_batchnorm_relu(x, 128, 3)
    x = layers.MaxPooling2D(2, padding="same")(x)
    x = conv_batchnorm_relu(x, 256, 3)
    x = conv_batchnorm_relu(x, 256, 3)
    x = conv_batchnorm_relu(x, 256, 3)
    x = layers.MaxPooling2D(2, padding="same")(x)
    x = conv_batchnorm_relu(x, 512, 3)
    x = conv_batchnorm_relu(x, 512, 3)
    x = conv_batchnorm_relu(x, 512, 3)
    x = layers.MaxPooling2D(2, padding="same")(x)
    x = conv_batchnorm_relu(x, 512, 3)
    x = conv_batchnorm_relu(x, 512, 3)
    x = conv_batchnorm_relu(x, 512, 3)
    x = layers.MaxPooling2D(2, padding="same")(x)

    x = layers.Flatten()(x)
    x = layers.Dense(4096)(x)
    x = layers.Dense(4096)(x)

    outputs = layers.Dense(output_size, activation="softmax")(x)

    return model.Model(inputs=inputs, outputs=outputs)

def certification_model():
    pass

def make_model(images, labels):
    if model_type == "classification":
        make_classification_model(images, labels)
    else:
        make_certification_model(images, labels)

def make_classification_model(images, labels):
    input_shape = (128, 128, 1)
    output_size = max(labels) + 1

    train_datas = []
    for i in range(len(images)):
        train_datas.append({
            "image": images[i],
            "label": labels[i]
        })

    train_image, train_labels = separate_image_and_label(train_datas)
    model = classification_model(input_shape, output_size)

def make_certification_model(images, labels):
    print("certification model")

images = []
labels = []

# TODO: 筆跡のpathとラベルを取得
image_paths =
labels =

model = make_model(images, labels, users_num)
# model.save(RAILS_ROOT + "ml/" + )
