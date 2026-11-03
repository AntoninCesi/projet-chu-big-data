WITH prof_csv AS (
    SELECT
        CASE 
            WHEN LENGTH(TRIM(CAST(identifiant AS STRING))) = 8 
            THEN LPAD(TRIM(CAST(identifiant AS STRING)), 9, '0')
            ELSE TRIM(CAST(identifiant AS STRING))
        END AS id_prof_brut,
        NULLIF(TRIM(CAST(categorie_professionnelle AS STRING)), '') AS categorie_prof,
        NULLIF(TRIM(CAST(profession AS STRING)), '') AS profession,
        NULLIF(TRIM(CAST(specialite AS STRING)), '') AS libelle_specialite
    FROM {{ source('chu_bronze', 'professionnel_sante') }}
    WHERE identifiant IS NOT NULL
),
prof_pg AS (
    SELECT
        CASE 
            WHEN LENGTH(TRIM(CAST(p.Identifiant AS STRING))) = 8 
            THEN LPAD(TRIM(CAST(p.Identifiant AS STRING)), 9, '0')
            ELSE TRIM(CAST(p.Identifiant AS STRING))
        END AS id_prof_brut,
        NULLIF(TRIM(CAST(p.Categorie_professionnelle AS STRING)), '') AS categorie_prof,
        NULLIF(TRIM(CAST(p.Profession AS STRING)), '') AS profession,
        NULLIF(TRIM(CAST(s.Specialite AS STRING)), '') AS libelle_specialite
    FROM {{ source('chu_bronze', 'professionnel_de_sante') }} p
    LEFT JOIN {{ source('chu_bronze', 'specialites') }} s
        ON TRIM(CAST(p.Code_specialite AS STRING)) = TRIM(CAST(s.Code_specialite AS STRING))
    WHERE p.Identifiant IS NOT NULL
),
prof_unifie AS (
    SELECT * FROM prof_pg
    UNION ALL
    SELECT * FROM prof_csv
),
prof_dedup AS (
    SELECT
        id_prof_brut,
        COALESCE(categorie_prof, 'Non renseigné') AS categorie_prof,
        COALESCE(profession, 'Non renseigné') AS profession,
        COALESCE(libelle_specialite, 'Généraliste / Non renseigné') AS libelle_specialite
    FROM prof_unifie
    QUALIFY ROW_NUMBER() OVER (PARTITION BY id_prof_brut ORDER BY libelle_specialite DESC NULLS LAST) = 1
),
activite_clean AS (
    SELECT
        CASE 
            WHEN LENGTH(TRIM(CAST(identifiant AS STRING))) = 8 
            THEN LPAD(TRIM(CAST(identifiant AS STRING)), 9, '0')
            ELSE TRIM(CAST(identifiant AS STRING))
        END AS id_prof_brut,
        NULLIF(TRIM(CAST(identifiant_organisation AS STRING)), '') AS id_organisation,
        COALESCE(NULLIF(TRIM(CAST(mode_exercice AS STRING)), ''), 'Inconnu') AS mode_exercice
    FROM {{ source('chu_bronze', 'activite_professionnel_sante') }}
    WHERE identifiant IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (PARTITION BY id_prof_brut ORDER BY identifiant_organisation DESC NULLS LAST) = 1
)
SELECT
    TO_HEX(SHA256(p.id_prof_brut)) AS id_prof_sante,
    p.id_prof_brut,
    p.profession,
    p.categorie_prof,
    p.libelle_specialite,
    COALESCE(a.mode_exercice, 'Libéral') AS mode_exercice,
    COALESCE(a.id_organisation, 'LIBERAL_NON_RATTACHE') AS id_organisation
FROM prof_dedup p
LEFT JOIN activite_clean a ON p.id_prof_brut = a.id_prof_brut