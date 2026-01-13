# Silver Load – Business Rules

## Scope
This ETL script performs a **full refresh** from `public` (raw Northwind) into `silver` tables.  
The goal is to keep the Silver layer structurally close to raw, while applying only **safe, low-risk standardization** to reduce BI friction.

## Global rules
1. **Full refresh strategy**
   - Each Silver table is truncated and reloaded on every run.
   - The output represents the current snapshot of `public`.

2. **No enrichment / no KPI calculations**
   - The script does not compute sales metrics or build star schema objects.
   - Only light standardization is applied.

## Table-level rules

### customers
- **region**
  - If `region` is NULL, replace it with `'N/A'`.
- **fax**
  - If `fax` is NULL, replace it with `'N/A'`.

### employees
- **region**
  - If `region` is NULL, replace it with `'N/A'`.
- **reports_to**
  - If `reports_to` is NULL, replace it with `0`.

### orders
- **ship_region**
  - If `ship_region` is NULL, replace it with `'N/A'`.

### products
- **reorder_level normalization**
  - If `discontinued = 1`, set `reorder_level = 0`.
  - Otherwise keep the original `reorder_level`.

### suppliers
- **region**
  - If `region` is NULL, replace it with `'N/A'`.
- **fax**
  - If `fax` is NULL, replace it with `'N/A'`.
- **homepage**
  - If `homepage` is NULL, replace it with `'N/A'`.

## Notes / assumptions
- `'N/A'` is used as a technical placeholder to prevent NULL propagation in BI filters and slicers.
- The value `0` for `reports_to` is a placeholder for “no manager recorded” and must be handled explicitly in reporting if needed.
