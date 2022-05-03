import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, optimizers, losses, regularizers, callbacks

import os
import sys
import numpy as np
import random
import matplotlib.pyplot as plt
import pathlib
import csv

from lib.functions import *
from lib.layers import *


model_type = sys.argv[1]
if model_type != "classification" and model_type != "certification":
    raise Exception("Unexpected commandline arguments")

RAILS_ROOT = str(pathlib.Path(__file__).resolve().parents[2])


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

def classification_model(image_input_shape, behavior_input_shape, output_size):
    image_inputs = layers.Input(image_input_shape, name="image")
    behavior_inputs = layers.Input(shape=behavior_input_shape, dtype=tf.float32, ragged=True, name="behavior")

    x = conv_batchnorm_relu(image_inputs, 64, 3)
    x = conv_batchnorm_relu(x, 64, 3)
    x = layers.MaxPooling2D(2, padding="same")(x)
    x = layers.Dropout(0.2)(x)
    x = conv_batchnorm_relu(x, 128, 3)
    x = conv_batchnorm_relu(x, 128, 3)
    x = layers.MaxPooling2D(2, padding="same")(x)
    x = layers.Dropout(0.2)(x)
    x = conv_batchnorm_relu(x, 256, 3)
    x = conv_batchnorm_relu(x, 256, 3)
    x = conv_batchnorm_relu(x, 256, 3)
    x = layers.MaxPooling2D(2, padding="same")(x)
    x = layers.Dropout(0.2)(x)
    x = conv_batchnorm_relu(x, 512, 3)
    x = conv_batchnorm_relu(x, 512, 3)
    x = conv_batchnorm_relu(x, 512, 3)
    x = layers.MaxPooling2D(2, padding="same")(x)
    x = layers.Dropout(0.2)(x)
    x = conv_batchnorm_relu(x, 512, 3)
    x = conv_batchnorm_relu(x, 512, 3)
    x = conv_batchnorm_relu(x, 512, 3)
    x = layers.MaxPooling2D(2, padding="same")(x)
    x = layers.Dropout(0.2)(x)
    x = layers.Flatten()(x)

    behavior_layers = models.Sequential([
        layers.GRU(20, activation="tanh"),
        layers.Dense(128, activation="relu"),
    ])

    encoded_behavior_input = behavior_layers(behavior_inputs)

    x = layers.concatenate([x, encoded_behavior_input])
    x = layers.Dense(2048)(x)
    x = layers.Dense(2048)(x)
    x = layers.Dense(1024)(x)
    x = layers.Dense(1024)(x)

    outputs = layers.Dense(output_size, activation="softmax")(x)
    model = models.Model(inputs=(image_inputs, behavior_inputs), outputs=outputs)

    model.summary()
    keras.utils.plot_model(model, RAILS_ROOT + "/ml/classification_model_plot.png", show_shapes=True)

    return model

def certification_model(image_input_shape, output_size):
    image1_input = keras.Input(shape=image_input_shape, name="image1")
    image2_input = keras.Input(shape=image_input_shape, name="image2")
    params = {
        "activation": "relu",
        "padding": "same"
    }

    shared_layers = keras.Sequential([
        layers.Conv2D(64, (3, 3), **params),
        layers.Conv2D(64, (3, 3), **params),
        layers.MaxPooling2D((2, 2)),
        # layers.Dropout(0.2),
        layers.Conv2D(128, (3, 3), **params),
        layers.Conv2D(128, (3, 3), **params),
        # layers.Dropout(0.2),
        layers.MaxPooling2D((2, 2)),
        layers.Conv2D(256, (3, 3), **params),
        layers.Conv2D(256, (3, 3), **params),
        layers.Conv2D(256, (3, 3), **params),
        layers.MaxPooling2D((2, 2)),
        # layers.Dropout(0.2),
        layers.Conv2D(512, (3, 3), **params),
        layers.Conv2D(512, (3, 3), **params),
        layers.Conv2D(512, (3, 3), **params),
        layers.MaxPooling2D((2, 2)),
        # layers.Dropout(0.2),
        layers.Conv2D(512, (3, 3), **params),
        layers.Conv2D(512, (3, 3), **params),
        layers.Conv2D(512, (3, 3), **params),
        layers.MaxPooling2D((2, 2)),
        # layers.Dropout(0.2),
        layers.Flatten()
    ])

    encoded_image1_input = shared_layers(image1_input)
    encoded_image2_input = shared_layers(image2_input)

    x = layers.concatenate([encoded_image1_input, encoded_image2_input])
    x = layers.Dense(4096, activation="relu")(x)
    x = layers.Dense(4096, activation="relu")(x)
    x = layers.Dense(4096, activation="relu")(x)
    x = layers.Dense(2048, activation="relu")(x)
    x = layers.Dense(2048, activation="relu")(x)
    x = layers.Dense(2048, activation="relu")(x)
    certification_pred = layers.Dense(output_size, activation="softmax")(x)

    model = models.Model(
        inputs=[image1_input, image2_input],
        outputs=[certification_pred]
    )

    model.summary()
    keras.utils.plot_model(model, RAILS_ROOT + "/ml/certification_model_plot.png", show_shapes=True)

    return model

