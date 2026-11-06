{{ config(materialized='table') }}

SELECT
    -1 AS sk_diagnostic,
    'SANS_DIAG' AS code_diagnostic,
    'Aucun diagnostic renseigné' AS libelle_diagnostic

UNION ALL

SELECT
    ROW_NUMBER() OVER (ORDER BY code_diagnostic) AS sk_diagnostic,
    code_diagnostic,
    libelle_diagnostic
FROM {{ ref('stg_diagnostic') }}