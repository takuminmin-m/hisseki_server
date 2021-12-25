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


model_type = sys.argv[1]
if model_type != "classification" and model_type != "certification":
    raise Exception("Unexpected commandline arguments")

RAILS_ROOT = str(pathlib.Path(__file__).resolve().parents[2])


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

def conv_batchnorm_relu(x, filters, kernel_size):
    params = {
        "filters": filters,
        "kernel_size": kernel_size,
        "strides": 1,
        "padding": "same",
        "use_bias": True,
        "kernel_initializer": "he_normal",
        "kernel_regularizer": regularizers.l2(0.001)
    }

    x = layers.Conv2D(**params)(x)
    # x = layers.BatchNormalization()(x)
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
    x = layers.Dense(2048)(x)
    x = layers.Dense(2048)(x)
    x = layers.Dense(1024)(x)
    x = layers.Dense(1024)(x)

    outputs = layers.Dense(output_size, activation="softmax")(x)
    model = models.Model(inputs=inputs, outputs=outputs)

    model.summary()
    keras.utils.plot_model(model, RAILS_ROOT + "/ml/classification_model_plot.png", show_shapes=True)

    return model

def certification_model():
    pass

def make_model(images, labels):
    if model_type == "classification":
        make_classification_model(images, labels)
    else:
        make_certification_model(images, labels)

def make_classification_model(images, labels):
    input_shape = (128, 128, 1)
    labels = list(map(int, labels))
    output_size = max(labels) + 1

    datas = []
    for i in range(len(images)):
        datas.append({
            "image": images[i],
            "label": labels[i]
        })

    random.shuffle(datas)
    train_datas, validation_datas = split(datas, 0.1)
    train_images, train_labels = separate_image_and_label(train_datas)
    validation_images, validation_labels = separate_image_and_label(validation_datas)

    train_images = np.array(train_images)
    train_labels = np.array(train_labels)
    validation_images = np.array(validation_images)
    validation_labels = np.array(validation_labels)

    model = classification_model(input_shape, output_size)
    model.compile(
        optimizer=optimizers.Adam(learning_rate=1e-4),
        loss=losses.SparseCategoricalCrossentropy(),
        metrics=["accuracy"]
    )

    model.fit(train_images, train_labels, epochs=50, validation_data=(validation_images, validation_labels))
    model.save(RAILS_ROOT + "/ml/hisseki_classification.tf")

def make_certification_model(images, labels):
    print("certification model")


labels, image_paths = read_csv(RAILS_ROOT + "/ml/hisseki_list.csv")
images = list(map(load_and_preprocess_image, image_paths))

model = make_model(images, labels)
# model.save(RAILS_ROOT + "ml/" + )
