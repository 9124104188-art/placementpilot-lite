import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd

# ----------- CONFIG ------------

CSV_FILE = 'final.csv'  # <-- set your CSV filename here
SERVICE_ACCOUNT_FILE = 'placementpilot-lite-firebase-adminsdk-fbsvc-d592232b2f.json'

# ----------- INIT FIREBASE ------------

cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
firebase_admin.initialize_app(cred)
db = firestore.client()

# ----------- READ CSV ------------

df = pd.read_csv(CSV_FILE)

for _, row in df.iterrows():
    # Split options string on commas, strip whitespace
    options = [option.strip() for option in str(row['options']).split(',')]

    # Prep Firestore data
    q_data = {
        'question': row['Question'],
        'options': options,
        'correctAnswer': row['Correct Answer'],
        'difficulty': int(row['Difficulty']),
        'category': row['Category'],
    }
    # Upload to Firestore
    db.collection('questions').add(q_data)
    print('Uploaded:', q_data['question'])

print('All questions uploaded!')