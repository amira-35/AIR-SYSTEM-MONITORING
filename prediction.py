import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import pyowm
from pyowm import OWM
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from keras.models import Sequential
from keras.layers import LSTM, Dense
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
from sklearn.preprocessing import MinMaxScaler
import seaborn as sns

#pretraitement
#declaration de tableaux de conc de chaque polluant
tab_AQI = [
    [0,50],
    [51,100],
    [101,150],
    [151,200],
    [201,300],
    [301,500]
    ]
tab_conc_o3 = [
    [0,20],
    [21,45],
    [46,90],
    [91,120],
    [121,200]
    ]
tab_conc_pm25 = [
    [0,100],
    [101,180],
    [181,400],
    [401,600],
    [601,800],
    [801,1000]
    ]
tab_conc_pm10 = [
    [0,125],
    [126,220],
    [221,500],
    [501,600],
    [601,800],
    [801,1000]
    ]
tab_conc_co = [
    [0,2],
    [3,5],
    [6,10],
    [11,20],
    [21,25],
    [26,30]
    ]
tab_conc_so2 = [
    [0,22],
    [93,100],
    [351,150],
    [486,200]
    ]
tab_conc_no2 = [
    [0,30],
    [31,50],
    [51,75],
    [76,150],
    [151,250],
    [251,400]
    ]
# Charger les données depuis un fichier CSV (exemple)
chemin_fichier = 'C:\\Users\\Lina\\Desktop\\PFE\\dataKaggle\\station_hour.csv'
df = pd.read_csv(chemin_fichier)
df.drop(['StationId', 'NO', 'NOx', 'NH3', 'Benzene', 'Toluene', 'Xylene', 'AQI_Bucket'],axis=1,inplace=True)
f.insert(1, 'longitude', pd.Series([]))
df.insert(2, 'latitude', pd.Series([]))
import numpy as np
# Remplir les colonnes de latitude et de longitude avec une valeur
df.loc[:, 'latitude'] = 36.722388
df.loc[:, 'longitude'] = 3.180213
 
#inserer la vitesse et la direction de vent
df.insert(9, 'Vitesse de vent', pd.Series([]))
df.insert(10, 'Direction de vent', pd.Series([]))
#Générer des valeurs aléatoires
random_vitesse = np.random.uniform(1, 80, size=len(df))
random_direction = np.random.uniform(0, 360, size=len(df))
# Remplir les colonnes de latitude et de longitude avec les valeurs aléatoires
df['Vitesse de vent'] = random_vitesse
df['Direction de vent'] = random_direction


plt.figure(figsize=(6, 6))
sns.boxplot(y='PM2.5', data=df, color='skyblue')
plt.ylabel('PM2.5')
plt.title('Box Plot of PM2.5')
plt.show()

plt.figure(figsize=(6, 6))
sns.boxplot(y='PM10', data=df, color='red')
plt.ylabel('PM10')
plt.title('Box Plot of PM10')
plt.show()

plt.figure(figsize=(6, 6))
sns.boxplot(y='NO2', data=df, color='skyblue')
plt.ylabel('NO2')
plt.title('Box Plot of NO2')
plt.show()

plt.figure(figsize=(6, 6))
sns.boxplot(y='CO', data=df, color='red')
plt.ylabel('CO')
plt.title('Box Plot of CO')
plt.show()

plt.figure(figsize=(6, 6))
sns.boxplot(y='SO2', data=df, color='skyblue')
plt.ylabel('SO2')
plt.title('Box Plot of SO2')
plt.show()

plt.figure(figsize=(6, 6))
sns.boxplot(y='O3', data=df, color='red')
plt.ylabel('O3')
plt.title('Box Plot of O3')
plt.show()

#remplir les valeurs manquantes
import numpy as np
valeurs_pm25 = np.random.uniform(0, 400, size=len(df))
valeurs_pm25_series = pd.Series(valeurs_pm25)
df['PM2.5'].fillna(valeurs_pm25_series, inplace=True)

valeurs_pm10 = np.random.uniform(0, 1000, size=len(df))
valeurs_pm10_series = pd.Series(valeurs_pm10)
df['PM10'].fillna(valeurs_pm10_series, inplace=True)

valeurs_no2 = np.random.uniform(0, 500, size=len(df))
valeurs_no2_series = pd.Series(valeurs_no2)
df['NO2'].fillna(valeurs_no2_series, inplace=True)

valeurs_co = np.random.uniform(0, 500, size=len(df))
valeurs_co_series = pd.Series(valeurs_co)
df['CO'].fillna(valeurs_co_series, inplace=True)

valeurs_so2 = np.random.uniform(0, 200, size=len(df))
valeurs_so2_series = pd.Series(valeurs_so2)
df['SO2'].fillna(valeurs_so2_series, inplace=True)

