# PHMS_ProactiveHealthManagementSystem

The Proactive Health Management System (PHMS) is a mobile health chatbot application built with Flutter and Flask-based REST APIs. All predictions and responses are generated on-the-fly by querying pre-trained models — no database required.

The app operates in three modes. Mode 1 handles disease prediction using multi-class classification on 66 binary symptom inputs, with NLP preprocessing via spaCy for natural language and synonym normalization. Multiple models were trained and evaluated for this task, including XGBoost, Random Forest, and K-Nearest Neighbors (KNN), but the Deep Neural Network (DNN) delivered the best overall accuracy and was selected for deployment. A LabelEncoder maps numeric outputs back to disease names, and a symptom frequency chart is returned as a base64-encoded image.

Mode 2 is a medical advice chatbot built on a Sequence-to-Sequence Encoder-Decoder architecture. Recurrent models including RNN and LSTM variants were trained and compared, with the LSTM-based model achieving superior performance and selected as the final model. It accepts tokenized medical text queries (up to 225 tokens) and generates contextual medical advice locally without external API dependency.

Mode 3 integrates OpenAI ChatGPT (GPT-3.5-turbo) for general-purpose health inquiries beyond the scope of the local trained models.
