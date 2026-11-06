SELECT
    FARM_FINGERPRINT(CONCAT(LPAD(TRIM(CAST(finess_geo AS STRING)), 9, '0'), '_2020_MCO_48H')) AS id_fait_satisfaction,
    LPAD(TRIM(CAST(finess_geo AS STRING)), 9, '0') AS code_finess_geo,
    LPAD(TRIM(CAST(finess AS STRING)), 9, '0') AS code_finess_juridique,
    TRIM(CAST(rs_finess_geo AS STRING)) AS raison_sociale_finess,
    TRIM(CAST(region AS STRING)) AS nom_region,
    20200101 AS sk_date_campagne,
    'MCO_48H' AS theme_enquete,
    SAFE_CAST(REPLACE(TRIM(CAST(score_all_rea_ajust AS STRING)), ',', '.') AS NUMERIC) AS score_global_ajuste,
    SAFE_CAST(TRIM(CAST(nb_rep_score_all_rea_ajust AS STRING)) AS INT64) AS nb_reponses_global,
    SAFE_CAST(REPLACE(TRIM(CAST(taux_reco_brut AS STRING)), ',', '.') AS NUMERIC) AS taux_recommandation
FROM {{ source('chu_bronze', 'esatis_2020') }}
WHERE finess_geo IS NOT NULL
  -- Règle HAS : score publié seulement à partir de 30 réponses exploitables
  AND SAFE_CAST(TRIM(CAST(nb_rep_score_all_rea_ajust AS STRING)) AS INT64) >= 30
  AND SAFE_CAST(REPLACE(TRIM(CAST(score_all_rea_ajust AS STRING)), ',', '.') AS NUMERIC) IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY finess_geo
    ORDER BY SAFE_CAST(TRIM(CAST(nb_rep_score_all_rea_ajust AS STRING)) AS INT64) DESC
) = 1
