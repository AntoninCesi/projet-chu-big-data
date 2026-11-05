"""
Job 4 - Ingestion des décès INSEE -> couche Bronze (chargement local)

Charge deces.csv tel quel dans chu_bronze.deces_raw.
Couche Bronze : aucune transformation, toutes les colonnes en STRING
(le schéma est celui de la table créée par create_deces_raw.sql).

Solution temporaire en attendant l'accès à NiFi : même résultat que le flux
ListFile -> FetchFile -> PutBigQuery prévu dans les fiches ETL.

Utilisation (venv activé) :
    python bronze/load_deces.py "C:/chemin/vers/deces.csv"
"""

import os
import sys
import time

from google.cloud import bigquery
from google.oauth2 import service_account

# --- Configuration ----------------------------------------------------------
PROJECT_ID = "big-data-cloud-healthcare-unit"
LOCATION = "europe-west9"  # région Paris, conformité HDS
TABLE_ID = f"{PROJECT_ID}.chu_bronze.deces_raw"

# La clé reste HORS du dépôt Git (même fichier que pour dbt)
KEY_PATH = os.environ.get(
    "GCP_KEY_PATH",
    os.path.expanduser("~/.dbt/big-data-cloud-healthcare-unit-43dee4b8c31a.json"),
)


def main() -> None:
    if len(sys.argv) != 2:
        print('Usage : python bronze/load_deces.py "chemin/vers/deces.csv"')
        sys.exit(1)

    csv_path = sys.argv[1]
    if not os.path.isfile(csv_path):
        print(f"Fichier introuvable : {csv_path}")
        sys.exit(1)

    credentials = service_account.Credentials.from_service_account_file(KEY_PATH)
    client = bigquery.Client(
        credentials=credentials, project=PROJECT_ID, location=LOCATION
    )

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,          # ligne d'en-tête
        field_delimiter=",",
        encoding="UTF-8",
        autodetect=False,             # on garde le schéma STRING de la table
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,  # rechargement complet
        max_bad_records=1000,         # lignes mal formées tolérées, listées à la fin
    )

    taille_mo = os.path.getsize(csv_path) / 1024 / 1024
    print(f"Envoi de {csv_path} ({taille_mo:.0f} Mo) vers {TABLE_ID}...")
    debut = time.time()

    with open(csv_path, "rb") as fichier:
        job = client.load_table_from_file(fichier, TABLE_ID, job_config=job_config)

    print(f"Fichier envoyé, chargement en cours dans BigQuery (job {job.job_id})...")
    job.result()  # attend la fin du chargement

    table = client.get_table(TABLE_ID)
    print(f"Terminé en {time.time() - debut:.0f} s : {table.num_rows} lignes dans {TABLE_ID}")

    if job.errors:
        print(f"{len(job.errors)} ligne(s) rejetée(s). Premières erreurs :")
        for erreur in job.errors[:10]:
            print(" -", erreur.get("message"))


if __name__ == "__main__":
    main()
