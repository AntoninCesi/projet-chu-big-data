{{ config(materialized='table', schema='chu_quality', tags=['quality']) }}

{% set cles_etrangeres = [
    ('fact_consultation', 'sk_patient'),
    ('fact_consultation', 'sk_professionnel'),
    ('fact_consultation', 'sk_etablissement'),
    ('fact_consultation', 'sk_diagnostic'),
    ('fact_hospitalisation', 'sk_patient'),
    ('fact_hospitalisation', 'sk_etablissement'),
    ('fact_hospitalisation', 'sk_diagnostic'),
    ('fact_satisfaction', 'sk_etablissement'),
    ('fact_satisfaction', 'sk_localisation'),
    ('fact_deces', 'sk_localisation')
] %}

{% set cles_metier = [
    ('dim_patient', 'id_patient_source', 'id_patient_source'),
    ('dim_etablissement', 'id_organisation', 'id_organisation'),
    ('dim_professionnel', 'id_prof_sante', 'id_prof_sante'),
    ('dim_diagnostic', 'code_diagnostic', 'code_diagnostic'),
    ('dim_localisation', 'code_commune_insee + code_departement', "concat(code_commune_insee, '|', code_departement)"),
    ('dim_temps', 'sk_date', 'sk_date'),
    ('fact_consultation', 'id_fait_consult', 'id_fait_consult'),
    ('fact_hospitalisation', 'id_fait_hospit', 'id_fait_hospit'),
    ('fact_satisfaction', 'id_fait_satisfaction', 'id_fait_satisfaction'),
    ('fact_deces', 'id_fait_deces', 'id_fait_deces')
] %}

{% set requetes = [] %}

{% for t, c in cles_etrangeres %}
    {% do requetes.append(
        "select 'cle_non_rattachee' as type_controle, '" ~ t ~ "' as table_name, '" ~ c ~ "' as attribut, "
        ~ "count(*) as nb_lignes, countif(" ~ c ~ " = -1 or " ~ c ~ " is null) as nb_anomalies from " ~ ref(t)
    ) %}
{% endfor %}

{% for t, libelle, expr in cles_metier %}
    {% do requetes.append(
        "select 'doublon' as type_controle, '" ~ t ~ "' as table_name, '" ~ libelle ~ "' as attribut, "
        ~ "count(*) as nb_lignes, count(" ~ expr ~ ") - count(distinct " ~ expr ~ ") as nb_anomalies from " ~ ref(t)
    ) %}
{% endfor %}

select
    type_controle,
    table_name,
    attribut,
    nb_lignes,
    nb_anomalies,
    round(100 * safe_divide(nb_anomalies, nb_lignes), 3) as taux_anomalies_pct
from (
    {{ requetes | join(' union all ') }}
    union all
    select
        'finess_format' as type_controle,
        'dim_etablissement' as table_name,
        'code_finess_geo' as attribut,
        count(*) as nb_lignes,
        countif(code_finess_geo is null or not regexp_contains(code_finess_geo, r'^(2A|2B|[0-9]{2})[0-9]{7}$')) as nb_anomalies
    from {{ ref('dim_etablissement') }}
    where sk_etablissement <> -1
    union all
    select
        'finess_doublon' as type_controle,
        'dim_etablissement' as table_name,
        'code_finess_geo' as attribut,
        count(*) as nb_lignes,
        count(code_finess_geo) - count(distinct code_finess_geo) as nb_anomalies
    from {{ ref('dim_etablissement') }}
    where sk_etablissement <> -1
)
order by type_controle, table_name, attribut