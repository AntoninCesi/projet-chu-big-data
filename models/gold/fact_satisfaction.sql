{{ config(
    materialized='table',
    partition_by={
      "field": "sk_date_campagne",
      "data_type": "int64",
      "range": {
        "start": 20100101,
        "end": 20301231,
        "interval": 10000
      }
    },
    cluster_by=["sk_etablissement", "sk_localisation", "theme_enquete"]
) }}

WITH etablissement_unique_finess AS (
    SELECT
        code_finess_geo,
        id_organisation,
        code_commune_insee,
        code_departement
    FROM {{ ref('stg_etablissement') }}
    WHERE code_finess_geo IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (PARTITION BY code_finess_geo ORDER BY id_organisation) = 1
)

SELECT
    s.id_fait_satisfaction,
    COALESCE(s.sk_date_campagne, 19000101) AS sk_date_campagne,
    COALESCE(de.sk_etablissement, -1) AS sk_etablissement,
    COALESCE(dl.sk_localisation, -1) AS sk_localisation,
    s.theme_enquete,
    s.score_global_ajuste,
    s.nb_reponses_global,
    s.taux_recommandation
FROM {{ ref('stg_satisfaction') }} s
LEFT JOIN etablissement_unique_finess euf 
    ON s.code_finess_geo = euf.code_finess_geo
LEFT JOIN {{ ref('dim_etablissement') }} de 
    ON euf.id_organisation = de.id_organisation
LEFT JOIN {{ ref('dim_localisation') }} dl 
    ON euf.code_commune_insee = dl.code_commune_insee 
   AND euf.code_departement = dl.code_departement