from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import os
import pandas as pd

# Default DAG arguments
default_args = {
    'owner': 'you',
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Function to read CRM CSVs locally
def load_crm_csv_locally(**kwargs):
    LOCAL_CSV_DIR = "../data/crm"  # folder containing crm_contacts.csv and crm_orders.csv

    data = {}
    for filename in os.listdir(LOCAL_CSV_DIR):
        if filename.endswith(".csv"):
            local_path = os.path.join(LOCAL_CSV_DIR, filename)
            df = pd.read_csv(local_path)
            data[filename] = df
            print(f"Loaded {filename}, shape: {df.shape}")

    return data

# DAG definition
with DAG(
    'crm_csv_loader',
    default_args=default_args,
    description='Read CRM CSV files locally',
    schedule='@daily',
    start_date=datetime(2025, 8, 25),
    catchup=False,
) as dag:



    load_task = PythonOperator(
        task_id='load_crm_csv',
        python_callable=load_crm_csv_locally
    )
