import base64
import io
import json
from matplotlib import pyplot as plt
from PIL import Image
import numpy as np
from numpy import asarray
from scipy.spatial.distance import cosine
from mtcnn.mtcnn import MTCNN
from keras_vggface.vggface import VGGFace
from keras_vggface.utils import preprocess_input
import mysql.connector


def extract_face(image, required_size=(224, 224)):
    pixels = np.array(image)
    # create the detector, using default weights
    detector = MTCNN()
    # detect faces in the image
    results = detector.detect_faces(pixels)

    # check if any faces were detected
    if len(results) == 0:
        # no faces detected, handle this error case (e.g., return None)
        return None

    # extract the bounding box from the first face
    x1, y1, width, height = results[0]['box']
    x2, y2 = x1 + width, y1 + height

    # extract the face
    face = image.crop((x1, y1, x2, y2))
    # resize pixels to the model size
    face = face.resize(required_size)
    face_array = asarray(face)
    return face_array



def get_embeddings(images):
    # extract faces
    faces = [extract_face(img) for img in images]
    # filter out None elements
    faces = [f for f in faces if f is not None]

    # convert into an array of samples
    samples = asarray(faces, 'float32')
    # prepare the face for the model, e.g., center pixels
    samples = preprocess_input(samples, version=2)

    # create a vggface model
    model = VGGFace(model='resnet50', include_top=False,
                    input_shape=(224, 224, 3), pooling='avg')
    # perform prediction
    embeddings = model.predict(samples)
    return embeddings

# determine if a candidate face is a match for a known face


def is_match(known_embedding, candidate_embedding, thresh=0.5):
    # calculate distance between embeddings
    score = cosine(known_embedding.flatten(), candidate_embedding.flatten())
    if score <= thresh:
        print('>face is a Match (%.3f <= %.3f)' % (score, thresh))
        return True
    else:
        print('>face is NOT a Match (%.3f > %.3f)' % (score, thresh))
        return False
    
host = "212.44.101.98"
username = "beofle38_blazbole"
password = "Dropshipping2022"
dbname = "beofle38_feri_projekt"

connection = mysql.connector.connect(
    host=host,
    user=username,
    password=password,
    database=dbname
)

user_id = 1
query = f"SELECT image FROM imagesLogin WHERE user_id = {2}"
cursor = connection.cursor()
cursor.execute(query)
rows1 = cursor.fetchall()
cursor.close()
test_images = []

for row in rows1:
    image_data = row[0]
    test_img = Image.open(io.BytesIO(base64.b64decode(image_data)))
    test_images.append(test_img)

test_image = test_images[0]    
plt.imshow(test_image)
plt.axis('off')
plt.show()

query = f"SELECT knn_model FROM faces WHERE user_id = {user_id}"
cursor = connection.cursor()
cursor.execute(query)
result = cursor.fetchone()
blob_data = result[0]
print(len(blob_data))
embeddings_train = np.frombuffer(blob_data, dtype=np.float32)
print(len(embeddings_train))
embeddings_train = embeddings_train.reshape((20, -1))
print(len(embeddings_train))

embeddings_test = get_embeddings([test_image])
match_images = 0
for embedding in embeddings_train:
    isMatch = is_match(embedding, embeddings_test[0])
    if(isMatch == True):
       match_images+=1
       
accuracy = (match_images/len(embeddings_train))*100
formatted_accuracy = "{:.2f}".format(accuracy)
print("Accuracy: " + formatted_accuracy + "%")
if(accuracy >= 70):
   print("Ujemanje")
else:
    print("Neujemanje")

#cursor.close()
connection.close()