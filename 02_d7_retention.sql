-- 02_d7_retention.sql
-- Calculates D1, D7, D30 retention proxies + engagement rate

WITH base AS (
  SELECT * FROM `project.dataset.cleaned_cohort`
),
metrics AS (
  SELECT
    Category,
    COUNT(*) AS app_count,
    AVG(Rating) AS avg_rating,
    SUM(installs_int) AS total_installs,
    AVG(SAFE_DIVIDE(Reviews, installs_int)) AS engagement_rate,
    AVG(CASE WHEN Rating < 4.0 THEN 1 ELSE 0 END) AS at_risk_ratio,
    PERCENTILE_CONT(Rating, 0.5) OVER (PARTITION BY Category) AS median_rating
  FROM base
  GROUP BY Category
)
SELECT
  Category,
  app_count,
  avg_rating,
  total_installs,
  engagement_rate,
  at_risk_ratio,
  RANK() OVER (ORDER BY avg_rating DESC) AS category_rank,
  CASE WHEN avg_rating < 4.0 THEN 'At Risk' ELSE 'Healthy' END AS health_status
FROM metrics
ORDER BY total_installs DESC;
