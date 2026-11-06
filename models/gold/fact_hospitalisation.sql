{{ config(
    materialized='table',
    partition_by={
      "field": "sk_date_entree",
      "data_type": "int64",
      "range": {
        "start": 19000101,
        "end": 20301231,
        "interval": 10000
      }
    },
    cluster_by=["sk_etablissement", "sk_diagnostic"]
) }}

SELECT
    h.id_fait_hospit,
    COALESCE(h.sk_date_entree, 19000101) AS sk_date_entree,
    COALESCE(p.sk_patient, -1) AS sk_patient,
    COALESCE(e.sk_etablissement, -1) AS sk_etablissement,
    COALESCE(d.sk_diagnostic, -1) AS sk_diagnostic,
    h.nb_jours_hospit,
    h.nb_hospitalisations
FROM {{ ref('stg_hospitalisation') }} h
LEFT JOIN {{ ref('dim_patient') }} p ON h.id_patient_source = p.id_patient_source
LEFT JOIN {{ ref('dim_etablissement') }} e ON h.id_organisation = e.id_organisation
LEFT JOIN {{ ref('dim_diagnostic') }} d ON h.code_diagnostic = d.code_diagnostic