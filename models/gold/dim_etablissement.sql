{{ config(materialized='table') }}

SELECT
    -1 AS sk_etablissement,
    'LIBERAL_NON_RATTACHE' AS id_organisation,
    '000000000' AS code_finess_geo,
    'Non rattaché / Libéral' AS raison_sociale

UNION ALL

SELECT
    ROW_NUMBER() OVER (ORDER BY id_organisation) AS sk_etablissement,
    id_organisation,
    code_finess_geo,
    raison_sociale
FROM {{ ref('stg_etablissement') }}