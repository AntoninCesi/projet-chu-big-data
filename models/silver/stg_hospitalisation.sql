SELECT
    CAST(Num_Hospitalisation AS INT64) AS id_fait_hospit,
    TO_HEX(SHA256(TRIM(CAST(Id_patient AS STRING)))) AS id_patient_source,
    TRIM(CAST(identifiant_organisation AS STRING)) AS id_organisation,
    UPPER(TRIM(CAST(Code_diagnostic AS STRING))) AS code_diagnostic,
    TRIM(CAST(Suite_diagnostic_consultation AS STRING)) AS libelle_diagnostic,
    SAFE.PARSE_DATE('%d/%m/%Y', TRIM(CAST(Date_Entree AS STRING))) AS date_entree,
    CAST(FORMAT_DATE('%Y%m%d', SAFE.PARSE_DATE('%d/%m/%Y', TRIM(CAST(Date_Entree AS STRING)))) AS INT64) AS sk_date_entree,
    CAST(Jour_Hospitalisation AS INT64) AS nb_jours_hospit,
    1 AS nb_hospitalisations
FROM {{ source('chu_bronze', 'hospitalisations') }}
WHERE Num_Hospitalisation IS NOT NULL
  AND SAFE_CAST(Jour_Hospitalisation AS INT64) >= 0
QUALIFY ROW_NUMBER() OVER (PARTITION BY Num_Hospitalisation ORDER BY Date_Entree DESC) = 1