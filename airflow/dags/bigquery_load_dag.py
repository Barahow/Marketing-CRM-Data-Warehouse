from google.oauth2 import service_account
from google.cloud import storage
from datetime import datetime
import os
import pandas as pd
from pathlib import Path

CRED_PATH = "/usr/local/airflow/secrets/gcs_key.json"
TMP_DIR = Path(__file__).parent.parent / "data" / "tmp"
TMP_DIR.mkdir(parents=True, exist_ok=True)

def get_gcs_client():
    if not Path(CRED_PATH).exists():
        raise FileNotFoundError(f"GCS key not found in container: {CRED_PATH}")
    creds = service_account.Credentials.from_service_account_file(CRED_PATH)
    return storage.Client(credentials=creds, project=creds.project_id)

def upload_csv_to_gcs(local_csv_path, bucket_name, gcs_folder):
    if not Path(local_csv_path).exists():
        raise FileNotFoundError(f"Local CSV not found: {local_csv_path}")
    df = pd.read_csv(local_csv_path)
    local_file = TMP_DIR / Path(local_csv_path).name
    df.to_csv(local_file, index=False)

    client = get_gcs_client()
    bucket = client.bucket(bucket_name)
    blob_path = f"{gcs_folder}/{datetime.now().strftime('%Y/%m/%d')}/{Path(local_csv_path).name}"
    blob = bucket.blob(blob_path)
    blob.upload_from_filename(str(local_file))
