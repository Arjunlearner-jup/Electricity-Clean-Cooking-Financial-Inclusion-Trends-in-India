#cleaning wdiseries
CREATE TABLE `wdi_india`.`wdiseries_clean` AS
SELECT
    NULLIF(TRIM(`C1`), '')  AS `Series Code`,
    NULLIF(TRIM(`C2`), '')  AS `Topic`,
    NULLIF(TRIM(`C3`), '')  AS `Indicator Name`,
    NULLIF(TRIM(`C4`), '')  AS `Short definition`,
    NULLIF(TRIM(`C5`), '')  AS `Long definition`,
    NULLIF(TRIM(`C6`), '')  AS `Unit of measure`,
    NULLIF(TRIM(`C7`), '')  AS `Periodicity`,
    NULLIF(TRIM(`C8`), '')  AS `Base Period`,
    NULLIF(TRIM(`C9`), '')  AS `Other notes`,
    NULLIF(TRIM(`C10`), '') AS `Aggregation method`,
    NULLIF(TRIM(`C11`), '') AS `Limitations and exceptions`,
    NULLIF(TRIM(`C12`), '') AS `Notes from original source`,
    NULLIF(TRIM(`C13`), '') AS `General comments`,
    NULLIF(TRIM(`C14`), '') AS `Source`,
    NULLIF(TRIM(`C15`), '') AS `Statistical concept and methodology`,
    NULLIF(TRIM(`C16`), '') AS `Development relevance`,
    NULLIF(TRIM(`C17`), '') AS `Related source links`,
    NULLIF(TRIM(`C18`), '') AS `Other web links`,
    NULLIF(TRIM(`C19`), '') AS `Related indicators`,
    NULLIF(TRIM(`C20`), '') AS `License Type`
FROM `wdi_india`.`wdiseries`
WHERE `C1` <> 'Series Code';

#Validate row count and required fields:
SELECT
    (SELECT COUNT(*) FROM `wdi_india`.`wdiseries`) AS source_rows,
    (SELECT COUNT(*) FROM `wdi_india`.`wdiseries`
     WHERE `C1` <> 'Series Code') AS expected_clean_rows,
    COUNT(*) AS clean_rows,
    SUM(`Series Code` IS NULL) AS missing_series_codes,
    SUM(`Indicator Name` IS NULL) AS missing_indicator_names,
    COUNT(DISTINCT `Series Code`) AS distinct_series_codes
FROM `wdi_india`.`wdiseries_clean`;

#Check for duplicate codes; this should return no rows if codes are unique:
SELECT `Series Code`, COUNT(*) AS occurrences
FROM `wdi_india`.`wdiseries_clean`
WHERE `Series Code` IS NOT NULL
GROUP BY `Series Code`
HAVING COUNT(*) > 1;

#Check that every indicator in your cleaned dataset1 has a matching series record:
SELECT DISTINCT d.indicator_code
FROM `wdi_india`.`dataset1_clean_long` AS d
LEFT JOIN `wdi_india`.`wdiseries_clean` AS s
    ON d.indicator_code = s.`Series Code`
WHERE s.`Series Code` IS NULL;
