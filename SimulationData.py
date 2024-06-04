import random
import pandas as pd
from datetime import datetime
import time
from pyowm import OWM
import firebase_admin
from firebase_admin import credentials, db

# Initialisation de Firebase avec un fichier de clé JSON
cred = credentials.Certificate(r'C:\Users\pc\Desktop\AIR-SYSTEM-MONITORING\sdkey.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://air-pollution-database-default-rtdb.europe-west1.firebasedatabase.app/'
})

# Clé API OpenWeatherMap (remplacez 'YOUR_API_KEY' par votre clé réelle)
OWM_API_KEY = 'f0f3f8e319045782f907f8b0616bdb7f'

# Fonction pour générer des coordonnées GPS aléatoires dans une zone géographique donnée
def generate_random_coordinates(latitude_range, longitude_range):
    latitude = random.uniform(latitude_range[0], latitude_range[1])
    longitude = random.uniform(longitude_range[0], longitude_range[1])
    return latitude, longitude
#calculer l'aqi pour chaque polluant 
def calculate_aqi(no2, co, pm10, pm25, so2, o3):
    tab_AQI = [
        [0, 50],
        [51, 100],
        [101, 150],
        [151, 200],
        [201, 300],
        [301, 500]
    ]
    tab_conc_o3 = [
        [0, 100],
        [101, 120],
        [121, 167],
        [168, 206],
        [207, 392]
    ]
    tab_conc_pm25 = [
        [0, 50],
        [51, 60],
        [61, 75],
        [76, 150],
        [151, 250],
        [251, 392]
    ]
    tab_conc_pm10 = [
        [0, 75],
        [76, 150],
        [151, 250],
        [251, 350],
        [351, 420],
        [421, 600]
    ]
    tab_conc_co = [
        [0, 5],
        [6, 10],
        [11, 14.3],
        [14.4, 17.8],
        [17.9, 35],
        [36, 58]
    ]
    tab_conc_so2 = [
        [0, 92],
        [93, 350],
        [351, 485],
        [486, 797]
    ]
    tab_conc_no2 = [
        [0, 100],
        [101, 400],
        [401, 677],
        [678, 1221],
        [1222, 2349],
        [2350, 3853]
    ]
    # O3
    for i, conc_range in enumerate(tab_conc_o3):
        if conc_range[0] <= o3 <= conc_range[1]:
            o3 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (o3 - conc_range[0]) + tab_AQI[i][0]
    # PM25
    for i, conc_range in enumerate(tab_conc_pm25):
        if conc_range[0] <= pm25 <= conc_range[1]:
            pm25 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (pm25 - conc_range[0]) + tab_AQI[i][0]
    # PM10
    for i, conc_range in enumerate(tab_conc_pm10):
        if conc_range[0] <= pm10 <= conc_range[1]:
            pm10 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (pm10 - conc_range[0]) + tab_AQI[i][0]
    # CO
    for i, conc_range in enumerate(tab_conc_co):
        if conc_range[0] <= co <= conc_range[1]:
            co = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (co - conc_range[0]) + tab_AQI[i][0]
    # SO2
    for i, conc_range in enumerate(tab_conc_so2):
        if conc_range[0] <= so2 <= conc_range[1]:
            so2 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (so2 - conc_range[0]) + tab_AQI[i][0]
    # NO2
    for i, conc_range in enumerate(tab_conc_no2):
        if conc_range[0] <= no2 <= conc_range[1]:
            no2 = (tab_AQI[i][1] - tab_AQI[i][0]) / (conc_range[1] - conc_range[0]) * (no2 - conc_range[0]) + tab_AQI[i][0]

    return max(o3, pm25, pm10, co, so2, no2)
#classifier l'aqi 
def assign_aqi_category(aqi):
    if aqi <= 50:
        return 1
    elif aqi <= 100:
        return 2
    elif aqi <= 150:
        return 3
    elif aqi <= 200:
        return 4
    elif aqi <= 300:
        return 5
    elif (aqi <= 500) or (aqi >= 500)  :
        return 6
   
# Improved error handling
def send_data_to_firebase(data):
    try:
        ref = db.reference('/Region')
        ref.push(data)
        print("Data successfully sent to Firebase!")
    except Exception as e:
        print(f"Error sending data to Firebase: {e}")

# Fonction pour obtenir la vitesse et la direction du vent à partir des coordonnées GPS
def get_weather_info(latitude, longitude):
    owm = OWM(OWM_API_KEY)
    mgr = owm.weather_manager()
    observation = mgr.weather_at_coords(latitude, longitude)
    weather = observation.weather
    wind_speed = weather.wind()['speed']  # Vitesse du vent en m/s
    wind_direction = weather.wind()['deg']  # Direction du vent en degrés
    humidity = weather.humidity  # Humidité en pourcentage
    temperature = weather.temperature('celsius')['temp']  # Température en degrés Celsius
    return wind_speed, wind_direction, humidity, temperature

# Fonction pour simuler les données de qualité de l'air en temps réel et les sauvegarder dans un fichier CSV
def simulate_real_time_data(seconds, filename, latitude_range, longitude_range):
    columns = ['DateTime', 'Latitude', 'Longitude', 'NO2', 'CO', 'PM10', 'PM25', 'SO2', 'O3', 'Direction vent', 'Vitesse vent', 'Humidité', 'Température']
    df = pd.DataFrame(columns=columns)
    
    while True:
        latitude, longitude = generate_random_coordinates(latitude_range, longitude_range)
        
        # Obtenir les informations météorologiques
        wind_speed, wind_direction, humidity, temperature = get_weather_info(latitude, longitude)
         
        # Générer des données aléatoires de pollution
        no2 = round(random.uniform(0, 100), 2)
        co = round(random.uniform(0, 20), 2)
        pm10 = round(random.uniform(0, 100), 2)
        pm25 = round(random.uniform(0, 100), 2)
        so2 = round(random.uniform(0, 100), 2)
        o3 = round(random.uniform(0, 100), 2)
        # Calculer l'aqi globale 
        aqiglob = round(calculate_aqi(o3, pm25, pm10, co, so2, no2), 2)
        aqicat = assign_aqi_category(aqiglob)
        new_data = {
            "DateTime": datetime.now().isoformat(),
            "Latitude": latitude,
            "Longitude": longitude,
            "NO2": no2,
            "CO": co,
            "PM10": pm10,
            "PM25": pm25,
            "SO2": so2,
            "O3": o3,
            "Direction vent": wind_direction,
            "Vitesse vent": wind_speed,
            "Humidité": humidity,
            "Température": temperature,
            "AQI": aqiglob,
            "AQI Category": aqicat,
        }
        
        df = pd.concat([df, pd.DataFrame([new_data])], ignore_index=True)
        df.to_csv(filename, index=False)
        send_data_to_firebase(new_data)
        time.sleep(2)

# Exemple d'utilisation
latitude_range = (36.5813, 36.8196)
longitude_range = (2.80218, 3.38548)
simulate_real_time_data(1, 'donnees_air.csv', latitude_range, longitude_range)
