WITH diag_pg AS (
    SELECT
        UPPER(TRIM(CAST(Code_diag AS STRING))) AS code_diagnostic,
        TRIM(CAST(Diagnostic AS STRING)) AS libelle_diagnostic
    FROM {{ source('chu_bronze', 'diagnostic') }}
    WHERE Code_diag IS NOT NULL
),
diag_hosp AS (
    SELECT
        UPPER(TRIM(CAST(Code_diagnostic AS STRING))) AS code_diagnostic,
        TRIM(CAST(Suite_diagnostic_consultation AS STRING)) AS libelle_diagnostic
    FROM {{ source('chu_bronze', 'hospitalisations') }}
    WHERE Code_diagnostic IS NOT NULL
),
union_diag AS (
    SELECT * FROM diag_pg
    UNION ALL
    SELECT * FROM diag_hosp
)
SELECT
    code_diagnostic,
    COALESCE(NULLIF(libelle_diagnostic, ''), 'Libellé inconnu') AS libelle_diagnostic
FROM union_diag
WHERE code_diagnostic != ''
QUALIFY ROW_NUMBER() OVER (PARTITION BY code_diagnostic ORDER BY LENGTH(libelle_diagnostic) DESC) = 1