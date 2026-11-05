{{ config(
    materialized='table',
    partition_by={
      "field": "date_consultation",
      "data_type": "date",
      "granularity": "month"
    },
    cluster_by=["id_organisation", "code_diagnostic", "id_prof_sante"]
) }}

WITH consultation_clean AS (
    SELECT
        CAST(Num_consultation AS INT64) AS id_fait_consult,
        TRIM(CAST(Id_patient AS STRING)) AS id_patient_brut,
        CASE 
            WHEN LENGTH(TRIM(CAST(Id_prof_sante AS STRING))) = 8 
            THEN LPAD(TRIM(CAST(Id_prof_sante AS STRING)), 9, '0')
            ELSE TRIM(CAST(Id_prof_sante AS STRING))
        END AS id_prof_brut,
        UPPER(TRIM(CAST(Code_diag AS STRING))) AS code_diagnostic,
        COALESCE(
            SAFE_CAST(Date AS DATE),
            SAFE.PARSE_DATE('%Y-%m-%d', SUBSTR(TRIM(CAST(Date AS STRING)), 1, 10)),
            SAFE.PARSE_DATE('%d/%m/%Y', SUBSTR(TRIM(CAST(Date AS STRING)), 1, 10))
        ) AS date_consultation,
        SAFE.PARSE_TIME('%H:%M:%S', SUBSTR(TRIM(CAST(Heure_debut AS STRING)), 1, 8)) AS heure_debut,
        SAFE.PARSE_TIME('%H:%M:%S', SUBSTR(TRIM(CAST(Heure_fin AS STRING)), 1, 8)) AS heure_fin
    FROM {{ source('chu_bronze', 'consultation') }}
    WHERE Num_consultation IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (PARTITION BY Num_consultation ORDER BY Date DESC) = 1
),
prescription_agg AS (
    SELECT
        CAST(Num_consultation AS INT64) AS id_fait_consult,
        COUNT(Code_CIS) AS nb_medicaments
    FROM {{ source('chu_bronze', 'prescription') }}
    WHERE Num_consultation IS NOT NULL
    GROUP BY CAST(Num_consultation AS INT64)
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
LEFT JOIN {{ ref('stg_professionnel') }} prof ON c.id_prof_brut = prof.id_prof_brut