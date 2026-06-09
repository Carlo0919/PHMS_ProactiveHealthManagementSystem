from flask import Flask, request, jsonify
import tensorflow as tf
from tensorflow.keras.preprocessing.sequence import pad_sequences
import joblib
import numpy as np

# Initialize Flask app
app = Flask(__name__)

# Load the model and tokenizer
model = tf.keras.models.load_model("C:/flask_api/seq2seq_chatbot_final_model.h5")

tokenizer = joblib.load("C:/flask_api/tokenizer.pkl")

# Max sequence length (same as when the model was trained)
MAX_SEQUENCE_LENGTH = 225

# Define a function for model prediction
def predict_medical_advice(user_input):
    # Tokenize the user input and pad the sequence
    sequence = tokenizer.texts_to_sequences([user_input])
    padded_sequence = pad_sequences(sequence, maxlen=MAX_SEQUENCE_LENGTH, padding='post', truncating='post')

    # Predict the output
    prediction = model.predict([padded_sequence, padded_sequence])
    
    # Convert prediction (output) from sequence back to text (reverse of tokenization)
    predicted_sequence = np.argmax(prediction, axis=-1)
    predicted_text = tokenizer.sequences_to_texts(predicted_sequence)[0]

    return predicted_text

# Define the route to handle POST requests from Flutter app
@app.route('/predict_advice', methods=['POST'])
def predict():
    try:
        # Get the input data from the request
        data = request.get_json()
        symptoms = data['message']
        
        # Process the symptoms and get medical advice
        response = predict_medical_advice(symptoms)
        
        # Return the response in JSON format
        return jsonify({"response": response})
    
    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)
