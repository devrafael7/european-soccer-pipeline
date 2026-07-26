import sqlite3
from pathlib import Path

import boto3
import kagglehub # type: ignore
import pandas as pd
from botocore.exceptions import BotoCoreError, ClientError


BUCKET_NAME = "amzn-s3-esd-rafael"
S3_PREFIX = "raw"


def upload_to_s3(
    s3_client,
    local_file: Path,
    bucket_name: str,
    s3_key: str,
) -> None:
    """Envia um arquivo local para o Amazon S3."""

    try:
        s3_client.upload_file(
            Filename=str(local_file),
            Bucket=bucket_name,
            Key=s3_key,
        )

        print(f"  Enviado para s3://{bucket_name}/{s3_key}")

    except (BotoCoreError, ClientError) as error:
        raise RuntimeError(
            f"Erro ao enviar {local_file} para o S3"
        ) from error


def main() -> None:
    # Cliente do Amazon S3
    s3_client = boto3.client("s3")

    # Baixa o dataset do Kaggle
    dataset_path = Path(
        kagglehub.dataset_download("hugomathien/soccer")
    )

    print(f"Dataset baixado em: {dataset_path}")

    # Localiza automaticamente o SQLite
    sqlite_files = list(dataset_path.glob("*.sqlite"))

    if not sqlite_files:
        raise FileNotFoundError(
            f"Nenhum arquivo .sqlite encontrado em {dataset_path}"
        )

    database_path = sqlite_files[0]

    print(f"Banco encontrado: {database_path}")

    # Pasta temporária/local dos CSVs
    output_folder = Path("csv")
    output_folder.mkdir(parents=True, exist_ok=True)

    with sqlite3.connect(database_path) as connection:
        tables_query = """
            SELECT name
            FROM sqlite_master
            WHERE type = 'table'
              AND name NOT LIKE 'sqlite_%'
            ORDER BY name
        """

        tables = pd.read_sql_query(
            tables_query,
            connection,
        )

        for table_name in tables["name"]:
            print(f"\nExportando tabela: {table_name}")

            dataframe = pd.read_sql_query(
                f'SELECT * FROM "{table_name}"',
                connection,
            )

            file_name = f"{table_name}.csv"
            csv_path = output_folder / file_name

            dataframe.to_csv(
                csv_path,
                index=False,
                encoding="utf-8",
            )

            print(
                f"  {len(dataframe):,} linhas salvas em {csv_path}"
            )

            # Caminho final dentro do bucket
            s3_key = f"{S3_PREFIX}/{file_name}"

            upload_to_s3(
                s3_client=s3_client,
                local_file=csv_path,
                bucket_name=BUCKET_NAME,
                s3_key=s3_key,
            )

    print("\nExportação e upload concluídos.")


if __name__ == "__main__":
    main()