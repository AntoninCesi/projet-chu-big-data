
-- MODE OPÉRATOIRE
--   1. DÉSACTIVER LE CACHE : More > Query settings > décocher "Use cached results"
--   2. Run : les 18 requêtes s'exécutent à la suite
--   3. Relancer 5 fois au total (médiane sur 5 mesures)

-- Q1 BRUT
SELECT /* BENCH Q1 */
  e.raison_sociale,
  COUNT(*) AS nb_consultations,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS taux_consultation_pct
FROM `big-data-cloud-healthcare-unit.benchmark.fact_consultation_brut` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_etablissement` AS e ON e.sk_etablissement = f.sk_etablissement
WHERE f.sk_date BETWEEN 20200101 AND 20201231
GROUP BY f.sk_etablissement, e.raison_sociale;

-- Q1 OPTI
SELECT /* BENCH Q1 */
  e.raison_sociale,
  COUNT(*) AS nb_consultations,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS taux_consultation_pct
FROM `big-data-cloud-healthcare-unit.chu_gold.fact_consultation` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_etablissement` AS e ON e.sk_etablissement = f.sk_etablissement
WHERE f.sk_date BETWEEN 20200101 AND 20201231
GROUP BY f.sk_etablissement, e.raison_sociale;


-------------------------------------------------------------------


-- Q2 OPTI
SELECT /* BENCH Q2 */
  d.code_diagnostic,
  d.libelle_diagnostic,
  COUNT(*) AS nb_consultations,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS taux_consultation_pct
FROM `big-data-cloud-healthcare-unit.chu_gold.fact_consultation` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_diagnostic` AS d ON d.sk_diagnostic = f.sk_diagnostic
WHERE f.sk_date BETWEEN 20200101 AND 20201231
GROUP BY d.code_diagnostic, d.libelle_diagnostic;

-- Q2 BRUT
SELECT /* BENCH Q2 */
  d.code_diagnostic,
  d.libelle_diagnostic,
  COUNT(*) AS nb_consultations,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS taux_consultation_pct
FROM `big-data-cloud-healthcare-unit.benchmark.fact_consultation_brut` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_diagnostic` AS d ON d.sk_diagnostic = f.sk_diagnostic
WHERE f.sk_date BETWEEN 20200101 AND 20201231
GROUP BY d.code_diagnostic, d.libelle_diagnostic;


-------------------------------------------------------------------


-- Q3 OPTI
SELECT /* BENCH Q3 */
  COUNT(*) AS nb_hospitalisations,
  COUNT(DISTINCT f.sk_patient) AS nb_patients_hospitalises,
  ROUND(100 * COUNT(DISTINCT f.sk_patient)
        / (SELECT COUNT(*) FROM `big-data-cloud-healthcare-unit.chu_gold.dim_patient` WHERE sk_patient <> -1), 2) AS taux_hospitalisation_pct
FROM `big-data-cloud-healthcare-unit.benchmark.fact_hospitalisation_brut` AS f
WHERE f.sk_date_entree BETWEEN 20200101 AND 20201231
  AND f.sk_patient <> -1;

-- Q3 OPTI
SELECT /* BENCH Q3 */
  COUNT(*) AS nb_hospitalisations,
  COUNT(DISTINCT f.sk_patient) AS nb_patients_hospitalises,
  ROUND(100 * COUNT(DISTINCT f.sk_patient)
        / (SELECT COUNT(*) FROM `big-data-cloud-healthcare-unit.chu_gold.dim_patient` WHERE sk_patient <> -1), 2) AS taux_hospitalisation_pct
FROM `big-data-cloud-healthcare-unit.chu_gold.fact_hospitalisation` AS f
WHERE f.sk_date_entree BETWEEN 20200101 AND 20201231
  AND f.sk_patient <> -1;


-------------------------------------------------------------------


-- Q4 OPTI
SELECT /* BENCH Q4 */
  d.code_diagnostic,
  d.libelle_diagnostic,
  COUNT(*) AS nb_hospitalisations,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS part_hospitalisations_pct,
  ROUND(AVG(f.nb_jours_hospit), 2) AS duree_moyenne_sejour_j
