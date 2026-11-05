{{ config(materialized='table') }}

WITH consultation_clean AS (
    SELECT
        SAFE_CAST(REPLACE(TRIM(CAST(Num_consultation AS STRING)), '"', '') AS INT64) AS id_fait_consult,
        REPLACE(TRIM(CAST(Id_patient AS STRING)), '"', '') AS id_patient_brut,
        CASE 
            WHEN LENGTH(REPLACE(TRIM(CAST(Id_prof_sante AS STRING)), '"', '')) = 8 
            THEN LPAD(REPLACE(TRIM(CAST(Id_prof_sante AS STRING)), '"', ''), 9, '0')
            ELSE REPLACE(TRIM(CAST(Id_prof_sante AS STRING)), '"', '')
        END AS id_prof_brut,
        UPPER(REPLACE(TRIM(CAST(Code_diag AS STRING)), '"', '')) AS code_diagnostic,
        SAFE_CAST(SUBSTR(REPLACE(TRIM(CAST(Date AS STRING)), '"', ''), 1, 10) AS DATE) AS date_consultation,
        SAFE_CAST(SUBSTR(REPLACE(TRIM(CAST(Heure_debut AS STRING)), '"', ''), 1, 8) AS TIME) AS heure_debut,
        SAFE_CAST(SUBSTR(REPLACE(TRIM(CAST(Heure_fin AS STRING)), '"', ''), 1, 8) AS TIME) AS heure_fin
    FROM {{ source('chu_bronze', 'consultation') }}
),
prescription_agg AS (
    SELECT
        SAFE_CAST(REPLACE(TRIM(CAST(Num_consultation AS STRING)), '"', '') AS INT64) AS id_fait_consult,
        COUNT(Code_CIS) AS nb_medicaments
    FROM {{ source('chu_bronze', 'prescription') }}
    GROUP BY 1
)
SELECT
    c.id_fait_consult,
    c.date_consultation,
    CAST(FORMAT_DATE('%Y%m%d', c.date_consultation) AS INT64) AS sk_date,
    TO_HEX(SHA256(c.id_patient_brut)) AS id_patient_source,
    TO_HEX(SHA256(c.id_prof_brut)) AS id_prof_sante,
    COALESCE(prof.id_organisation, 'LIBERAL_NON_RATTACHE') AS id_organisation,
    c.code_diagnostic,
    CAST(
        CASE 
            WHEN c.heure_debut IS NOT NULL AND c.heure_fin IS NOT NULL AND c.heure_fin >= c.heure_debut
            THEN TIME_DIFF(c.heure_fin, c.heure_debut, MINUTE)
            ELSE NULL
        END AS NUMERIC
    ) AS duree_consult_min,
    COALESCE(presc.nb_medicaments, 0) AS nb_medicaments,
    1 AS nb_consultations
FROM consultation_clean c
LEFT JOIN prescription_agg presc ON c.id_fait_consult = presc.id_fait_consult
LEFT JOIN {{ ref('stg_professionnel') }} prof ON TO_HEX(SHA256(c.id_prof_brut)) = prof.id_prof_sante
WHERE c.id_fait_consult IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY c.id_fait_consult ORDER BY c.date_consultation DESC) = 1