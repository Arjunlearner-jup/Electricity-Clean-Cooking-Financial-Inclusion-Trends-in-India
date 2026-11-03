# Trends and Inequalities in Electricity, Clean-Cooking Access and Financial Inclusion in India

Th project cleans three World Development Indicators (WDI) source tables in the `wdi_india` database: `dataset1`, `wdicountry`, and `wdiseries`. The SQL scripts use MySQL syntax. Run each script against a database containing the corresponding raw table.

## Source tables and scripts

| Source table | Cleaning script | Cleaned output |
|:-------------|:----------------|:---------------|
| `dataset1` | [`dataset1_cleaning.sql`] | `dataset1_clean_long` |
| `wdicountry` | [`wdicountry_cleaning.sql`] | `wdicountry_clean` |
| `wdiseries` | [`wdiseries_cleaning.sql`] | `wdiseries_clean` |
## `dataset1` → `dataset1_clean_long`

The raw `dataset1` table is in WDI wide format: its first four columns identify the country and indicator, while columns `C4` through `C69` hold yearly values.

The cleaning script:

1. Reports the raw row count, header-row count, number of distinct indicator codes, and rows with missing country or indicator identifiers.
2. Expands the 66 year-value columns (`C4`–`C69`) into separate rows using `JSON_TABLE`, producing one record per source row and year.
3. Trims the country and indicator identifiers and converts empty strings to `NULL`.
4. Assigns years from 1960 through 2025 using the value-column position (ordinal + 1959).
5. Preserves each source value as `raw_value`. Converts values matching a numeric pattern to `DECIMAL(38,15)` in `value`; blank values and nonnumeric values become `NULL` in `value`.
6. Labels each value as `VALID`, `MISSING`, or `INVALID` in `value_status`.
7. Validates the resulting row and indicator counts, year range, missing and invalid values, and zero values; it also lists any invalid raw values for review.

The script includes an expected row-count note of 98,868 rows (1,498 indicators × 66 years). Treat this as an expectation to compare with the validation output, not a guaranteed result if the source data differs.

## `wdicountry` → `wdicountry_clean`

This table contains country-level metadata. The script:

1. Creates `wdicountry_clean` with the same columns and types as `wdicountry` using `CREATE TABLE ... LIKE`.
2. Inserts the listed country metadata columns from the source, trimming text and replacing empty strings with `NULL`. The national accounts reference year is copied directly.
3. Checks the clean row count against the source, missing country codes and short names, distinct country codes, and codes with surrounding spaces.
4. Looks for duplicate non-null country codes.

## `wdiseries` → `wdiseries_clean`

This table contains indicator-series metadata. The raw table uses generic column names (`C1`–`C20`). The script:

1. Creates `wdiseries_clean` by selecting those columns with descriptive names, such as `Series Code`, `Indicator Name`, `Unit of measure`, and `Source`.
2. Trims text and replaces empty strings with `NULL`; excludes the header row where `C1` is `Series Code`.
3. Checks source and cleaned row counts, missing series codes or indicator names, and distinct series codes.
4. Looks for duplicate series codes.
5. Compares indicator codes in `dataset1_clean_long` with `wdiseries_clean` and returns codes with no matching series metadata.

Run `dataset1_cleaning.sql` and `wdiseries_cleaning.sql` before the cross-table matching check in `wdiseries_cleaning.sql`, because that check reads `dataset1_clean_long`. The scripts create tables and insert data, so rerunning them may require removing or renaming existing cleaned tables first. In particular, `wdicountry_cleaning.sql` creates its output with `CREATE TABLE` and does not drop an existing output table.

## Outputs at a glance

- `dataset1_clean_long`: country and indicator identifiers, year, original raw value, parsed numeric value, and parse status.
- `wdicountry_clean`: trimmed country metadata with blank text values normalized to `NULL`.
- `wdiseries_clean`: descriptive indicator metadata columns with blank text values normalized to `NULL`.

The validation statements report issues for inspection; they do not automatically repair invalid numeric values, duplicate codes, or unmatched indicators.

## Analysis queries

[`Data analysis.sql`](Data%20analysis.sql) contains five read-only analyses using `dataset1_clean_long` and, where needed, `wdiseries_clean`:

1. **Electricity access over time** — Returns yearly values for indicator `EG.ELC.ACCS.ZS` with its unit of measure.
2. **Rural and urban access gaps** — Compares four rural and urban electricity and clean-fuel access indicators over time.
3. **Latest value by indicator** — Finds the most recent non-null value and year for each indicator, adding its unit of measure.
4. **Data coverage** — Counts observed and missing years per indicator, calculates the missing percentage, and reports the first and latest years with values.
5. **Financial account ownership by gender** — Compares female and male account ownership by year and calculates the difference in percentage points when both values are present.

These queries expect the cleaned tables to exist. The first, third, and fifth queries also use MySQL-specific syntax or behavior; run them in the intended MySQL-compatible environment.
