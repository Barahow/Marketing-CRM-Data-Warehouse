FROM astrocrpublic.azurecr.io/runtime:3.0-9

# Upgrade pip
RUN python -m pip install --upgrade pip

# Install dbt and SQLFluff
RUN pip install dbt-bigquery sqlfluff sqlfluff-templater-dbt

# Copy dbt folder
COPY --chown=astro:0 ./dbt /usr/local/airflow/dbt


# Copy secrets folder
COPY --chown=astro:0 ./secrets /usr/local/airflow/secrets


WORKDIR /usr/local/airflow
