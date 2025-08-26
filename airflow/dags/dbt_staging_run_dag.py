from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.utils.trigger_rule import TriggerRule
from datetime import datetime, timedelta

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2025, 8, 25),
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    "dbt_staging_run_dag",
    default_args=default_args,
    description="Run dbt staging models after raw data load",
    schedule=None,  # run only when triggered
    catchup=False,
) as dag:

    # run dbt staging models
    run_dbt_staging = BashOperator(
        task_id="run_dbt_staging",
        bash_command="cd /usr/local/airflow/dbt/etl_models && dbt run --select staging+",
    )

    # run dbt tests to validate staging models
    test_dbt_staging = BashOperator(
        task_id="test_dbt_staging",
        bash_command="cd /usr/local/airflow/dbt/etl_models && dbt test --select staging+",
        trigger_rule=TriggerRule.ALL_SUCCESS,  # only run tests if run_dbt_staging succeeds
    )

    run_dbt_staging >> test_dbt_staging
