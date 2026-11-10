    {{ config(materialized='table', schema='chu_quality', tags=['quality']) }}

    {% set modeles = [
        'stg_patient',
        'stg_etablissement',
        'stg_professionnel',
        'stg_diagnostic',
        'stg_consultation',
        'stg_hospitalisation',
        'stg_deces',
        'stg_satisfaction',
        'dim_patient',
        'dim_etablissement',
        'dim_professionnel',
        'dim_diagnostic',
        'dim_localisation',
        'dim_temps',
        'fact_consultation',
        'fact_hospitalisation',
        'fact_deces',
        'fact_satisfaction'
    ] %}

    {% set relations = [] %}
    {% for m in modeles %}
        {% do relations.append(ref(m)) %}
    {% endfor %}

    {% set requetes = [] %}
    {% if execute %}
        {% for rel in relations %}
            {% for col in adapter.get_columns_in_relation(rel) %}
                {% do requetes.append(
                    "select '" ~ rel.schema ~ "' as couche, '" ~ rel.identifier ~ "' as table_name, '" ~ col.name ~ "' as attribut, "
                    ~ "count(*) as nb_lignes, countif(`" ~ col.name ~ "` is null) as nb_nulls from " ~ rel
                ) %}
            {% endfor %}
        {% endfor %}
    {% endif %}

    select
        couche,
        table_name,
        attribut,
        nb_lignes,
        nb_nulls,
        round(100 * (1 - safe_divide(nb_nulls, nb_lignes)), 2) as taux_completude_pct
    from (
        {{ requetes | join(' union all ') }}
    )
    order by couche, table_name, taux_completude_pct