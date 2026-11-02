# data cleaning for dataset1
SELECT
    COUNT(*) AS total_rows,
    SUM(`C0` = 'Country Name') AS header_rows,
    COUNT(DISTINCT CASE WHEN `C0` <> 'Country Name' THEN TRIM(`C3`) END) AS indicator_count,
    SUM(CASE
        WHEN `C0` <> 'Country Name'
         AND (NULLIF(TRIM(`C0`), '') IS NULL
           OR NULLIF(TRIM(`C1`), '') IS NULL
           OR NULLIF(TRIM(`C2`), '') IS NULL
           OR NULLIF(TRIM(`C3`), '') IS NULL)
        THEN 1 ELSE 0
    END) AS rows_with_missing_identifiers
FROM `wdi_india`.`dataset1`;

#2
CREATE TABLE `wdi_india`.`dataset1_clean_long` AS
SELECT
    NULLIF(TRIM(d.`C0`), '') AS country_name,
    NULLIF(TRIM(d.`C1`), '') AS country_code,
    NULLIF(TRIM(d.`C2`), '') AS indicator_name,
    NULLIF(TRIM(d.`C3`), '') AS indicator_code,
    jt.ordinal + 1959 AS year,
    NULLIF(TRIM(jt.raw_value), '') AS raw_value,
    CASE
        WHEN NULLIF(TRIM(jt.raw_value), '') IS NULL THEN NULL
        WHEN TRIM(jt.raw_value) REGEXP '^[+-]?[0-9]+([.][0-9]+)?([eE][+-]?[0-9]+)?$'
            THEN CAST(TRIM(jt.raw_value) AS DECIMAL(38,15))
        ELSE NULL
    END AS value,
    CASE
        WHEN NULLIF(TRIM(jt.raw_value), '') IS NULL THEN 'MISSING'
        WHEN TRIM(jt.raw_value) REGEXP '^[+-]?[0-9]+([.][0-9]+)?([eE][+-]?[0-9]+)?$'
            THEN 'VALID'
        ELSE 'INVALID'
    END AS value_status
FROM `wdi_india`.`dataset1` AS d
CROSS JOIN JSON_TABLE(
    JSON_ARRAY(
        d.`C4`,  d.`C5`,  d.`C6`,  d.`C7`,  d.`C8`,  d.`C9`,
        d.`C10`, d.`C11`, d.`C12`, d.`C13`, d.`C14`, d.`C15`,
        d.`C16`, d.`C17`, d.`C18`, d.`C19`, d.`C20`, d.`C21`,
        d.`C22`, d.`C23`, d.`C24`, d.`C25`, d.`C26`, d.`C27`,
        d.`C28`, d.`C29`, d.`C30`, d.`C31`, d.`C32`, d.`C33`,
        d.`C34`, d.`C35`, d.`C36`, d.`C37`, d.`C38`, d.`C39`,
        d.`C40`, d.`C41`, d.`C42`, d.`C43`, d.`C44`, d.`C45`,
        d.`C46`, d.`C47`, d.`C48`, d.`C49`, d.`C50`, d.`C51`,
        d.`C52`, d.`C53`, d.`C54`, d.`C55`, d.`C56`, d.`C57`,
        d.`C58`, d.`C59`, d.`C60`, d.`C61`, d.`C62`, d.`C63`,
        d.`C64`, d.`C65`, d.`C66`, d.`C67`, d.`C68`, d.`C69`
    ),
    '$[*]' COLUMNS (
        ordinal FOR ORDINALITY,
        raw_value VARCHAR(255) PATH '$'
    )
) AS jt
WHERE d.`C0` <> 'Country Name';


#Validate the cleaned data:
SELECT
    COUNT(*) AS rows_created,
    COUNT(DISTINCT indicator_code) AS indicators,
    SUM(value_status = 'MISSING') AS missing_values,
    SUM(value_status = 'INVALID') AS invalid_values,
    SUM(value = 0) AS zero_values
FROM `wdi_india`.`dataset1_clean_long`;

#Find any year values that could not be converted:
SELECT indicator_code, indicator_name, year, raw_value
FROM `wdi_india`.`dataset1_clean_long`
WHERE value_status = 'INVALID'
ORDER BY indicator_code, year;

#validate the result
-- Expect 98,868 rows: 1,498 indicators × 66 years
SELECT
    COUNT(*) AS rows_created,
    COUNT(DISTINCT indicator_code) AS indicators,
    MIN(year) AS first_year,
    MAX(year) AS last_year,
    SUM(value_status = 'MISSING') AS missing_values,
    SUM(value_status = 'INVALID') AS invalid_values
FROM `wdi_india`.`dataset1_clean_long`;


