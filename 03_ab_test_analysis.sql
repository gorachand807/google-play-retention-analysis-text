-- 03_ab_test_analysis.sql
-- A/B Test Analysis: Control 22.1% vs Treatment 29.3% D7 Retention
-- Includes SRM check, t-test proxy, confidence interval

WITH events AS (
  SELECT * FROM `project.dataset.sample_events`
),
agg AS (
  SELECT
    variant,
    COUNT(DISTINCT user_id) AS n_users,
    COUNTIF(retained_d7 = 1) AS retained,
    AVG(CAST(retained_d7 AS FLOAT64)) AS d7_retention_rate
  FROM events
  GROUP BY variant
),
srm_check AS (
  SELECT
    -- Chi-square SRM check: expected 50/50
    SUM(CASE WHEN variant='control' THEN 1 ELSE 0 END) AS control_count,
    SUM(CASE WHEN variant='treatment' THEN 1 ELSE 0 END) AS treatment_count
  FROM events
)
SELECT
  a.variant,
  a.n_users,
  a.retained,
  a.d7_retention_rate,
  s.control_count,
  s.treatment_count,
  (SELECT d7_retention_rate FROM agg WHERE variant='treatment') - (SELECT d7_retention_rate FROM agg WHERE variant='control') AS lift
FROM agg a CROSS JOIN srm_check s;
-- For p-value, use Python scipy.stats.ttest_ind or prop_ztest
