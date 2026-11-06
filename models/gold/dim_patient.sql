{{ config(materialized='table') }}

SELECT
    -1 AS sk_patient,
    'INCONNU' AS id_patient_source,
    'Inconnu' AS sexe,
    CAST(NULL AS INT64) AS age,
    'Inconnu' AS tranche_age

UNION ALL

SELECT
    ROW_NUMBER() OVER (ORDER BY id_patient_source) AS sk_patient,
    id_patient_source,
    sexe,
    age,
    tranche_age
FROM {{ ref('stg_patient') }}