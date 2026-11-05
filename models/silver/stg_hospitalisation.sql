{{ config(materialized='table') }}

SELECT
    SAFE_CAST(REPLACE(TRIM(CAST(Num_Hospitalisation AS STRING)), '"', '') AS INT64) AS id_fait_hospit,
    TO_HEX(SHA256(REPLACE(TRIM(CAST(Id_patient AS STRING)), '"', ''))) AS id_patient_source,
    REPLACE(TRIM(CAST(identifiant_organisation AS STRING)), '"', '') AS id_organisation,
    UPPER(REPLACE(TRIM(CAST(Code_diagnostic AS STRING)), '"', '')) AS code_diagnostic,
    REPLACE(TRIM(CAST(Suite_diagnostic_consultation AS STRING)), '"', '') AS libelle_diagnostic,
    SAFE.PARSE_DATE('%d/%m/%Y', SUBSTR(REPLACE(TRIM(CAST(Date_Entree AS STRING)), '"', ''), 1, 10)) AS date_entree,
    CAST(FORMAT_DATE('%Y%m%d', SAFE.PARSE_DATE('%d/%m/%Y', SUBSTR(REPLACE(TRIM(CAST(Date_Entree AS STRING)), '"', ''), 1, 10))) AS INT64) AS sk_date_entree,
    SAFE_CAST(REPLACE(TRIM(CAST(Jour_Hospitalisation AS STRING)), '"', '') AS INT64) AS nb_jours_hospit,
    1 AS nb_hospitalisations
FROM {{ source('chu_bronze', 'hospitalisations') }}
WHERE Num_Hospitalisation IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_fait_hospit ORDER BY date_entree DESC) = 1