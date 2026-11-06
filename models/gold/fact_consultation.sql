{{ config(
    materialized='table',
    partition_by={
      "field": "sk_date",
      "data_type": "int64",
      "range": {
        "start": 19000101,
        "end": 20301231,
        "interval": 10000
      }
    },
    cluster_by=["sk_etablissement", "sk_diagnostic", "sk_professionnel"]
) }}

SELECT
    c.id_fait_consult,
    COALESCE(c.sk_date, 19000101) AS sk_date,
    COALESCE(p.sk_patient, -1) AS sk_patient,
    COALESCE(prof.sk_professionnel, -1) AS sk_professionnel,
    COALESCE(e.sk_etablissement, -1) AS sk_etablissement,
    COALESCE(d.sk_diagnostic, -1) AS sk_diagnostic,
    c.duree_consult_min,
    c.nb_medicaments,
    c.nb_consultations
FROM {{ ref('stg_consultation') }} c
LEFT JOIN {{ ref('dim_patient') }} p ON c.id_patient_source = p.id_patient_source
LEFT JOIN {{ ref('dim_professionnel') }} prof ON c.id_prof_sante = prof.id_prof_sante
LEFT JOIN {{ ref('dim_etablissement') }} e ON c.id_organisation = e.id_organisation
LEFT JOIN {{ ref('dim_diagnostic') }} d ON c.code_diagnostic = d.code_diagnostic