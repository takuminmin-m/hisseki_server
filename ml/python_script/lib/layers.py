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


class PreprocessLayer(layers.Layer):
    def __init__(self):
        super(PreprocessLayer, self).__init__()
        self.rescaling = layers.Rescaling(scale=1./255)
    def call(self, inputs):
        return self.rescaling(inputs)
