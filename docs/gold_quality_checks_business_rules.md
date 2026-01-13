# Gold Quality Checks — Business Rules

## Purpose
These checks validate that the Gold layer (fact + dimensions) is safe for BI reporting and does not produce incorrect totals due to model issues.

## Business Rules Implemented

### 1) Dimension key uniqueness
**Rule:** Each dimension must contain at most one row per business key used for joining from the fact table.

Checked keys:
- `gold.dim_customers.customer_id`
- `gold.dim_date.date`
- `gold.dim_employees.employee_id`
- `gold.dim_products.product_id`
- `gold.dim_shippers.shipper_id`

**Expected result:** 0 duplicate rows returned by each duplicate check.

**Why it matters:**  
Duplicate keys in a dimension can multiply fact rows during joins, inflating sums and counts in BI.

### 2) Join row explosion prevention
**Rule:** Joining the fact table to all dimensions must not increase the number of rows.

**Expected result:** `joined_rows = fact_rows`

**Why it matters:**  
If `joined_rows > fact_rows`, at least one dimension join is not 1-to-many as intended, causing incorrect aggregations in dashboards.
