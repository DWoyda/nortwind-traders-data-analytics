# Silver Load – How the Script Works

## What it does
The script loads data from `public` schema into `silver` schema tables using a consistent pattern:

1. **TRUNCATE TABLE silver.<table>**
   - Removes all rows from the target Silver table.
   - This makes the load deterministic: the final content depends only on the current raw data.

2. **INSERT INTO silver.<table> (...) SELECT ... FROM public.<table>**
   - Reloads all rows from the corresponding raw table.
   - For selected columns, lightweight transformations are applied (mainly `COALESCE` and one `CASE` expression).

## Execution characteristics
- **Idempotent output:** running it multiple times produces the same result (assuming raw data didn’t change).
- **Order of statements:** each table is processed independently (truncate + insert).  
  There is no dependency between the inserts in this script because each insert reads from `public` and writes to `silver`.

## Why these transformations exist
- `COALESCE(..., 'N/A')` prevents NULL values from causing confusing BI behavior (missing categories in slicers / blanks in labels).
- `COALESCE(reports_to, 0)` ensures a single consistent placeholder for missing manager references.
- `CASE WHEN discontinued = 1 THEN 0 ELSE reorder_level END` ensures that discontinued products do not carry a reorder signal in the Silver layer.

## What this script intentionally does NOT do
- Does not create fact/dimension views.
- Does not compute sales amounts or aggregates.
- Does not enforce constraints or deduplicate records.
- Does not standardize country/region codes beyond replacing NULLs.
