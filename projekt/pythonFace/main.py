from keras.datasets import cifar10
from matplotlib import pyplot as plt
import numpy as np
from skimage.feature import local_binary_pattern
from skimage.feature import hog
from skimage import color
from sklearn.preprocessing import normalize


def razdeli_podatke(x, y, test_ratio=0.2, random_seed=42):
    np.random.seed(random_seed)
    num_samples = len(x)
    indices = np.random.permutation(num_samples)
    num_test_samples = int(test_ratio * num_samples)
    test_indices = indices[:num_test_samples]
    train_indices = indices[num_test_samples:]
    x_train = x[train_indices]
    y_train = y[train_indices]
    x_test = x[test_indices]
    y_test = y[test_indices]
    
    return (x_train, y_train), (x_test, y_test)


(x_train, y_train), (x_test, y_test) = cifar10.load_data()


(x_train, y_train), (x_test, y_test) = razdeli_podatke(x_train, y_train, test_ratio=0.2, random_seed=42)


print("Training set shape:", x_train.shape)


print("Testing set shape:", x_test.shape)
example_image = x_train[0]  
example_label = y_train[0]  
plt.imshow(example_image)
plt.title(f"CIFAR-10 Example\nLabel: {example_label}")
plt.axis('off')
plt.show()
