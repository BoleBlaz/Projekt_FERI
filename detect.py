import mysql.connector
import io
import matplotlib.pyplot as plt
from PIL import Image
import numpy as np
import base64
import cv2
import matplotlib.pyplot as plt
from sklearn.svm import SVC
import random
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score
from sklearn.tree import DecisionTreeClassifier
import math
import time
import os


def izracunaj_hog(sivinska_slika, velikost_celice, velikost_bloka, segmenti):
    # Izračunamo gradient slike v smeri x
    #dobimo kak se inteziteta pikslov spreminja v x in y 
    gx = cv2.Sobel(sivinska_slika, cv2.CV_32F, 1, 0)
    
    # Izračunamo gradient slike v smeri y
    gy = cv2.Sobel(sivinska_slika, cv2.CV_32F, 0, 1)

    # Pretvorimo gradientne komponente v magnitudo in orientacijo
    magnituda, orientacija = cv2.cartToPolar(gx, gy, angleInDegrees=True)
    
    # Normaliziramo magnitudo na obseg med 0 in 1
    magnituda /= np.max(magnituda)
    
    # Pretvorimo orientacijo v stopinje in omejimo na obseg med 0 in 180 stopinj
    orientacija = np.rad2deg(orientacija) % 180

    # Pridobimo velikost sivinske slike
    visina, sirina = sivinska_slika.shape
    
    # Izračunamo število celic v vrstici in stolpcu
    stevilo_celic_v_vrstici = math.ceil(visina / velikost_celice)
    stevilo_celic_v_stolpcu = math.ceil(sirina / velikost_celice)

    # Izračunamo velikost histograma za posamezen blok
    velikost_histograma = velikost_bloka * velikost_bloka * segmenti

    # Inicializiramo prazno seznam za značilke HOG
    značilke = []

    # Zunanja zanka za celice v vrstici
    for y in range(stevilo_celic_v_vrstici - velikost_bloka + 1):
        # Notranja zanka za celice v stolpcu
        for x in range(stevilo_celic_v_stolpcu - velikost_bloka + 1):
            # Inicializiramo prazen histogram za blok
            blok_hist = np.zeros(velikost_histograma)

            # Zunanja zanka za iteriranje po celicah v bloku
            for i in range(velikost_bloka):
                for j in range(velikost_bloka):
                    # Pridobimo orientacije in magnitudo celic znotraj trenutnega bloka
                    celicne_orientacije = orientacija[y + i: y + i + velikost_celice, x + j: x + j + velikost_celice]
                    celicne_magnituda = magnituda[y + i: y + i + velikost_celice, x + j: x + j + velikost_celice]

                    # Izračunamo histogram za celice znotraj bloka
                    hist, _ = np.histogram(celicne_orientacije, bins=segmenti, range=(0, 180), weights=celicne_magnituda)

                    # Shranimo histogram v ustrezen del bloka_hist
                    blok_hist[i * velikost_bloka * segmenti + j * segmenti: (i * velikost_bloka * segmenti + j * segmenti) + segmenti] = hist
            
            # Dodamo blok_hist v seznam značilk
            značilke.append(blok_hist)
    
    # Združimo značilke v enoten enodimenzionalni niz in ga vrnemo
    return np.concatenate(značilke)


