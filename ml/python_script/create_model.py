import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, optimizers, losses

import os
import sys
import numpy as np
import random
import matplotlib.pyplot as plt
import pathlib

import ml_tools

model_type = sys.argv[1]
if model_type == "classification":
    from classification_model import *
elif model_type == "certification":
    from certification_model import *
else:
    raise Exception("Unexpected commandline arguments")

RAILS_ROOT = str(pathlib.Path(__file__).resolve().parents[2])


AUTOTUNE = tf.data.experimental.AUTOTUNE

images = []
labels = []

model = make_model(images, labels)
# model.save(RAILS_ROOT + "ml/" + )