FROM `big-data-cloud-healthcare-unit.chu_gold.fact_hospitalisation` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_diagnostic` AS d ON d.sk_diagnostic = f.sk_diagnostic
WHERE f.sk_date_entree BETWEEN 20200101 AND 20201231
GROUP BY d.code_diagnostic, d.libelle_diagnostic;

-- Q4 BRUT
SELECT /* BENCH Q4 */
  d.code_diagnostic,
  d.libelle_diagnostic,
  COUNT(*) AS nb_hospitalisations,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS part_hospitalisations_pct,
  ROUND(AVG(f.nb_jours_hospit), 2) AS duree_moyenne_sejour_j
FROM `big-data-cloud-healthcare-unit.benchmark.fact_hospitalisation_brut` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_diagnostic` AS d ON d.sk_diagnostic = f.sk_diagnostic
WHERE f.sk_date_entree BETWEEN 20200101 AND 20201231
GROUP BY d.code_diagnostic, d.libelle_diagnostic;


-------------------------------------------------------------------


-- Q5 BRUT
WITH /* BENCH Q5 */ hospit AS (
  SELECT
    p.sexe,
    p.tranche_age,
    COUNT(*) AS nb_hospitalisations,
    COUNT(DISTINCT f.sk_patient) AS nb_patients_hospitalises
  FROM `big-data-cloud-healthcare-unit.benchmark.fact_hospitalisation_brut` AS f
  JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_patient` AS p ON p.sk_patient = f.sk_patient
  WHERE f.sk_date_entree BETWEEN 20200101 AND 20201231
  GROUP BY p.sexe, p.tranche_age
),
population AS (
  SELECT sexe, tranche_age, COUNT(*) AS nb_patients
  FROM `big-data-cloud-healthcare-unit.chu_gold.dim_patient`
  WHERE sk_patient <> -1
  GROUP BY sexe, tranche_age
)
SELECT
  population.sexe,
  population.tranche_age,
  population.nb_patients,
  COALESCE(hospit.nb_hospitalisations, 0) AS nb_hospitalisations,
  ROUND(100 * COALESCE(hospit.nb_patients_hospitalises, 0) / population.nb_patients, 2) AS taux_hospitalisation_pct
FROM population
LEFT JOIN hospit USING (sexe, tranche_age);

-- Q5 OPTI
WITH /* BENCH Q5 */ hospit AS (
  SELECT
    p.sexe,
    p.tranche_age,
    COUNT(*) AS nb_hospitalisations,
    COUNT(DISTINCT f.sk_patient) AS nb_patients_hospitalises
  FROM `big-data-cloud-healthcare-unit.chu_gold.fact_hospitalisation` AS f
  JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_patient` AS p ON p.sk_patient = f.sk_patient
  WHERE f.sk_date_entree BETWEEN 20200101 AND 20201231
  GROUP BY p.sexe, p.tranche_age
),
population AS (
  SELECT sexe, tranche_age, COUNT(*) AS nb_patients
  FROM `big-data-cloud-healthcare-unit.chu_gold.dim_patient`
  WHERE sk_patient <> -1
  GROUP BY sexe, tranche_age
)
SELECT
  population.sexe,
  population.tranche_age,
  population.nb_patients,
  COALESCE(hospit.nb_hospitalisations, 0) AS nb_hospitalisations,
  ROUND(100 * COALESCE(hospit.nb_patients_hospitalises, 0) / population.nb_patients, 2) AS taux_hospitalisation_pct
FROM population
LEFT JOIN hospit USING (sexe, tranche_age);


-------------------------------------------------------------------


-- Q6 OPTI
SELECT /* BENCH Q6 */
  p.profession,
  p.libelle_specialite,
  COUNT(*) AS nb_consultations,
  COUNT(DISTINCT f.sk_professionnel) AS nb_professionnels,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS taux_consultation_pct
FROM `big-data-cloud-healthcare-unit.chu_gold.fact_consultation` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_professionnel` AS p ON p.sk_professionnel = f.sk_professionnel
WHERE f.sk_date BETWEEN 20200101 AND 20201231
GROUP BY p.profession, p.libelle_specialite;

-- Q6 BRUT
SELECT /* BENCH Q6 */
  p.profession,
  p.libelle_specialite,
  COUNT(*) AS nb_consultations,
  COUNT(DISTINCT f.sk_professionnel) AS nb_professionnels,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS taux_consultation_pct
FROM `big-data-cloud-healthcare-unit.benchmark.fact_consultation_brut` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_professionnel` AS p ON p.sk_professionnel = f.sk_professionnel
WHERE f.sk_date BETWEEN 20200101 AND 20201231
GROUP BY p.profession, p.libelle_specialite;


