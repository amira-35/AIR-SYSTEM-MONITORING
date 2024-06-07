from flask import Flask, request, jsonify
import numpy as np
import tensorflow as tf
from sklearn.preprocessing import MinMaxScaler
import joblib

app = Flask(__name__)

# Chargement du modèle LSTM
model = tf.keras.models.load_model('lstm_model2.h5')

# Charger le scaler
scaler = joblib.load("scaler.save")

# Route pour la prédiction
@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json(force=True)
        
        # Extraction des features de la requête
        features = np.array(data['features'])
        
        # Vérification des dimensions des features
        if features.shape != (24, 6):
            return jsonify({'error': 'The input must be a list of 24 lists, each containing exactly 6 features.'}), 400
        
        # Normalisation des features
        scaled_features = scaler.transform(features)
        
        # Reshape pour correspondre à l'entrée du modèle LSTM (1, 24, 6)
        scaled_features = scaled_features.reshape((1, 24, 6))
        
        # Génération de 50 prédictions itératives
        num_predictions = 168
        predictions = []

        for _ in range(num_predictions):
            prediction = model.predict(scaled_features)
            predicted_class = int(np.argmax(prediction, axis=1)[0])  # Convertir en type Python natif
            predictions.append(predicted_class)
            
            # Ajouter la prédiction comme nouvelle feature pour la prochaine itération
            new_feature = np.zeros((1, 1, 6))
            new_feature[0, 0, 0] = predicted_class  # Remplir avec la classe prédite
            scaled_features = np.concatenate((scaled_features[:, 1:, :], new_feature), axis=1)

        return jsonify({'predictions': predictions})
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True)
