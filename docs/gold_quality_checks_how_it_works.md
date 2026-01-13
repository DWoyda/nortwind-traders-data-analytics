# Gold Quality Checks — How It Works

## Overview
The script runs in three logical blocks:
1) Duplicate detection in each dimension view.
2) A raw fact-to-dim join output for manual spot-checking.
3) A numeric test comparing row counts before and after joins (row explosion test).

## Step-by-step

### 1) Duplicate checks (per dimension)
Each query groups by the dimension join key and returns only keys where `COUNT(*) > 1`.
If any row is returned, the dimension is not safe for joining.

### 2) Connectivity preview join
A `SELECT *` with `LEFT JOIN`s shows the combined dataset.
This is mainly for manual inspection (sampling rows, verifying columns look consistent).

Important:
- This query does not automatically flag missing matches.
- A `LEFT JOIN` will still return rows even if a dimension match is missing.

### 3) Row explosion test
Two counts are computed:
- `fact_rows`: number of rows in `gold.fact_sales`
- `joined_rows`: number of rows after left-joining all dimensions

Interpretation:
- If `joined_rows = fact_rows` → joins do not multiply rows (good).
- If `joined_rows > fact_rows` → at least one join multiplies fact rows (problem).
- If `joined_rows < fact_rows` → unlikely with `LEFT JOIN`; would indicate filtering (not present here).

## What this script does NOT check
- It does not explicitly list unmatched foreign keys (orphans).  
  That requires a `WHERE dim_key IS NULL` filter after a `LEFT JOIN`.
