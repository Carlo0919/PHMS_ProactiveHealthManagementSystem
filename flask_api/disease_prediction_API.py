from flask import Flask, request, jsonify
import numpy as np
import tensorflow as tf
import spacy
import joblib
import pandas as pd
import matplotlib.pyplot as plt
import io
import base64

# Load dataset at startup
df = pd.read_csv("C:\\flask_api\\FYP Augmented (Secondly) Dataset.csv") 

# Load spaCy's pre-trained English model for NLP
nlp = spacy.load('en_core_web_sm')

app = Flask(__name__)

# Load your trained model (make sure to set the correct path to your model)
model = tf.keras.models.load_model("C:\\flask_api\\best_dnn_model.h5")

# Load the saved LabelEncoder
label_encoder = joblib.load("C:\\flask_api\\label_encoder.pkl")

# List of symptoms (binary variables)
symptoms = [
    'headache', 'vomiting', 'cough', 'sharp abdominal pain', 'sharp chest pain',
    'nausea', 'fever', 'dizziness', 'back pain', 'shortness of breath', 'weakness',
    'sore throat', 'lower abdominal pain', 'leg pain', 'nasal congestion',
    'burning abdominal pain', 'problems with movement', 'depressive or psychotic symptoms',
    'skin swelling', 'skin rash', 'difficulty speaking', 'side pain', 'ache all over',
    'abnormal appearing skin', 'pelvic pain', 'chest tightness', 'peripheral edema',
    'abusing alcohol', 'lip swelling', 'diarrhea', 'insomnia', 'skin growth', 'fatigue',
    'loss of sensation', 'ear pain', 'allergic reaction', 'arm pain', 'neck pain',
    'lower body pain', 'difficulty breathing', 'skin lesion', 'abnormal involuntary movements',
    'depression', 'itching of skin', 'facial pain', 'decreased appetite', 'fainting', 'feeling ill',
    'heartburn', 'involuntary urination', 'difficulty in swallowing', 'retention of urine',
    'anxiety and nervousness', 'blood in stool', 'vaginal itching', 'joint pain', 'disturbance of memory',
    'hip pain', 'shoulder pain', 'low back pain', 'knee pain', 'acne or pimples', 'symptoms of eye',
    'foot or toe pain', 'frequent urination', 'lack of growth', 'intermenstrual bleeding', 'diminished vision',
    'painful urination', 'palpitations', 'vaginal discharge', 'hand or finger swelling', 'suprapubic pain', 'coryza'
]

# Mapping common variations or related words to symptoms
synonym_map = {
    'sick': 'fever',
    'ill': 'feeling ill',
    'pee frequently': 'frequent urination',
    'urinate often': 'frequent urination',
    'skin itchy': 'itching of skin',
    'back ache': 'back pain',
    'head pain': 'headache',
    'vomit': 'vomiting',
    'coughing': 'cough',
    'nauseous': 'nausea',
    'exhausted': 'fatigue',
    'tired': 'fatigue',
    'gasp': 'shortness of breath',
    'dizzy': 'dizziness',
    'cold': 'fever',
    'shivering': 'fever',
    'loss feeling':'loss of sensation',
    'numbed':'loss of sensation',
    'chest pain': 'sharp chest pain',
    'abdominal pain': 'sharp abdominal pain',
    'leg pain': 'leg pain',
    'throat pain': 'sore throat',
    'allergic': 'allergic reaction',
    'unable to speak': 'difficulty speaking',
    'pain in leg': 'leg pain',    
    'pain in back': 'back pain',
    'pain in chest': 'sharp chest pain',    
    'pain in abdomen': 'sharp abdominal pain',
    'pain in neck': 'neck pain',    
    'pain in shoulder': 'shoulder pain',
    'unable to move': 'problems with movement',
    'alcohol addiction': 'abusing alcohol',
    'depression': 'depressive or psychotic symptoms',
    'lost of appetite': 'decreased appetite',
    'sadness': 'depressive or psychotic symptoms',
    'flu':'nasal congestion',
    'abdominal discomfort': 'sharp abdominal pain',
    'discomfort':'feeling ill',
    'anxious': 'anxiety and nervousness',
    'tension': 'anxiety and nervousness',
    'rapid heartbeat': 'palpitations',
    'fast-beating': 'palpitations',
    'pounding heartbeat': 'palpitations',
    'racing heart': 'palpitations',
    'forgetfulness': 'disturbance of memory',
    'memory loss': 'disturbance of memory',
    'amnesia': 'disturbance of memory',
    'sneezing': 'coryza',
}

