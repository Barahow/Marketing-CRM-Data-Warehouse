FROM astrocrpublic.azurecr.io/runtime:3.0-9

# copy dbt folder from airflow
COPY --chown=astro:0 ./dbt /usr/local/airflow/dbt

WORKDIR /usr/local/airflow
