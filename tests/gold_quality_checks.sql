/*
===============================================================================
gold_quality_checks.sql (PostgreSQL)
===============================================================================
Purpose:
    Validate the Gold layer views used for analytics / BI by checking:
    - Uniqueness of business keys in dimension views (no duplicate keys).
    - Star schema join behavior (no row explosion when joining fact to dims).

Usage:
    Run after refreshing / recreating Gold views.
    Any returned rows indicate an issue that should be investigated.
===============================================================================
*/

-- quality gold checks

-- Check: duplicate customer_id in gold.dim_customers
-- Expectation: No results
SELECT 
	customer_id,
	COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1

-- Check: duplicate date in gold.dim_date
-- Expectation: No results
SELECT 
	date,
	COUNT(*) AS duplicate_count
FROM gold.dim_date
GROUP BY date
HAVING COUNT(*) > 1

-- Check: duplicate employee_id in gold.dim_employees
-- Expectation: No results
SELECT 
	employee_id,
	COUNT(*) AS duplicate_count
FROM gold.dim_employees
GROUP BY employee_id
HAVING COUNT(*) > 1

-- Check: duplicate product_id in gold.dim_products
-- Expectation: No results
SELECT 
	product_id,
	COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1

-- Check: duplicate shipper_id in gold.dim_shippers
-- Expectation: No results
SELECT 
	shipper_id,
	COUNT(*) AS duplicate_count
FROM gold.dim_shippers
GROUP BY shipper_id
HAVING COUNT(*) > 1

-- Connectivity preview: joins fact to dimensions (manual inspection)
-- Note: this query alone does not "fail" when keys don't match; it is a raw joined output.
SELECT 
	*
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS c
	ON fs.customer_id = c.customer_id
LEFT JOIN gold.dim_employees AS e
	ON fs.employee_id = e.employee_id
LEFT JOIN gold.dim_products AS p
	ON fs.product_id = p.product_id
LEFT JOIN gold.dim_shippers AS s
	ON fs.shipper_id = s.shipper_id

-- Check: row explosion test
-- Expectation: joined_rows = fact_rows
-- If joined_rows > fact_rows, at least one dimension join multiplies fact rows
SELECT
  (	SELECT 
  		COUNT(*) 
	FROM gold.fact_sales) AS fact_rows,
  ( SELECT 
  		COUNT(*)
   	FROM gold.fact_sales fs
   LEFT JOIN gold.dim_customers AS c ON fs.customer_id = c.customer_id
   LEFT JOIN gold.dim_employees AS e ON fs.employee_id = e.employee_id
   LEFT JOIN gold.dim_products  AS p ON fs.product_id  = p.product_id
   LEFT JOIN gold.dim_shippers  AS s ON fs.shipper_id  = s.shipper_id
  ) AS joined_rows;
