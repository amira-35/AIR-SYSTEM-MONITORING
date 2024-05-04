import random
import pandas as pd
from datetime import datetime
import time
from pyowm import OWM

# Clé API OpenWeatherMap (remplacez 'YOUR_API_KEY' par votre clé réelle)
OWM_API_KEY = 'f0f3f8e319045782f907f8b0616bdb7f'

# Fonction pour générer des coordonnées GPS aléatoires dans une zone géographique donnée
def generate_random_coordinates(latitude_range, longitude_range):
    latitude = random.uniform(latitude_range[0], latitude_range[1])
    longitude = random.uniform(longitude_range[0], longitude_range[1])
    return latitude, longitude

# Fonction pour obtenir la vitesse et la direction du vent à partir des coordonnées GPS
def get_wind_info(latitude, longitude):
    owm = OWM(OWM_API_KEY)
    mgr = owm.weather_manager()
    observation = mgr.weather_at_coords(latitude, longitude)
    weather = observation.weather
    wind_speed = weather.wind()['speed']  # Vitesse du vent en m/s
    wind_direction = weather.wind()['deg']  # Direction du vent en degrés
    return wind_speed, wind_direction

# Fonction pour simuler les données de qualité de l'air en temps réel et les sauvegarder dans un fichier CSV
def simulate_real_time_data(seconds, filename, latitude_range, longitude_range):
    columns = ['DateTime', 'Latitude', 'Longitude', 'NO2', 'CO', 'PM10', 'PM25', 'SO2', 'O3', 'Direction vent', 'Vitesse vent']
    df = pd.DataFrame(columns=columns)
    
    while True:
        latitude, longitude = generate_random_coordinates(latitude_range, longitude_range)
        
        # Obtenir la vitesse et la direction du vent
        wind_speed, wind_direction = get_wind_info(latitude, longitude)
        
        new_data = {
            'DateTime': datetime.now(),
            'Latitude': latitude,
            'Longitude': longitude,
            'NO2': random.uniform(0,400),
            'CO': random.uniform(0, 30),
            'PM10': random.uniform(0, 500),
            'PM25': random.uniform(0, 250),
            'SO2': random.uniform(0,500),
            'O3': random.uniform(0, 180),
            'Direction vent': wind_direction,
            'Vitesse vent': wind_speed
        }
        
        df = pd.concat([df, pd.DataFrame([new_data])], ignore_index=True)
        df.to_csv(filename, index=False)
        
        time.sleep(seconds)

# Exemple d'utilisation
latitude_range = (36.5813, 36.8196)
longitude_range = (2.80218, 3.38548)
simulate_real_time_data(1, 'donnees_air.csv', latitude_range, longitude_range)
