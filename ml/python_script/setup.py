import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, optimizers, losses

import os
import numpy as np
import random
import matplotlib.pyplot as plt
import pathlib

import lib

AUTOTUNE = tf.data.experimental.AUTOTUNE
