-- 01_create_cohort.sql
-- Creates fact table and cleans Play Store data
-- Google BigQuery Standard SQL

WITH cleaned AS (
  SELECT
    App,
    Category,
    CAST(REGEXP_REPLACE(Installs, r'[^0-9]', '') AS INT64) AS installs_int,
    Rating,
    Reviews,
    Size,
    Type,
    Price,
    PARSE_DATE('%B %d, %Y', Last_Updated) AS last_updated_date
  FROM `project.dataset.google_play_raw`
  WHERE App IS NOT NULL
),
ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Rating DESC) AS rank_in_category,
    AVG(Rating) OVER (PARTITION BY Category) AS avg_category_rating,
    LAG(Rating) OVER (PARTITION BY Category ORDER BY Reviews DESC) AS prev_rating
  FROM cleaned
)
SELECT * FROM ranked;
