{{ config(materialized='table') }}

WITH communes_unifiees AS (
    SELECT DISTINCT
        COALESCE(code_commune_insee, 'INCONNU') AS code_commune_insee,
        COALESCE(code_departement, 'INCONNU') AS code_departement
    FROM {{ ref('stg_etablissement') }}
    UNION DISTINCT
    SELECT DISTINCT
        COALESCE(code_commune_insee, 'INCONNU') AS code_commune_insee,
        COALESCE(code_departement, 'INCONNU') AS code_departement
    FROM {{ ref('stg_deces') }}
),

enrichissement_region AS (
    SELECT
        code_commune_insee,
        code_departement,
        CASE
            WHEN code_departement IN ('75','77','78','91','92','93','94','95') THEN 'Île-de-France'
            WHEN code_departement IN ('02','59','60','62','80') THEN 'Hauts-de-France'
            WHEN code_departement IN ('08','10','51','52','54','55','57','67','68','88') THEN 'Grand Est'
            WHEN code_departement IN ('14','27','50','61','76') THEN 'Normandie'
            WHEN code_departement IN ('22','29','35','56') THEN 'Bretagne'
            WHEN code_departement IN ('44','49','53','72','85') THEN 'Pays de la Loire'
            WHEN code_departement IN ('18','28','36','37','41','45') THEN 'Centre-Val de Loire'
            WHEN code_departement IN ('21','25','39','58','70','71','89','90') THEN 'Bourgogne-Franche-Comté'
            WHEN code_departement IN ('01','03','07','15','26','38','42','43','63','69','73','74') THEN 'Auvergne-Rhône-Alpes'
            WHEN code_departement IN ('16','17','19','23','24','33','40','47','64','79','86','87') THEN 'Nouvelle-Aquitaine'
            WHEN code_departement IN ('09','11','12','30','31','32','34','46','48','65','66','81','82') THEN 'Occitanie'
            WHEN code_departement IN ('04','05','06','13','83','84') THEN "Provence-Alpes-Côte d'Azur"
            WHEN code_departement IN ('20','2A','2B') THEN 'Corse'
            WHEN code_departement LIKE '97%' OR code_departement LIKE '98%' THEN 'Outre-Mer'
            ELSE 'Région Inconnue'
        END AS nom_region
    FROM communes_unifiees
)

SELECT
    -1 AS sk_localisation,
    'INCONNU' AS code_commune_insee,
    'INCONNU' AS code_departement,
    'Non renseigné' AS nom_region

UNION ALL

SELECT
    ROW_NUMBER() OVER (ORDER BY code_departement, code_commune_insee) AS sk_localisation,
    code_commune_insee,
    code_departement,
    nom_region
FROM enrichissement_region
WHERE NOT (code_commune_insee = 'INCONNU' AND code_departement = 'INCONNU')