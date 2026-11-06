
CREATE OR REPLACE TABLE `big-data-cloud-healthcare-unit.benchmark.fact_consultation_brut`
OPTIONS (description = "Benchmark - copie de chu_gold.fact_consultation SANS partitionnement ni clustering")
AS SELECT * FROM `big-data-cloud-healthcare-unit.chu_gold.fact_consultation`;

CREATE OR REPLACE TABLE `big-data-cloud-healthcare-unit.benchmark.fact_hospitalisation_brut`
OPTIONS (description = "Benchmark - copie de chu_gold.fact_hospitalisation SANS partitionnement ni clustering")
AS SELECT * FROM `big-data-cloud-healthcare-unit.chu_gold.fact_hospitalisation`;

CREATE OR REPLACE TABLE `big-data-cloud-healthcare-unit.benchmark.fact_deces_brut`
OPTIONS (description = "Benchmark - copie de chu_gold.fact_deces SANS partitionnement ni clustering")
AS SELECT * FROM `big-data-cloud-healthcare-unit.chu_gold.fact_deces`;

CREATE OR REPLACE TABLE `big-data-cloud-healthcare-unit.benchmark.fact_satisfaction_brut`
OPTIONS (description = "Benchmark - copie de chu_gold.fact_satisfaction SANS partitionnement ni clustering")
AS SELECT * FROM `big-data-cloud-healthcare-unit.chu_gold.fact_satisfaction`;