# Funkcija za izračun Lokalnega binarnega vzorca (LBP)
def lbp(slika):
    # Pridobimo število vrstic in stolpcev slike
    vrstice, stolpci = slika.shape
    
    # Ustvarimo prazno sliko enake velikosti kot vhodna slika
    lbp_slika = np.zeros((vrstice, stolpci), dtype=np.uint8)
    
    # Definiramo relativne koordinate osmih sosednjih pikslov
    sosedje = [(0, -1), (-1, -1), (-1, 0), (-1, 1), (0, 1), (1, 1), (1, 0), (1, -1)]
    
    # Zunanja zanka za vrstice (brez prve in zadnje vrstice)
    for r in range(1, vrstice - 1):
        # Notranja zanka za stolpce (brez prvega in zadnjega stolpca)
        for c in range(1, stolpci - 1):
            # Pridobimo vrednost sredinskega piksla trenutne pozicije
            sredinski_piksel = slika[r, c]
            
            # Inicializiramo prazen niz za binarni vzorec LBP
            binarni_vzorec = ""
            
            # Iteriramo skozi osmih sosednjih pikslov
            for premik in sosedje:
                # Razpakiramo koordinate premika
                x, y = premik
                
                # Pridobimo vrednost sosednjega piksla glede na trenutno pozicijo
                sosednji_piksel = slika[r + y, c + x]
                
                # Primerjamo vrednosti sosednjega piksla s sredinskim pikslom
                if sosednji_piksel >= sredinski_piksel:
                    # Če je vrednost sosednjega piksla večja ali enaka sredinskemu pikslu, dodamo "1" v binarni vzorec
                    binarni_vzorec += "1"
                else:
                    # Sicer dodamo "0" v binarni vzorec
                    binarni_vzorec += "0"
            
            # Pretvorimo binarni vzorec v decimalno obliko
            decimalni_vzorec = int(binarni_vzorec, 2)
            #print("Decimal",decimalni_vzorec)
            
            # Nastavimo vrednost decimalnega vzorca v sliko LBP na trenutni poziciji
            lbp_slika[r, c] = decimalni_vzorec
    
    # Izračunamo histogram LBP slikovnih vrednosti
    histogram, _ = np.histogram(lbp_slika.flatten(), bins=256, range=(0, 256-1))
    #print("Histogram LBP:", histogram)
    
    # Vrnemo histogram
    return histogram


def razdeli_podatke(podatki, razmerje):
    random.shuffle(podatki)
    velikost_train = int(len(podatki) * razmerje)
    train_mnozica = podatki[:velikost_train]
    test_mnozica = podatki[velikost_train:]
    return train_mnozica, test_mnozica


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

user_id = 1 # Replace with the actual image ID
query = f"SELECT image FROM images WHERE user_id = {user_id}"
cursor = connection.cursor()
cursor.execute(query)
rows = cursor.fetchall()

decoded_images = []

for row in rows:
    image_data = row[0] 
    decoded_image = base64.b64decode(image_data)
    decoded_images.append(decoded_image)


for i, image_data in enumerate(decoded_images):
    image = Image.open(io.BytesIO(image_data))

    cv_image = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)

    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    faces = face_cascade.detectMultiScale(cv_image, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))
    #print(len(decoded_images))
    print(f"Image {i+1}:")
    if len(faces) == 1:
        print("Face detected")
        face_detected = True
    else:
        print("No face detected")
        face_detected = False
        del decoded_images[i]  

    # Display the image
    print(len(decoded_images))
    #plt.imshow(image)
    #plt.axis('off')
    #plt.show()
'''
decoded_images = np.array(decoded_images)

hog_histograms = []
lbp_histograms = []

rows1, columns = 10, 10

for image in decoded_images:
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    cell_hog_histogram = izracunaj_hog(gray_image, 3, 4, 9)
    hog_histograms.append(cell_hog_histogram)
    cell_lbp_histogram = lbp(gray_image)
    lbp_histograms.append(cell_lbp_histogram)

X = np.concatenate((np.array(lbp_histograms), np.array(hog_histograms)), axis=1)
y = np.array([0] * (rows1 * columns))  # Assuming all images have the same label

train_X, test_X = razdeli_podatke(X, 0.95)
train_y, test_y = razdeli_podatke(y, 0.95)


svm = SVC()
svm.fit(train_X, train_y)
knn = KNeighborsClassifier()
knn.fit(train_X, train_y)
dt = DecisionTreeClassifier()
dt.fit(train_X, train_y)

svm_predictions = svm.predict(test_X)
knn_predictions = knn.predict(test_X)
dt_predictions = dt.predict(test_X)

print("Number of elements:", len(hog_histograms))
dt_accuracy = accuracy_score(test_y, dt_predictions)
print("Accuracy:", dt_accuracy)

'''
connection.close()
