WITH patient_brut AS (
    SELECT
        Id_patient,
        Sexe,
        Age,
        Date AS date_naissance_str
    FROM {{ source('chu_bronze', 'patient') }}
    WHERE Id_patient IS NOT NULL
),
calcul_age AS (
    SELECT
        TRIM(CAST(Id_patient AS STRING)) AS id_patient_brut,
        TO_HEX(SHA256(TRIM(CAST(Id_patient AS STRING)))) AS id_patient_source,
        CASE 
            WHEN UPPER(TRIM(CAST(Sexe AS STRING))) IN ('F', 'FEMME', 'FEMALE', '2') THEN 'F'
            WHEN UPPER(TRIM(CAST(Sexe AS STRING))) IN ('M', 'H', 'HOMME', 'MALE', '1') THEN 'M'
            ELSE 'Inconnu'
        END AS sexe,
        COALESCE(
            SAFE_CAST(Age AS INT64),
            DATE_DIFF(
                CURRENT_DATE(),
                COALESCE(
                    SAFE.PARSE_DATE('%Y-%m-%d', TRIM(CAST(date_naissance_str AS STRING))),
                    SAFE.PARSE_DATE('%d/%m/%Y', TRIM(CAST(date_naissance_str AS STRING)))
                ),
                YEAR
            )
        ) AS age
    FROM patient_brut
    QUALIFY ROW_NUMBER() OVER (PARTITION BY Id_patient ORDER BY Age DESC NULLS LAST) = 1
)
SELECT
    id_patient_source,
    id_patient_brut,
    sexe,
    age,
    CASE
        WHEN age < 18 THEN 'Moins de 18 ans'
        WHEN age BETWEEN 18 AND 35 THEN '18-35 ans'
        WHEN age BETWEEN 36 AND 59 THEN '36-59 ans'
        WHEN age >= 60 THEN '60 ans et plus'
        ELSE 'Non renseigné'
    END AS tranche_age
FROM calcul_age
WHERE age IS NULL OR age BETWEEN 0 AND 125