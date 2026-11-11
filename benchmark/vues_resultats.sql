
CREATE OR REPLACE VIEW `big-data-cloud-healthcare-unit.benchmark.v_resultats_benchmark` AS
WITH mesures AS (
  SELECT
    REGEXP_EXTRACT(query, r'BENCH (Q\d+)')               AS requete,
    IF(query LIKE '%_brut`%', 'Avant', 'Après')          AS version,
    TIMESTAMP_DIFF(end_time, start_time, MILLISECOND)    AS temps_ms,
    total_bytes_processed / 1000000                      AS mo_lus,
    total_slot_ms                                        AS slot_ms
  FROM `big-data-cloud-healthcare-unit`.`region-europe-west9`.INFORMATION_SCHEMA.JOBS_BY_USER
  WHERE query LIKE '%BENCH Q%'          
    AND statement_type = 'SELECT' 
    AND error_result IS NULL            -- exclus les erreur
    AND cache_hit IS NOT TRUE           -- exclus le cache

)
SELECT
  requete,
  version,
  COUNT(*)                                   AS nb_executions,
  APPROX_QUANTILES(temps_ms, 2)[OFFSET(1)]   AS temps_median_ms,
  APPROX_QUANTILES(mo_lus, 2)[OFFSET(1)]     AS mo_lus_median,
  APPROX_QUANTILES(slot_ms, 2)[OFFSET(1)]    AS slot_ms_median
FROM mesures
GROUP BY requete, version;
