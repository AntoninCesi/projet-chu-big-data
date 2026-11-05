{{ config(
    materialized='table',
    partition_by={
      "field": "date_deces",
      "data_type": "date",
      "granularity": "year"
    },
    cluster_by=["code_departement", "sexe_decede"]
) }}

WITH deces_brut AS (
    SELECT
        CASE 
            WHEN UPPER(REPLACE(TRIM(CAST(sexe AS STRING)), '"', '')) IN ('1', 'M', 'H') THEN 'M'
            WHEN UPPER(REPLACE(TRIM(CAST(sexe AS STRING)), '"', '')) IN ('2', 'F') THEN 'F'
            ELSE 'Inconnu'
        END AS sexe_decede,
        COALESCE(
            SAFE_CAST(REPLACE(TRIM(CAST(date_naissance AS STRING)), '"', '') AS DATE),
            SAFE.PARSE_DATE('%Y-%m-%d', CONCAT(SUBSTR(REPLACE(TRIM(CAST(date_naissance AS STRING)), '"', ''), 1, 10), '-01')) ,
            SAFE.PARSE_DATE('%Y-%m-%d', CONCAT(SUBSTR(REPLACE(TRIM(CAST(date_naissance AS STRING)), '"', ''), 1, 4), '-01-01'))
        ) AS dt_naissance,
        COALESCE(
            SAFE_CAST(REPLACE(TRIM(CAST(date_deces AS STRING)), '"', '') AS DATE),
            SAFE.PARSE_DATE('%Y-%m-%d', CONCAT(SUBSTR(REPLACE(TRIM(CAST(date_deces AS STRING)), '"', ''), 1, 10), '-01')),
            SAFE.PARSE_DATE('%Y-%m-%d', CONCAT(SUBSTR(REPLACE(TRIM(CAST(date_deces AS STRING)), '"', ''), 1, 4), '-01-01'))
        ) AS dt_deces,
        REPLACE(TRIM(CAST(code_lieu_deces AS STRING)), '"', '') AS code_commune_insee,
        REPLACE(TRIM(CAST(numero_acte_deces AS STRING)), '"', '') AS numero_acte_deces
    FROM {{ source('chu_bronze', 'deces_insee') }}
)
SELECT
    FARM_FINGERPRINT(CONCAT(COALESCE(code_commune_insee, ''), '_', COALESCE(CAST(dt_deces AS STRING), ''), '_', COALESCE(numero_acte_deces, ''))) AS id_fait_deces,
    dt_deces AS date_deces,
    CAST(FORMAT_DATE('%Y%m%d', dt_deces) AS INT64) AS sk_date_deces,
    code_commune_insee,
    CASE
        WHEN STARTS_WITH(code_commune_insee, '97') OR STARTS_WITH(code_commune_insee, '98')
        THEN SUBSTR(code_commune_insee, 1, 3)
        ELSE SUBSTR(code_commune_insee, 1, 2)
    END AS code_departement,
    sexe_decede,
    DATE_DIFF(dt_deces, dt_naissance, YEAR) AS age_au_deces,
    1 AS nb_deces
FROM deces_brut
WHERE dt_deces IS NOT NULL
  AND (dt_naissance IS NULL OR DATE_DIFF(dt_deces, dt_naissance, YEAR) BETWEEN 0 AND 125)
QUALIFY ROW_NUMBER() OVER (PARTITION BY code_commune_insee, dt_deces, numero_acte_deces, sexe_decede ORDER BY dt_naissance) = 1