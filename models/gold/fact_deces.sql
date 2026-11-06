{{ config(
    materialized='table',
    partition_by={
      "field": "sk_date_deces",
      "data_type": "int64",
      "range": {
        "start": 19000101,
        "end": 20301231,
        "interval": 10000
      }
    },
    cluster_by=["sk_localisation", "sexe_decede"]
) }}

SELECT
    d.id_fait_deces,
    COALESCE(d.sk_date_deces, 19000101) AS sk_date_deces,
    COALESCE(l.sk_localisation, -1) AS sk_localisation,
    d.sexe_decede,
    d.age_au_deces,
    d.nb_deces
FROM {{ ref('stg_deces') }} d
LEFT JOIN {{ ref('dim_localisation') }} l 
    ON d.code_commune_insee = l.code_commune_insee 
   AND d.code_departement = l.code_departement