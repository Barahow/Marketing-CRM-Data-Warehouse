from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.email import EmailOperator
from airflow.models import DagRun, Variable
from airflow.utils.state import State
from airflow.utils.session import provide_session
from datetime import datetime, timedelta,timezone
from typing import Optional

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime.now(timezone.utc) - timedelta(days=1),
    "retries": 0,
}
DAGS_TO_MONITOR = [
    "ga5_meta_ads_loader",
    "dbt_staging_run_dag",
    "dbt_marts_run_dag",
]

from typing import Optional
from sqlalchemy import desc
from sqlalchemy.orm import Session
from airflow.models import DagRun
from airflow.utils.session import provide_session

@provide_session
def get_last_dagrun(dag_id: str, session: Session | None = None) -> Optional[DagRun]:
    assert session is not None, "Airflow did not provide a session"
    return (
        session.query(DagRun)
        .filter(DagRun.dag_id == dag_id) # pyright: ignore[reportOptionalCall]
        .order_by(desc(DagRun.logical_date))
        .first()
    )

def check_dags(ti=None, **kwargs):
    failed_dags = []
    for dag_id in DAGS_TO_MONITOR:
        last_run = get_last_dagrun(dag_id)
        if not last_run:
            failed_dags.append(f"{dag_id}: no runs found")
            continue
        if last_run.state != State.SUCCESS:
            failed_dags.append(f"{dag_id}: last run state {last_run.state}")
    push_target = ti or kwargs.get("ti")
    if not push_target:
        raise RuntimeError("TaskInstance not available to push XCom")
    push_target.xcom_push(
        key="failed_dags",
        value="\n".join(failed_dags) if failed_dags else "All DAGs successful",
    )


with DAG(
    "monitoring_dag",
    default_args=default_args,
    schedule="@daily",
    catchup=False,
    description="Monitor main ETL DAGs and alert if failures detected",
) as dag:
    check_status = PythonOperator(
        task_id="check_pipeline_status",
        python_callable=check_dags,
    )

    alert = EmailOperator(
        task_id="send_alert",
        to=Variable.get("alert_email"),
        subject="Pipeline Monitoring Alert",
        html_content="{{ task_instance.xcom_pull(task_ids='check_pipeline_status', key='failed_dags') }}",
        trigger_rule="all_done",
    )

    check_status >> alert # type: ignore