def make_model(images, writing_behaviors, labels):
    if model_type == "classification":
        make_classification_model(images, writing_behaviors, labels)
    else:
        make_certification_model(images, writing_behaviors, labels)

def make_classification_model(images, writing_behaviors, labels):
    image_input_shape = (128, 128, 1)
    behavior_input_shape = (None, 1)
    labels = list(map(int, labels))
    output_size = max(labels) + 1

    datas = []
    for i in range(len(images)):
        datas.append({
            "image": images[i],
            "behavior": writing_behaviors[i],
            "label": labels[i]
        })


    random.shuffle(datas)
    train_datas, validation_datas = split(datas, 0.1)
    train_images, train_behaviors, train_labels = separate_image_and_behaviors_and_label(train_datas)
    validation_images, validation_behaviors, validation_labels = separate_image_and_behaviors_and_label(validation_datas)

    train_images = np.array(train_images)
    train_labels = np.array(train_labels)
    train_behaviors = np.array(train_behaviors)
    validation_images = np.array(validation_images)
    validation_labels = np.array(validation_labels)
    validation_behaviors = np.array(validation_behaviors)

    train_images = tf.convert_to_tensor(train_images)
    train_labels = tf.convert_to_tensor(train_labels)
    train_behaviors = tf.ragged.constant(train_behaviors)
    validation_images = tf.convert_to_tensor(validation_images)
    validation_labels = tf.convert_to_tensor(validation_labels)
    validation_behaviors = tf.ragged.constant(validation_behaviors)


    model = classification_model(image_input_shape, behavior_input_shape, output_size)
    model.compile(
        optimizer=optimizers.Adam(learning_rate=1e-4),
        loss=losses.SparseCategoricalCrossentropy(),
        metrics=["accuracy"]
    )

    model.fit(
        {"image": train_images, "behavior": train_behaviors},
        train_labels,
        epochs=50,
        validation_data=({"image": validation_images, "behavior": validation_behaviors}, validation_labels)
    )
    model.save(RAILS_ROOT + "/ml/hisseki_classification.tf")

def make_certification_model(images, labels):
    image_input_shape = (128, 128, 1)
    labels = list(map(int, labels))
    output_size = 2

    datas = []
    for i in range(len(images)):
        for j in range(len(images)):
            if labels[i] == labels[j]:
                datas.append({
                    "image1": images[i],
                    "image2": images[j],
                    "label": 1
                })
            else:
                datas.append({
                    "image1": images[i],
                    "image2": images[j],
                    "label": 0
                })

    random.shuffle(datas)
    train_datas, validation_datas = split(datas, 0.1)
    train_datas = datas
    train_images1, train_images2, train_labels = separate_2images_and_label(train_datas)
    validation_images1, validation_images2, validation_labels = separate_2images_and_label(validation_datas)

    train_images1 = np.array(train_images1)
    train_images2 = np.array(train_images2)
    train_labels = np.array(train_labels)
    validation_images1 = np.array(validation_images1)
    validation_images2 = np.array(validation_images2)
    validation_labels = np.array(validation_labels)

    model = certification_model(image_input_shape, output_size)
    model.compile(
        optimizer=optimizers.Adam(learning_rate=1e-4),
        loss=losses.SparseCategoricalCrossentropy(),
        metrics=["accuracy"]
    )
    early_stopping = callbacks.EarlyStopping(
        monitor="val_loss",
        min_delta=1.0e-8,
        patience=5,
        mode="min"
    )

    model.fit(
        {"image1": train_images1, "image2": train_images2},
        train_labels,
        epochs=50,
        validation_data=({"image1": validation_images1, "image2": validation_images2}, validation_labels),
        callbacks=[early_stopping]
    )
    model.save(RAILS_ROOT + "/ml/hisseki_certification.tf")


labels, image_paths, writing_behaviors = read_csv(RAILS_ROOT + "/ml/hisseki_list.csv")
for value in writing_behaviors:
    print(len(value))

images = list(map(load_and_preprocess_image, image_paths))
writing_behaviors = list(map(preprocess_writing_behavior, writing_behaviors))

# images = np.array(images)
writing_behaviors = np.array(writing_behaviors)

model = make_model(images, writing_behaviors, labels)

print("create_model.py: done")