# Function to process the user's message and map it to binary input
def process_message(message):
    binary_input = np.zeros(len(symptoms))  # Initialize array with zeros
    
    lower_message = message.lower()  # Lowercase for matching
    detected_symptoms = []

    # Check for direct symptom matches or synonyms
    for idx, symptom in enumerate(symptoms):
        if symptom in lower_message:
            binary_input[idx] = 1  # Mark symptom as present
            detected_symptoms.append(symptom)
        else:
            # Check for synonyms in the synonym map
            for key, value in synonym_map.items():
                if key in lower_message and value == symptom:
                    binary_input[idx] = 1  # Mark synonym-based symptom as present
                    detected_symptoms.append(symptom)

    return binary_input, detected_symptoms


# Disease prediction endpoint
@app.route('/predict_disease', methods=['POST'])

def predict():
    print("🔵 Received a request!")

    data = request.get_json(force=True)
    print(f"📩 Received JSON: {data}")

    if not data or 'message' not in data:
        print("❗ Missing 'message' in data")
        return jsonify({'error': 'No message provided'}), 400

    message = data['message']
    print(f"📝 Symptoms text: {message}")

    # Process the message into binary input and get detected symptoms
    binary_input, detected_symptoms = process_message(message)
    num_symptoms_present = int(np.sum(binary_input))

    # 🔥 Check if enough symptoms are provided
    if num_symptoms_present < 3:
        print("⚠️ Not enough symptoms provided")
        return jsonify({
            'error': '⚠️Please provide at least 3 symptoms for a more accurate prediction.',
            'symptoms_detected': num_symptoms_present
        }), 400

    binary_input = np.expand_dims(binary_input, axis=0)  # Model expects 2D array

    # Predict using the model
    prediction = model.predict(binary_input)
    predicted_class = np.argmax(prediction, axis=1)[0]

    # Map back to disease name
    predicted_label = label_encoder.inverse_transform([predicted_class])[0]

    print(f"✅ Predicted Class ID: {predicted_class}")
    print(f"🏥 Predicted Disease Name: {predicted_label}")

    chart_base64, total_cases = generate_chart(predicted_label)

    # Return the response with detected symptoms and predicted disease
    return jsonify({
        'disease_id': int(predicted_class),
        'disease_name': predicted_label,
        'symptoms_detected': detected_symptoms,
        'symptom_chart_base64': chart_base64,
        'total_cases': total_cases
    })

def generate_chart(disease_name):
    filtered = df[df['diseases'] == disease_name]
    symptom_counts = {}
    for symptom in symptoms:
        if symptom in filtered.columns:
            count = filtered[symptom].sum()
            if count > 0:
                symptom_counts[symptom] = int(count)

    if not symptom_counts:
        return None, 0

    # Sorting symptoms by count for better color gradient mapping
    sorted_symptoms = sorted(symptom_counts.items(), key=lambda x: x[1], reverse=True)
    symptom_names = [item[0] for item in sorted_symptoms]
    symptom_values = [item[1] for item in sorted_symptoms]

    # Normalize counts between 0 and 1 for coloring
    counts_array = np.array(symptom_values)
    norm = (counts_array - counts_array.min()) / (counts_array.max() - counts_array.min() + 1e-6)

    # Generate colors: from green (low) to red (high)
    colors = plt.cm.RdYlGn_r(norm)  # Reverse Green-Red colormap (_r means reversed)

    fig, ax = plt.subplots(figsize=(10, 5))
    bars = ax.bar(symptom_names, symptom_values, color=colors)

    # Add count labels on top of each bar
    for bar, value in zip(bars, symptom_values):
        ax.text(
            bar.get_x() + bar.get_width() / 2, 
            bar.get_height() + 0.5,  # Slightly above bar
            str(value),
            ha='center', 
            va='bottom',
            fontsize=8
        )

    plt.xticks(rotation=90)
    plt.title(f"Symptoms Frequency for {disease_name}", fontsize=14)
    plt.xlabel("Symptoms", fontsize=12)
    plt.ylabel("Count", fontsize=12)
    plt.tight_layout()

    # Save to base64
    img_buf = io.BytesIO()
    plt.savefig(img_buf, format='png', dpi=200)
    img_buf.seek(0)
    encoded_img = base64.b64encode(img_buf.read()).decode('utf-8')
    plt.close()

    return encoded_img, sum(symptom_counts.values())

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)

