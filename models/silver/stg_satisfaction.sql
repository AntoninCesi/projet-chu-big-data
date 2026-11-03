SELECT
    FARM_FINGERPRINT(CONCAT(LPAD(TRIM(CAST(finess_geo AS STRING)), 9, '0'), '_2017_MCO_48H')) AS id_fait_satisfaction,
    LPAD(TRIM(CAST(finess_geo AS STRING)), 9, '0') AS code_finess_geo,
    LPAD(TRIM(CAST(finess AS STRING)), 9, '0') AS code_finess_juridique,
    TRIM(CAST(rs_finess_geo AS STRING)) AS raison_sociale_finess,
    REPLACE(TRIM(CAST(region AS STRING)), 'Rhne', 'Rhône') AS nom_region,
    20170101 AS sk_date_campagne,
    'MCO_48H' AS theme_enquete,
    SAFE_CAST(REPLACE(CAST(score_all_rea_ajust AS STRING), ',', '.') AS NUMERIC) AS score_global_ajuste,
    SAFE_CAST(nb_rep_score_all_rea_ajust AS INT64) AS nb_reponses_global,
    CAST(NULL AS NUMERIC) AS taux_recommandation
FROM {{ source('chu_bronze', 'esatis_2017') }}
WHERE finess_geo IS NOT NULL
  AND SAFE_CAST(nb_rep_score_all_rea_ajust AS INT64) >= 30
  AND SAFE_CAST(REPLACE(CAST(score_all_rea_ajust AS STRING), ',', '.') AS NUMERIC) IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY finess_geo ORDER BY nb_rep_score_all_rea_ajust DESC) = 1