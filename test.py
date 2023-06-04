import pickle
import cv2
from matplotlib import pyplot as plt
import numpy as np
import mysql.connector
import base64
from PIL import Image
import io
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score

host = "212.44.101.98"
username = "beofle38_blazbole"
password = "Dropshipping2022"
dbname = "beofle38_feri_projekt"

# Establish the database connection
connection = mysql.connector.connect(
    host=host,
    user=username,
    password=password,
    database=dbname
)

# Retrieve the serialized model from the database
user_id = 1  # Replace with the actual user ID
query = "SELECT knn_model FROM faces WHERE user_id = %s"
cursor = connection.cursor()
cursor.execute(query, (user_id,))
result = cursor.fetchone()
knn_model_bytes = result[0]

knn = pickle.loads(knn_model_bytes)

# Retrieve the images from the imageLogin table
query = "SELECT image FROM imagesLogin WHERE user_id = %s"
cursor.execute(query, (2,))
results = cursor.fetchall()

test_X = []
test_y = []

for row in results:
    image_data = row[0]
    decoded_image = base64.b64decode(image_data)
    image = Image.open(io.BytesIO(decoded_image))
    image_array = np.array(image)
    #resized_image = cv2.resize(image_array, (2, 4736))  # Replace width and height with the desired dimensions
    gray_image = cv2.cvtColor(image_array, cv2.COLOR_BGR2GRAY)
    gray_image_1d = gray_image.flatten()  # Flatten to 1D array
    test_X.append(gray_image_1d)
    test_y.append(user_id)


# Make predictions using the KNN model
predictions = knn.predict(test_X)

# Calculate accuracy
accuracy = accuracy_score(test_y, predictions)
print("Accuracy:", accuracy)

# Compare predictions with images
'''for i, image in enumerate(test_X):
    plt.imshow(image)
    plt.axis('off')
    plt.title(f"Prediction: {predictions[i]}, Actual: {test_y[i]}")
    plt.show()'''

cursor.close()
connection.close()
