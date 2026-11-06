{{ config(materialized='table') }}

SELECT
    -1 AS sk_professionnel,
    'INCONNU' AS id_prof_sante,
    'Non renseigné' AS profession,
    'Non renseignée' AS libelle_specialite,
    'Non renseigné' AS mode_exercice

UNION ALL

SELECT
    ROW_NUMBER() OVER (ORDER BY id_prof_sante) AS sk_professionnel,
    id_prof_sante,
    profession,
    libelle_specialite,
    mode_exercice
FROM {{ ref('stg_professionnel') }}