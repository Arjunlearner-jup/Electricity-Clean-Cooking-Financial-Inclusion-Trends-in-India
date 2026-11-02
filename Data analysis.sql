#Use one indicator per chart, or compare related indicators that share a unit. Replace the code to explore a different indicator.
#linechart
SELECT
    l.year,
    l.indicator_code,
    l.indicator_name,
    s.`Unit of measure` AS unit,
    l.value
FROM `wdi_india`.`dataset1_clean_long` AS l
LEFT JOIN `wdi_india`.`wdiseries_clean` AS s
    ON l.indicator_code = s.`Series Code`
WHERE l.indicator_code = 'EG.ELC.ACCS.ZS'
  AND l.value IS NOT NULL
ORDER BY l.year;

# 2. Rural–urban access gaps — multi-line chart
#Plot year against value, with indicator name as the series. These access indicators use percentages, which makes the comparison interpretable.
SELECT
    l.year,
    l.indicator_code,
    l.indicator_name,
    l.value
FROM `wdi_india`.`dataset1_clean_long` AS l
WHERE l.indicator_code IN (
    'EG.ELC.ACCS.RU.ZS',
    'EG.ELC.ACCS.UR.ZS',
    'EG.CFT.ACCS.RU.ZS',
    'EG.CFT.ACCS.UR.ZS'
)
  AND l.value IS NOT NULL
ORDER BY l.indicator_code, l.year;

# 3. Latest available value by indicator — bar chart or KPI table
#This returns each indicator’s latest reported year and value. The latest year may differ by indicator, so show the year alongside each value.

WITH ranked AS (
    SELECT
        l.indicator_code,
        l.indicator_name,
        l.year,
        l.value,
        ROW_NUMBER() OVER (
            PARTITION BY l.indicator_code
            ORDER BY l.year DESC
        ) AS rn
    FROM `wdi_india`.`dataset1_clean_long` AS l
    WHERE l.value IS NOT NULL
)
SELECT
    r.indicator_code,
    r.indicator_name,
    s.`Unit of measure` AS unit,
    r.year AS latest_year,
    r.value AS latest_value
FROM ranked AS r
LEFT JOIN `wdi_india`.`wdiseries_clean` AS s
    ON r.indicator_code = s.`Series Code`
WHERE r.rn = 1
ORDER BY r.indicator_name;

# 4. Data coverage — missingness chart

SELECT
    l.indicator_code,
    l.indicator_name,
    COUNT(*) AS years_in_table,
    COUNT(l.value) AS years_with_values,
    SUM(l.value IS NULL) AS missing_years,
    ROUND(100 * SUM(l.value IS NULL) / COUNT(*), 1) AS percent_missing,
    MIN(CASE WHEN l.value IS NOT NULL THEN l.year END) AS first_available_year,
    MAX(CASE WHEN l.value IS NOT NULL THEN l.year END) AS latest_available_year
FROM `wdi_india`.`dataset1_clean_long` AS l
GROUP BY l.indicator_code, l.indicator_name
ORDER BY percent_missing DESC, l.indicator_name;

#5. Financial account ownership by gender — line chart
SELECT
    year,
    MAX(CASE
        WHEN indicator_code = 'FX.OWN.TOTL.FE.ZS' THEN value
    END) AS female_percent,
    MAX(CASE
        WHEN indicator_code = 'FX.OWN.TOTL.MA.ZS' THEN value
    END) AS male_percent,
    MAX(CASE
        WHEN indicator_code = 'FX.OWN.TOTL.MA.ZS' THEN value
    END)
    - MAX(CASE
        WHEN indicator_code = 'FX.OWN.TOTL.FE.ZS' THEN value
    END) AS gender_gap_percentage_points
FROM `wdi_india`.`dataset1_clean_long`
WHERE indicator_code IN (
    'FX.OWN.TOTL.FE.ZS',
    'FX.OWN.TOTL.MA.ZS'
)
GROUP BY year
HAVING female_percent IS NOT NULL
   AND male_percent IS NOT NULL
ORDER BY year;


