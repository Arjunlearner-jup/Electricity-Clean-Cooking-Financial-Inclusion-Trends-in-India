#data cleaning

#1
CREATE TABLE `wdi_india`.`wdicountry_clean`
LIKE `wdi_india`.`wdicountry`;

#3
INSERT INTO `wdi_india`.`wdicountry_clean` (
    `Country Code`,
    `Short Name`,
    `Table Name`,
    `Long Name`,
    `2-alpha code`,
    `Currency Unit`,
    `Special Notes`,
    `Region`,
    `Income Group`,
    `WB-2 code`,
    `National accounts base year`,
    `National accounts reference year`,
    `SNA price valuation`,
    `Lending category`,
    `Other groups`,
    `System of National Accounts`,
    `Alternative conversion factor`,
    `PPP survey year`,
    `Balance of Payments Manual in use`,
    `External debt Reporting status`,
    `System of trade`,
    `Government Accounting concept`,
    `IMF data dissemination standard`,
    `Latest population census`,
    `Latest household survey`,
    `Source of most recent Income and expenditure data`,
    `Vital registration complete`,
    `Latest agricultural census`,
    `Latest industrial data`,
    `Latest trade data`,
    `Latest water withdrawal data`
)
SELECT
    NULLIF(TRIM(`Country Code`), ''),
    NULLIF(TRIM(`Short Name`), ''),
    NULLIF(TRIM(`Table Name`), ''),
    NULLIF(TRIM(`Long Name`), ''),
    NULLIF(TRIM(`2-alpha code`), ''),
    NULLIF(TRIM(`Currency Unit`), ''),
    NULLIF(TRIM(`Special Notes`), ''),
    NULLIF(TRIM(`Region`), ''),
    NULLIF(TRIM(`Income Group`), ''),
    NULLIF(TRIM(`WB-2 code`), ''),
    NULLIF(TRIM(`National accounts base year`), ''),
    `National accounts reference year`,
    NULLIF(TRIM(`SNA price valuation`), ''),
    NULLIF(TRIM(`Lending category`), ''),
    NULLIF(TRIM(`Other groups`), ''),
    NULLIF(TRIM(`System of National Accounts`), ''),
    NULLIF(TRIM(`Alternative conversion factor`), ''),
    NULLIF(TRIM(`PPP survey year`), ''),
    NULLIF(TRIM(`Balance of Payments Manual in use`), ''),
    NULLIF(TRIM(`External debt Reporting status`), ''),
    NULLIF(TRIM(`System of trade`), ''),
    NULLIF(TRIM(`Government Accounting concept`), ''),
    NULLIF(TRIM(`IMF data dissemination standard`), ''),
    NULLIF(TRIM(`Latest population census`), ''),
    NULLIF(TRIM(`Latest household survey`), ''),
    NULLIF(TRIM(`Source of most recent Income and expenditure data`), ''),
    NULLIF(TRIM(`Vital registration complete`), ''),
    NULLIF(TRIM(`Latest agricultural census`), ''),
    NULLIF(TRIM(`Latest industrial data`), ''),
    NULLIF(TRIM(`Latest trade data`), ''),
    NULLIF(TRIM(`Latest water withdrawal data`), '')
FROM `wdi_india`.`wdicountry`;

#validate row count, missing country codes, and duplicate codes:
SELECT
    COUNT(*) AS rows_in_clean_table,
    SUM(`Country Code` IS NULL OR TRIM(`Country Code`) = '') AS missing_country_codes,
    COUNT(DISTINCT `Country Code`) AS distinct_country_codes
FROM `wdi_india`.`wdicountry_clean`;


SELECT `Country Code`, COUNT(*) AS occurrences
FROM `wdi_india`.`wdicountry_clean`
WHERE `Country Code` IS NOT NULL
GROUP BY `Country Code`
HAVING COUNT(*) > 1;

#VALIDATION....
SELECT
    COUNT(*) AS clean_rows,
    (SELECT COUNT(*) FROM `wdi_india`.`wdicountry`) AS source_rows,
    COUNT(*) = (SELECT COUNT(*) FROM `wdi_india`.`wdicountry`)
        AS row_count_matches,
    SUM(`Country Code` IS NULL OR TRIM(`Country Code`) = '')
        AS missing_country_codes,
    SUM(`Short Name` IS NULL OR TRIM(`Short Name`) = '')
        AS missing_short_names,
    COUNT(DISTINCT `Country Code`) AS distinct_country_codes,
    SUM(`Country Code` IS NOT NULL AND `Country Code` <> TRIM(`Country Code`))
        AS country_codes_with_outer_spaces
FROM `wdi_india`.`wdicountry_clean`;


SELECT `Country Code`, COUNT(*) AS occurrences
FROM `wdi_india`.`wdicountry_clean`
WHERE `Country Code` IS NOT NULL
GROUP BY `Country Code`
HAVING COUNT(*) > 1;