-------------------------------------------------------------------


-- Q7 BRUT
SELECT /* BENCH Q7 */
  l.nom_region,
  COUNT(*) AS nb_deces,
  COUNTIF(f.sexe_decede = 'F') AS nb_femmes,
  COUNTIF(f.sexe_decede = 'M') AS nb_hommes,
  ROUND(AVG(f.age_au_deces), 1) AS age_moyen_deces
FROM `big-data-cloud-healthcare-unit.benchmark.fact_deces_brut` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_localisation` AS l ON l.sk_localisation = f.sk_localisation
WHERE f.sk_date_deces BETWEEN 20190101 AND 20191231
GROUP BY l.nom_region;

-- Q7 OPTI
SELECT /* BENCH Q7 */
  l.nom_region,
  COUNT(*) AS nb_deces,
  COUNTIF(f.sexe_decede = 'F') AS nb_femmes,
  COUNTIF(f.sexe_decede = 'M') AS nb_hommes,
  ROUND(AVG(f.age_au_deces), 1) AS age_moyen_deces
FROM `big-data-cloud-healthcare-unit.chu_gold.fact_deces` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_localisation` AS l ON l.sk_localisation = f.sk_localisation
WHERE f.sk_date_deces BETWEEN 20190101 AND 20191231
GROUP BY l.nom_region;


-------------------------------------------------------------------


-- Q8 OPTI
SELECT /* BENCH Q8 */
  l.nom_region,
  COUNT(*) AS nb_etablissements,
  SUM(f.nb_reponses_global) AS nb_reponses,
  ROUND(SUM(f.score_global_ajuste * f.nb_reponses_global) / SUM(f.nb_reponses_global), 2) AS score_moyen_pondere,
  ROUND(AVG(f.taux_recommandation), 1) AS taux_recommandation_moyen
FROM `big-data-cloud-healthcare-unit.chu_gold.fact_satisfaction` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_localisation` AS l ON l.sk_localisation = f.sk_localisation
WHERE f.sk_date_campagne BETWEEN 20200101 AND 20201231
GROUP BY l.nom_region;

-- Q8 BRUT
SELECT /* BENCH Q8 */
  l.nom_region,
  COUNT(*) AS nb_etablissements,
  SUM(f.nb_reponses_global) AS nb_reponses,
  ROUND(SUM(f.score_global_ajuste * f.nb_reponses_global) / SUM(f.nb_reponses_global), 2) AS score_moyen_pondere,
  ROUND(AVG(f.taux_recommandation), 1) AS taux_recommandation_moyen
FROM `big-data-cloud-healthcare-unit.benchmark.fact_satisfaction_brut` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_localisation` AS l ON l.sk_localisation = f.sk_localisation
WHERE f.sk_date_campagne BETWEEN 20200101 AND 20201231
GROUP BY l.nom_region;


-------------------------------------------------------------------


-- Q9 BRUT
SELECT /* BENCH Q9 */
  e.raison_sociale,
  COUNT(*) AS nb_consultations,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS taux_consultation_pct
FROM `big-data-cloud-healthcare-unit.benchmark.fact_consultation_brut` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_temps` AS t ON t.sk_date = f.sk_date
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_etablissement` AS e ON e.sk_etablissement = f.sk_etablissement
WHERE t.annee = 2020
GROUP BY f.sk_etablissement, e.raison_sociale;

-- Q9 OPTI
SELECT /* BENCH Q9 */
  e.raison_sociale,
  COUNT(*) AS nb_consultations,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS taux_consultation_pct
FROM `big-data-cloud-healthcare-unit.chu_gold.fact_consultation` AS f
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_temps` AS t ON t.sk_date = f.sk_date
JOIN `big-data-cloud-healthcare-unit.chu_gold.dim_etablissement` AS e ON e.sk_etablissement = f.sk_etablissement
WHERE t.annee = 2020
GROUP BY f.sk_etablissement, e.raison_sociale;
