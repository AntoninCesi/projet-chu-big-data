{{ config(materialized='table') }}

WITH dates_unifiees AS (
    SELECT DISTINCT date_consultation AS date_complete FROM {{ ref('stg_consultation') }} WHERE date_consultation IS NOT NULL
    UNION DISTINCT
    SELECT DISTINCT date_entree AS date_complete FROM {{ ref('stg_hospitalisation') }} WHERE date_entree IS NOT NULL
    UNION DISTINCT
    SELECT DISTINCT date_deces AS date_complete FROM {{ ref('stg_deces') }} WHERE date_deces IS NOT NULL
    UNION DISTINCT
    SELECT DISTINCT SAFE.PARSE_DATE('%Y%m%d', CAST(sk_date_campagne AS STRING)) AS date_complete FROM {{ ref('stg_satisfaction') }} WHERE sk_date_campagne IS NOT NULL
    UNION DISTINCT
    SELECT DATE('1900-01-01') AS date_complete
)

SELECT
    CAST(FORMAT_DATE('%Y%m%d', date_complete) AS INT64) AS sk_date,
    date_complete,
    EXTRACT(YEAR FROM date_complete) AS annee,
    EXTRACT(QUARTER FROM date_complete) AS trimestre,
    EXTRACT(MONTH FROM date_complete) AS mois
FROM dates_unifiees
WHERE date_complete IS NOT NULL