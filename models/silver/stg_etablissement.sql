WITH source_etab AS (
    SELECT * FROM {{ source('chu_bronze', 'etablissement_sante') }}
),
nettoyage AS (
    SELECT
        TRIM(CAST(identifiant_organisation AS STRING)) AS id_organisation,
        LPAD(
            COALESCE(
                NULLIF(TRIM(CAST(finess_site AS STRING)), ''),
                NULLIF(TRIM(CAST(siren_site AS STRING)), ''),
                CASE 
                    WHEN STARTS_WITH(TRIM(CAST(identifiant_organisation AS STRING)), 'F') 
                    THEN SUBSTR(TRIM(CAST(identifiant_organisation AS STRING)), 2, 9)
                END
            ), 9, '0'
        ) AS code_finess_geo,
        LPAD(NULLIF(TRIM(CAST(finess_etablissement_juridique AS STRING)), ''), 9, '0') AS code_finess_juridique,
        COALESCE(NULLIF(TRIM(CAST(raison_sociale_site AS STRING)), ''), 'Inconnu') AS raison_sociale,
        NULLIF(TRIM(CAST(siret_site AS STRING)), '') AS siret_site,
        NULLIF(TRIM(CAST(code_commune AS STRING)), '') AS code_commune_insee,
        CASE
            WHEN STARTS_WITH(COALESCE(NULLIF(TRIM(CAST(code_commune AS STRING)), ''), NULLIF(TRIM(CAST(code_postal AS STRING)), '')), '97')
              OR STARTS_WITH(COALESCE(NULLIF(TRIM(CAST(code_commune AS STRING)), ''), NULLIF(TRIM(CAST(code_postal AS STRING)), '')), '98')
            THEN SUBSTR(COALESCE(NULLIF(TRIM(CAST(code_commune AS STRING)), ''), NULLIF(TRIM(CAST(code_postal AS STRING)), '')), 1, 3)
            ELSE SUBSTR(COALESCE(NULLIF(TRIM(CAST(code_commune AS STRING)), ''), NULLIF(TRIM(CAST(code_postal AS STRING)), '')), 1, 2)
        END AS code_departement
    FROM source_etab
    WHERE identifiant_organisation IS NOT NULL
)
SELECT *
FROM nettoyage
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_organisation ORDER BY code_finess_geo DESC NULLS LAST) = 1