valeurs_o3 = np.random.uniform(0, 1000, size=len(df))
valeurs_o3_series = pd.Series(valeurs_o3)
df['O3'].fillna(valeurs_o3_series, inplace=True)

#remplir AQI
for index, row in df.iterrows():
    pm25 =0
    #o3
    for i, conc_range in enumerate(tab_conc_o3):
        if conc_range[0] <= row['O3'] <= conc_range[1]:
            o3 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (row['O3'] - conc_range[0]) + tab_AQI[i][0]
            break
    #pm25
    for i, conc_range in enumerate(tab_conc_pm25):
        if conc_range[0] <= row['PM2.5'] <= conc_range[1]:
            pm25 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (row['PM2.5'] - conc_range[0]) + tab_AQI[i][0]
            break
    #pm10
    for i, conc_range in enumerate(tab_conc_pm10):
        if conc_range[0] <= row['PM10'] <= conc_range[1]:
            pm10 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (row['PM10'] - conc_range[0]) + tab_AQI[i][0]
            break
    #co
    for i, conc_range in enumerate(tab_conc_co):
        if conc_range[0] <= row['CO'] <= conc_range[1]:
            co = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (row['CO'] - conc_range[0]) + tab_AQI[i][0]
            break
    #so2
    for i, conc_range in enumerate(tab_conc_o3):
        if conc_range[0] <= row['SO2'] <= conc_range[1]:
            so2 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (row['SO2'] - conc_range[0]) + tab_AQI[i][0]
            break
    #no2
    for i, conc_range in enumerate(tab_conc_no2):
        if conc_range[0] <= row['NO2'] <= conc_range[1]:
            no2 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (row['NO2'] - conc_range[0]) + tab_AQI[i][0]
            break

    df.at[index,'AQI'] = max(o3, pm25, pm10, co, so2, no2)

#Classification
for index, row in df.iterrows():
    for i, conc_range in enumerate(tab_AQI):
        if tab_AQI[i][0] <= row['AQI'] <= tab_AQI[i][1]:
            df.at[index,'Air_quality'] = i+1

'''LSTM'''

#x et y
features = df.drop(['AQI','Air_quality','Datetime'], axis=1)
label = df['Air_quality']

# Convert pandas DataFrame to NumPy array
features_array = features.values
label_array = label.values

# Convert labels to one-hot encoded format
label_array = to_categorical(label_array)

# Scale features to range [0, 1] Normalisation
scaler = MinMaxScaler(feature_range=(0, 1))
scaled_features = scaler.fit_transform(features_array)
# Reshape to 3D array (batch_size, timesteps, input_dim)
scaled_features = np.reshape(scaled_features, (scaled_features.shape[0], 1, scaled_features.shape[1]))
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense

# Define the LSTM model
model = Sequential()
model.add(LSTM(50, return_sequences=True, input_shape=(scaled_features.shape[1], scaled_features.shape[2])))
model.add(LSTM(5, return_sequences=True))
model.add(LSTM(5,return_sequences=False))
model.add(Dense(7, activation='softmax'))
model.compile(loss='categorical_crossentropy', optimizer='adam',metrics=['accuracy'])# Fit the model
from sklearn.model_selection import train_test_split
from tensorflow.keras.callbacks import TensorBoard
import pickle


# Split the data into a training set and a test set
features_train, features_test, label_train, label_test = train_test_split(scaled_features, label_array, test_size=0.2, random_state=39)

import tensorflow as tf
# Créez un callback TensorBoard
tensorboard_callback = TensorBoard(log_dir='drive/My Drive/saved models', histogram_freq=1, write_graph=True)

# Entraînez le modèle sur l'ensemble d'entraînement
history = model.fit(features_train, label_train, epochs=25, batch_size=72, validation_split=0.2, shuffle=False, callbacks=[tensorboard_callback])
# Évaluation du modèle
evaluation_results = model.evaluate(features_test, label_test)

# Affichage des résultats de l'évaluation
print("Loss:", evaluation_results[0])
print("Accuracy:", evaluation_results[1])

# Make predictions on the test set
predictions = model.predict(features_test)

# Convert predictions and true labels to class labels
predicted_classes = np.argmax(predictions, axis=1)
true_classes = np.argmax(label_test, axis=1)

# Visualize the predictions vs the true values
plt.figure(figsize=(14, 7))
plt.plot(predicted_classes[:100], 'r', marker='o', linestyle='-', label='Prédictions')
plt.plot(true_classes[:100], 'b', marker='x', linestyle='--', label='Valeurs réelles')
plt.title('Comparaison des Prédictions et des Valeurs Réelles')
plt.xlabel('Index des Échantillons')
plt.ylabel('Classes')
plt.legend()
plt.show()