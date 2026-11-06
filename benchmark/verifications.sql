-- 1. taux de lignes rattachées aux inconnus des dimensions

SELECT 'consultation -> patient' AS jointure, ROUND(100 * COUNTIF(sk_patient = -1) / COUNT(*), 2) AS pct_inconnu FROM `big-data-cloud-healthcare-unit.chu_gold.fact_consultation`
UNION ALL SELECT 'consultation -> professionnel', ROUND(100 * COUNTIF(sk_professionnel = -1) / COUNT(*), 2) FROM `big-data-cloud-healthcare-unit.chu_gold.fact_consultation`
UNION ALL SELECT 'consultation -> établissement (libéraux attendus ~36 %)', ROUND(100 * COUNTIF(sk_etablissement = -1) / COUNT(*), 2) FROM `big-data-cloud-healthcare-unit.chu_gold.fact_consultation`
UNION ALL SELECT 'consultation -> diagnostic', ROUND(100 * COUNTIF(sk_diagnostic = -1) / COUNT(*), 2) FROM `big-data-cloud-healthcare-unit.chu_gold.fact_consultation`
UNION ALL SELECT 'hospitalisation -> patient', ROUND(100 * COUNTIF(sk_patient = -1) / COUNT(*), 2) FROM `big-data-cloud-healthcare-unit.chu_gold.fact_hospitalisation`
UNION ALL SELECT 'hospitalisation -> établissement', ROUND(100 * COUNTIF(sk_etablissement = -1) / COUNT(*), 2) FROM `big-data-cloud-healthcare-unit.chu_gold.fact_hospitalisation`
UNION ALL SELECT 'hospitalisation -> diagnostic', ROUND(100 * COUNTIF(sk_diagnostic = -1) / COUNT(*), 2) FROM `big-data-cloud-healthcare-unit.chu_gold.fact_hospitalisation`
UNION ALL SELECT 'décès -> localisation', ROUND(100 * COUNTIF(sk_localisation = -1) / COUNT(*), 2) FROM `big-data-cloud-healthcare-unit.chu_gold.fact_deces`
UNION ALL SELECT 'satisfaction -> établissement (FINESS)', ROUND(100 * COUNTIF(sk_etablissement = -1) / COUNT(*), 2) FROM `big-data-cloud-healthcare-unit.chu_gold.fact_satisfaction`
UNION ALL SELECT 'satisfaction -> localisation (région)', ROUND(100 * COUNTIF(sk_localisation = -1) / COUNT(*), 2) FROM `big-data-cloud-healthcare-unit.chu_gold.fact_satisfaction`
ORDER BY jointure;

-- 2. Campagne de satisfaction présente (2020)

SELECT sk_date_campagne, COUNT(*) AS nb_etablissements FROM `big-data-cloud-healthcare-unit.chu_gold.fact_satisfaction` GROUP BY 1;

-- 3. check des copies
SELECT 'consultation' AS fait,
       (SELECT COUNT(*) FROM `big-data-cloud-healthcare-unit.chu_gold.fact_consultation`)    AS gold,
       (SELECT COUNT(*) FROM `big-data-cloud-healthcare-unit.benchmark.fact_consultation_brut`) AS brut
UNION ALL SELECT 'hospitalisation', (SELECT COUNT(*) FROM `big-data-cloud-healthcare-unit.chu_gold.fact_hospitalisation`), (SELECT COUNT(*) FROM `big-data-cloud-healthcare-unit.benchmark.fact_hospitalisation_brut`)
UNION ALL SELECT 'deces',           (SELECT COUNT(*) FROM `big-data-cloud-healthcare-unit.chu_gold.fact_deces`),           (SELECT COUNT(*) FROM `big-data-cloud-healthcare-unit.benchmark.fact_deces_brut`)
UNION ALL SELECT 'satisfaction',    (SELECT COUNT(*) FROM `big-data-cloud-healthcare-unit.chu_gold.fact_satisfaction`),    (SELECT COUNT(*) FROM `big-data-cloud-healthcare-unit.benchmark.fact_satisfaction_brut`);
