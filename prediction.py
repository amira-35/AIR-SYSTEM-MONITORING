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
    [0,100],
    [101,120],
    [121,167],
    [168,206],
    [207,392]
    ]
tab_conc_pm25 = [
    [0,50],     
    [51,60],
    [61,75],
    [76,150],
    [151,250],
    [251,392]
    ]
tab_conc_pm10 = [
    [0,75],
    [76,150],
    [151,250],
    [251,350],
    [351,420],
    [421,600]
    ]
tab_conc_co = [
    [0,5],
    [6,10],
    [11,14.3],
    [14.4,17.8],
    [17.9,35],
    [36,58]
    ]
tab_conc_so2 = [
    [0,92],
    [93,350],
    [351,485],
    [486,797]
    ]
tab_conc_no2 = [
    [0,100],
    [101,400],
    [401,677],
    [678,1221],
    [1222,2349],
    [2350,3853]
    ]
# Charger les données depuis un fichier CSV (exemple)
chemin_fichier = 'C:\\Users\\Lina\\Desktop\\PFE\\Final_dataset.csv'
df = pd.read_csv(chemin_fichier, parse_dates=['Date'], index_col='Date')
df = df.sort_values('Date')

df.rename(columns = {'NOx':'NO2'}, inplace = True)
df.drop(['NH3'],axis=1,inplace=True)
df.drop(['City'],axis=1,inplace=True)
df.insert(1, 'longitude', pd.Series([]))
df.insert(2, 'latitude', pd.Series([]))
df.insert(11, 'Vitesse de vent', pd.Series([]))
df.insert(12, 'Direction de vent', pd.Series([]))

# Générer des valeurs aléatoires pour latitude et longitude
random_latitudes = np.random.uniform(36.5813, 36.8196, size=len(df))
random_longitudes = np.random.uniform(2.80218, 3.38548, size=len(df))

# Remplir les colonnes de latitude et de longitude avec les valeurs aléatoires
df['latitude'] = random_latitudes
df['longitude'] = random_longitudes

#API de vitesse et direction de vent
# Clé API OpenWeatherMap (remplacez 'YOUR_API_KEY' par votre clé réelle)

OWM_API_KEY = 'f0f3f8e319045782f907f8b0616bdb7f'

def get_wind_info(latitude, longitude):
    owm = OWM(OWM_API_KEY)
    mgr = owm.weather_manager()
    observation = mgr.weather_at_coords(latitude, longitude)
    weather = observation.weather
    wind_speed = weather.wind()['speed']  # Vitesse du vent en m/s
    wind_direction = weather.wind()['deg']  # Direction du vent en degrés
    return wind_speed, wind_direction

# Appliquer la fonction à chaque ligne du DataFrame
df[['wind_speed', 'wind_direction']] = df.apply(lambda row: get_wind_info(row['latitude'], row['longitude']), axis=1, result_type='expand')
        
        
#calcule d'AQI de chaque polluant
for index, row in df.iterrows():
    #o3
    for i, conc_range in enumerate(tab_conc_o3):
        if conc_range[0] <= row['O3'] <= conc_range[1]:
            o3 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (row['O3'] - conc_range[0]) + tab_AQI[i][0]
    #pm25
    for i, conc_range in enumerate(tab_conc_pm25):
        if conc_range[0] <= row['PM2.5'] <= conc_range[1]:
            pm25 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (row['PM2.5'] - conc_range[0]) + tab_AQI[i][0]
    #pm10
    for i, conc_range in enumerate(tab_conc_pm10):
        if conc_range[0] <= row['PM10'] <= conc_range[1]:
            pm10 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (row['PM10'] - conc_range[0]) + tab_AQI[i][0]
    #co
    for i, conc_range in enumerate(tab_conc_co):
        if conc_range[0] <= row['CO'] <= conc_range[1]:
            co = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (row['CO'] - conc_range[0]) + tab_AQI[i][0]
    #so2
    for i, conc_range in enumerate(tab_conc_o3):
        if conc_range[0] <= row['SO2'] <= conc_range[1]:
            so2 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (row['SO2'] - conc_range[0]) + tab_AQI[i][0]
    #no2
    for i, conc_range in enumerate(tab_conc_no2):
        if conc_range[0] <= row['NO2'] <= conc_range[1]:
            no2 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (row['NO2'] - conc_range[0]) + tab_AQI[i][0]
            
    df.at[index,'AQI'] = max(o3, pm25, pm10, co, so2)
    
#Classification
for index, row in df.iterrows():
    for i, conc_range in enumerate(tab_AQI):
        if tab_AQI[i][0] <= row['AQI'] <= tab_AQI[i][1]: 
            df.at[index,'Air_quality'] = i+1
'''
FIN DE PRE PRETRAITEMENT
'''

'''
APPLICATION DE L'ALGO LSTM
'''
''' 
#logistic regression
y = df['Air_quality']
X = df[['longitude','latitude', 'PM2.5', 'PM10', 'NO2', 'CO', 'SO2','O3']]
X_train, X_test, y_train, y_test = train_test_split(X, y,test_size=0.20,random_state=23)
# LogisticRegression
lreg = LogisticRegression(random_state=0)
lreg.fit(X_train, y_train)
# Prediction
y_pred = lreg.predict(X_test)

acc = accuracy_score(y_test, y_pred)
print("Logistic Regression model accuracy (in %):", acc*100)
'''

'''
# Créer un objet MinMaxScaler
scaler = MinMaxScaler(feature_range=(0, 1))
# Appliquer la normalisation aux données
df_normalisé = scaler.fit_transform(df)
y = df['Air_quality']
X = df[['longitude','latitude', 'PM2.5', 'PM10', 'NO2', 'CO', 'SO2','O3']]

# Séparation des données en ensemble d'entraînement et ensemble de test
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Redimensionner les données pour les rendre compatibles avec l'entrée de LSTM [samples, time steps, features]
X_train = np.reshape(X_train.values, (X_train.shape[0], 1, X_train.shape[1]))
X_test = np.reshape(X_test.values, (X_test.shape[0], 1, X_test.shape[1]))

# Créer le modèle LSTM
model = Sequential()
model.add(LSTM(50, input_shape=(X_train.shape[1], X_train.shape[2])))
model.add(Dense(1))  # Une seule sortie pour la qualité de l'air
model.compile(loss='mean_squared_error', optimizer='adam') #

# Entraîner le modèle
model.fit(X_train, y_train, epochs=10, batch_size=32, validation_data=(X_test, y_test), verbose=2)#epochs nb etiration sur l'ensemble de don
# Faire des prédictions sur l'ensemble de test
predictions = model.predict(X_test)

# Inverser la normalisation des prédictions
predictions = scaler.inverse_transform(predictions)

# Calculer l'erreur quadratique moyenne (RMSE)
rmse = np.sqrt(mean_squared_error(y_test, predictions))
print("RMSE:", rmse)#Plus le RMSE est faible, meilleure est la performance du modèle.

# Visualiser les prédictions par rapport aux valeurs réelles
plt.plot(y_test.index, y_test.values, label="Valeurs réelles", color='blue')
plt.plot(y_test.index, predictions, label="Prédictions", color='red')
plt.xlabel("Date")
plt.ylabel("Pollution")
plt.legend()
plt.show()
'''