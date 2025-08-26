from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
from google.cloud import storage
from google.oauth2 import service_account
from pathlib import Path
import os
import pandas as pd
import hashlib

CRED_PATH = "/usr/local/airflow/secrets/gcs_key.json"

script_dir = os.path.dirname(os.path.abspath(__file__))
ga4_path = os.path.join(script_dir, '..', 'data', 'ga4_expanded.csv')
meta_ads_path = os.path.join(script_dir, '..', 'data', 'meta_ads.csv')

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2025, 8, 25),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

def get_gcs_client():
    if not Path(CRED_PATH).exists():
        raise FileNotFoundError(f"Key missing in container: {CRED_PATH}")
    creds = service_account.Credentials.from_service_account_file(CRED_PATH)
    return storage.Client(credentials=creds, project=creds.project_id)

def compute_file_hash(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def upload_csv_to_gcs_if_changed(local_csv_path: str, bucket_name: str, gcs_folder: str):
    """
    Upload local_csv_path to bucket_name under gcs_folder/<YYYY/MM/DD>/filename only if file content changed.
    Maintain a metadata hash file at gcs_folder/.hashes/<filename>.sha256 to track last upload.
    """
    # prepare local tmp copy (preserve existing logic)
    df = pd.read_csv(local_csv_path)
    os.makedirs("data/tmp", exist_ok=True)
    local_file = os.path.join("data", "tmp", os.path.basename(local_csv_path))
    df.to_csv(local_file, index=False)

    client = get_gcs_client()
    bucket = client.bucket(bucket_name)

    filename = os.path.basename(local_csv_path)
    meta_blob_path = f"{gcs_folder}/.hashes/{filename}.sha256"
    meta_blob = bucket.blob(meta_blob_path)

    current_hash = compute_file_hash(local_file)

    # read previous hash if present
    previous_hash = None
    try:
        if meta_blob.exists():
            previous_hash = meta_blob.download_as_text().strip()
    except Exception:
        # avoid failing the task on metadata read errors; treat as no previous hash
        previous_hash = None

    if previous_hash == current_hash:
        print(f"No change detected for {filename}; skipping upload.")
        return False

    # upload new dated file (keeps historical copies)
    dated_blob_path = f"{gcs_folder}/{datetime.utcnow().strftime('%Y/%m/%d')}/{filename}"
    dated_blob = bucket.blob(dated_blob_path)
    dated_blob.upload_from_filename(local_file)
    print(f"Uploaded {local_file} -> gs://{bucket_name}/{dated_blob_path}")

    # update metadata hash file
    try:
        meta_blob.upload_from_string(current_hash)
        print(f"Updated hash metadata at gs://{bucket_name}/{meta_blob_path}")
    except Exception as e:
        print(f"Warning: failed to update metadata hash file: {e}")

    return True

def simulate_ga4_api_to_gcs(**kwargs):
    upload_csv_to_gcs_if_changed(ga4_path, "ga4-meta-crm-bucket", "raw/ga4")

def simulate_meta_api_to_gcs(**kwargs):
    upload_csv_to_gcs_if_changed(meta_ads_path, "ga4-meta-crm-bucket", "raw/meta")

with DAG(
    'ga5_meta_ads_loader',
    default_args=default_args,
    description='Load CRM CSV files to GCS',
    schedule='@daily',
    catchup=False,
) as dag:

    ga4_task = PythonOperator(
        task_id='simulate_ga4_api_to_gcs',
        python_callable=simulate_ga4_api_to_gcs
    )

    meta_task = PythonOperator(
        task_id='simulate_meta_api_to_gcs',
        python_callable=simulate_meta_api_to_gcs
    )

meta_task.set_upstream(ga4_task)
