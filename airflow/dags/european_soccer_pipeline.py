import pendulum

from airflow.sdk import dag, task
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.standard.operators.bash import BashOperator

#use this dag for ec2 build
@dag(
    dag_id="european_soccer_pipeline",
    description="Pipeline completa do European Soccer Database",
    schedule=None,
    start_date=pendulum.datetime(
        2026,
        7,
        1,
        tz="America/Sao_Paulo",
    ),
    catchup=False,
    tags=[
        "kaggle",
        "aws",
        "s3",
        "snowflake",
        "dbt",
        "soccer",
    ],
)
def european_soccer_pipeline():

    @task(task_id="ingest_kaggle_to_s3")
    def ingest_kaggle_to_s3() -> None:
        from scripts.ingest import main

        main()

    load_s3_to_snowflake = SQLExecuteQueryOperator(
        task_id="load_s3_to_snowflake",
        conn_id="snowflake_default",
        sql="sql/load_s3_to_snowflake.sql",
        split_statements=True,
        autocommit=True,
    )

    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command="""
            dbt deps\
            --project-dir /opt/airflow/dbt/europan_soccer_dbt \
            --profiles-dir /home/airflow/.dbt &&

            dbt build \
            --project-dir /opt/airflow/dbt/europan_soccer_dbt \
            --profiles-dir /home/airflow/.dbt
        """,
    )

    ingest_task = ingest_kaggle_to_s3()

    ingest_task >> load_s3_to_snowflake >> dbt_build


european_soccer_pipeline()
