from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
from google.cloud import storage
import os
import pandas as pd

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2025, 8, 25),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

def upload_csv_to_gcs(local_csv_path, bucket_name, gcs_folder):
    """Generic function to upload CSV to GCS."""
    df = pd.read_csv(local_csv_path)
    os.makedirs("data/tmp", exist_ok=True)
    local_file = f"data/tmp/{os.path.basename(local_csv_path)}"
    df.to_csv(local_file, index=False)

    client = storage.Client()
    bucket = client.get_bucket(bucket_name)
    blob_path = f"{gcs_folder}/{datetime.now().strftime('%Y/%m/%d')}/{os.path.basename(local_csv_path)}"
    blob = bucket.blob(blob_path)
    blob.upload_from_filename(local_file)

def simulate_ga4_api_to_gcs(**kwargs):
    upload_csv_to_gcs("../data/ga4.csv", "ga4-meta-crm-bucket", "raw/ga4")

def simulate_meta_api_to_gcs(**kwargs):
    upload_csv_to_gcs("../data/meta_ads.csv", "ga4-meta-crm-bucket", "raw/meta")

with DAG(
    'ga5_meta_ads_loader',
    default_args=default_args,
    description='Load CRM CSV files to GCS',
    schedule='@daily',  # replace schedule_interval
    start_date=datetime(2025, 8, 25),
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

     # run GA4 first, then Meta Ads

    meta_task.set_upstream(ga4_task)
    ga4_task.set_downstream(meta_task)
