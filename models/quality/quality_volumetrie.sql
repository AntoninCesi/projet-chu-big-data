{{ config(materialized='table', schema='chu_quality', tags=['quality']) }}

{% set bronze_silver = [
    ('patient', "select count(*) from " ~ source('chu_bronze', 'patient'), 'stg_patient'),
    ('consultation', "select count(*) from " ~ source('chu_bronze', 'consultation'), 'stg_consultation'),
    ('diagnostic + hospitalisations (codes distincts)', "select count(distinct upper(trim(code))) from (select Code_diag as code from " ~ source('chu_bronze', 'diagnostic') ~ " union all select Code_diagnostic as code from " ~ source('chu_bronze', 'hospitalisations') ~ ")", 'stg_diagnostic'),
    ('hospitalisations', "select count(*) from " ~ source('chu_bronze', 'hospitalisations'), 'stg_hospitalisation'),
    ('deces_insee', "select count(*) from " ~ source('chu_bronze', 'deces_insee'), 'stg_deces'),
    ('esatis_2017', "select count(*) from " ~ source('chu_bronze', 'esatis_2017'), 'stg_satisfaction'),
    ('etablissement_sante', "select count(*) from " ~ source('chu_bronze', 'etablissement_sante'), 'stg_etablissement'),
    ('professionnel_de_sante + professionnel_sante', "select (select count(*) from " ~ source('chu_bronze', 'professionnel_de_sante') ~ ") + (select count(*) from " ~ source('chu_bronze', 'professionnel_sante') ~ ")", 'stg_professionnel')
] %}

{% set silver_gold = [
    ('stg_patient', 'dim_patient'),
    ('stg_etablissement', 'dim_etablissement'),
    ('stg_professionnel', 'dim_professionnel'),
    ('stg_diagnostic', 'dim_diagnostic'),
    ('stg_consultation', 'fact_consultation'),
    ('stg_hospitalisation', 'fact_hospitalisation'),
    ('stg_deces', 'fact_deces'),
    ('stg_satisfaction', 'fact_satisfaction')
] %}

{% set requetes = [] %}

{% for amont, requete, silver in bronze_silver %}
    {% do requetes.append(
        "select 'bronze -> silver' as etape, '" ~ amont ~ "' as table_amont, '" ~ silver ~ "' as table_aval, "
        ~ "(" ~ requete ~ ") as nb_amont, "
        ~ "(select count(*) from " ~ ref(silver) ~ ") as nb_aval"
    ) %}
{% endfor %}

{% for silver, gold in silver_gold %}
    {% do requetes.append(
        "select 'silver -> gold' as etape, '" ~ silver ~ "' as table_amont, '" ~ gold ~ "' as table_aval, "
        ~ "(select count(*) from " ~ ref(silver) ~ ") as nb_amont, "
        ~ "(select count(*) from " ~ ref(gold) ~ ") as nb_aval"
    ) %}
{% endfor %}

select
    etape,
    table_amont,
    table_aval,
    nb_amont,
    nb_aval,
    nb_aval - nb_amont as ecart,
    round(100 * safe_divide(nb_aval, nb_amont), 2) as taux_conservation_pct
from (
    {{ requetes | join(' union all ') }}
)
order by etape, table_amont