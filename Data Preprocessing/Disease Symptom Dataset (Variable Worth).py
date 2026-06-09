file_path = r'C:\Users\khiew\Downloads\FYP Reduced Dataset_37.csv'
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
 
# Step 1: Load your dataset
data = pd.read_csv(file_path)
 
# Step 2: Separate your target variable (y) and features (X)
# Assuming your target variable is in the first column, and all other columns are features
y = data.iloc[:, 0]  # The first column is the target variable
X = data.iloc[:, 1:]  # All columns except the first one are features
 
# Step 3: Split the data into training and test sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)
 
# Step 4: Train a Random Forest Classifier
rf = RandomForestClassifier(n_estimators=100, random_state=42)
rf.fit(X_train, y_train)
 
# Step 5: Get Feature Importance from the trained model
importances = rf.feature_importances_
 
# Step 6: Create a DataFrame to display feature importance
importance_df = pd.DataFrame({
    'Feature': X.columns,
    'Importance': importances
})
 
# Step 7: Sort by importance (from high to low)
importance_df = importance_df.sort_values(by='Importance', ascending=False)
 
# Step 8: Save the sorted feature importance as an HTML file
importance_df.to_html("C:\\Users\\khiew\\Downloads\\Variable_Worth_of_Attributes.html", index=False)
 
# Step 9: Print a message indicating the file is saved
print("Variable Worth of Attributes has been saved as 'Variable_Worth_of_Attributes.html'")
