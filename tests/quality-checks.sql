-- PURPOSE:
-- Run data quality checks on Northwind RAW tables (schema: public) before building the Silver layer.
-- The script validates primary keys, basic text cleanliness, sales-critical numeric fields, and date sanity.

-- ======================================================================
/*
QUALITY CHECKS SCOPE

DIMENSIONS
- categories
- customers
- employees
- products
- region
- shippers
- suppliers
- territories
- us_states

FACTS
- orders         (order header)
- order_details  (order lines)

BRIDGE / LINK TABLES
- employee_territories
- customer_customer_demo (often empty)

OPTIONAL
- customer_demographics (often empty)
*/
-- ======================================================================

-- ======================================================================
-- categories
-- ======================================================================

-- Check: PK integrity (category_id must be unique and not NULL)
-- Expectation: No Results
SELECT 
	category_id,
	COUNT(*)
FROM categories
GROUP BY category_id
HAVING COUNT(*) > 1 OR category_id IS NULL

-- Check: Required field (category_name should not be NULL/empty)
-- Expectation: 0
SELECT 
	COUNT(*)
FROM public.categories
WHERE category_name IS NULL 
	OR TRIM(category_name) = '';

-- Check: Text cleanliness (description should not have leading/trailing spaces; only where NOT NULL)
-- Expectation: No Results
SELECT 
	description
FROM categories
WHERE description IS NOT NULL 
	AND description!= TRIM(description)

-- ======================================================================
-- customer_customer_demo -> EMPTY (ignore)
-- ======================================================================
-- ======================================================================
-- customer_demographics -> EMPTY (ignore)
-- ======================================================================
-- ======================================================================
-- customers
-- ======================================================================

-- Check: PK integrity (customer_id must be unique and not NULL)
-- Expectation: No Results
SELECT
	customer_id,
	COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1 OR customer_id IS NULL

-- Check: Text cleanliness (selected columns should not have leading/trailing spaces; NULL-safe)
-- Expectation: No Results
SELECT 
	customer_id
FROM public.customers
WHERE company_name  IS NOT NULL AND company_name  != TRIM(company_name)
   OR contact_name  IS NOT NULL AND contact_name  != TRIM(contact_name)
   OR contact_title IS NOT NULL AND contact_title != TRIM(contact_title)
   OR address       IS NOT NULL AND address       != TRIM(address)
   OR city          IS NOT NULL AND city          != TRIM(city)
   OR country       IS NOT NULL AND country       != TRIM(country);

-- Profiling: Country distribution (used for standardization / filters)
-- Expectation: Informational
SELECT DISTINCT 
	country, COUNT (*) 
FROM customers 
GROUP BY country 
ORDER BY country;

-- Profiling: postal_code length outliers (not always an error in international datasets)
-- Expectation: Informational
SELECT 
	customer_id,
	postal_code,
	LENGTH(postal_code)
FROM customers
WHERE LENGTH(postal_code) < 3 OR LENGTH(postal_code) > 12

-- Profiling: region completeness (often optional; handled in Silver via COALESCE or kept NULL)
-- Expectation: Informational
SELECT 
    COUNT(*) FILTER (WHERE region IS NULL) as count_nulls,
    COUNT(*) FILTER (WHERE region = '') as count_empty_strings
FROM customers;

-- ======================================================================
-- employee_territories
-- ======================================================================

-- Check: Composite PK integrity (employee_id + territory_id must be unique)
-- Expectation: No Results
SELECT 
	employee_id, 
	territory_id, COUNT(*)
FROM employee_territories
GROUP BY employee_id, territory_id
HAVING COUNT(*) > 1;

-- ======================================================================
-- employees
-- ======================================================================

-- Check: PK integrity (employee_id must be unique and not NULL)
-- Expectation: No Results
SELECT 
	employee_id,
	COUNT(*)
FROM employees
GROUP BY employee_id
HAVING COUNT(*) > 1 OR employee_id IS NULL

-- Check: Required identity fields (first_name and last_name should not be NULL/empty)
-- Expectation: 0
SELECT 
	COUNT(*) AS bad_employee_name
FROM employees
WHERE first_name IS NULL OR TRIM(first_name) = ''
   OR last_name  IS NULL OR TRIM(last_name)  = '';

-- Check: Date sanity (birth_date and hire_date must be present and plausible)
-- Expectation: No Results
SELECT 
	employee_id,
	first_name,
	last_name,
	birth_date,
	hire_date
FROM employees
WHERE birth_date IS NULL
   OR hire_date  IS NULL
   OR birth_date > hire_date
   OR (birth_date + INTERVAL '18 years') >= hire_date;

-- ======================================================================
-- order_details
-- ======================================================================

-- Check: Composite PK integrity (order_id + product_id must be unique; no NULL keys)
-- Expectation: No Results
SELECT 
	order_id,
	product_id,
	COUNT(*)
FROM order_details
GROUP BY order_id, product_id
HAVING COUNT(*) > 1 
	OR order_id IS NULL
	OR product_id IS NULL

-- Check: Sales-critical numeric sanity (unit_price>0, quantity>0, discount>=0; no NULLs)
-- Expectation: No Results
SELECT 
	order_id, 
	product_id, 
	unit_price, 
	quantity, 
	discount
FROM public.order_details
WHERE unit_price IS NULL OR unit_price <= 0
   OR quantity   IS NULL OR quantity   <= 0
   OR discount   IS NULL OR discount   < 0;

-- Profiling: Discount range (determine whether discount is 0–1 or 0–100)
-- Expectation: Informational
SELECT 
	MIN(discount) AS discount_min, 
	MAX(discount) AS discount_max
FROM order_details;

-- ======================================================================
-- orders
-- ======================================================================

-- Check: PK integrity (order_id must be unique and not NULL)
-- Expectation: No Results
SELECT 
	order_id,
	COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1 OR order_id IS NULL

-- Check: Text cleanliness (shipping fields should not have leading/trailing spaces; NULL-safe)
-- Expectation: No Results
SELECT 
	order_id, 
	ship_name
FROM orders
WHERE ship_name 	IS NOT NULL AND ship_name 		!= TRIM(ship_name) 
   OR ship_address 	IS NOT NULL AND ship_address 	!= TRIM(ship_address)
   OR ship_city 	IS NOT NULL AND ship_city 		!= TRIM(ship_city)
   OR ship_country	IS NOT NULL AND ship_country 	!= TRIM(ship_country)

-- Check: Numeric sanity (freight must be positive and not NULL - project rule)
-- Expectation: No Results
SELECT
	freight
FROM orders
WHERE freight <= 0 
	OR freight IS NULL

-- Check: Date sanity (order_date must exist; shipped_date must be after order_date per current rule)
-- Expectation: No Results
SELECT
	order_id,
	order_date,
	shipped_date
FROM orders
WHERE order_date IS NULL OR order_date >= shipped_date

-- ======================================================================
-- products
-- ======================================================================

-- Check: PK integrity (product_id must be unique and not NULL)
-- Expectation: No Results
SELECT
	product_id,
	COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1 OR product_id IS NULL

/*
Check for misleading informations
Business Rule (assumption to verify):
Discontinued products should typically not have a positive reorder_level.
Purpose: list discontinued products that still have reorder_level > 0 for review.
Expectation: Ideally 0 rows; if not, confirm whether this is intended or needs cleanup.
*/

-- Check: Review list (discontinued=1 AND reorder_level>0)
-- Expectation: Ideally 0 rows (review if not)
SELECT
  product_id,
  product_name
FROM products
WHERE discontinued = 1 AND reorder_level > 0;

-- Check: Pricing sanity (unit_price must not be NULL or negative; grouped output lists affected products)
-- Expectation: No Results
SELECT
	product_id,
	product_name,
	COUNT(*) AS invalid_unit_price
FROM products
WHERE unit_price IS NULL 
	OR unit_price < 0
GROUP BY product_id

-- Check: Inventory sanity (no negative stock/order/reorder values)
-- Expectation: No Results
SELECT 
	product_id,
	units_in_stock,
	units_on_order,
	reorder_level
FROM products
WHERE units_in_stock IS NOT NULL AND units_in_stock < 0
   OR units_on_order IS NOT NULL AND units_on_order < 0
   OR reorder_level  IS NOT NULL AND reorder_level  < 0

-- ======================================================================
-- region
-- ======================================================================

-- Check: PK integrity (region_id must be unique and not NULL)
-- Expectation: No Results
SELECT 
	region_id,
	COUNT(*)
FROM region
GROUP BY region_id
HAVING COUNT(*) > 1 OR region_id IS NULL

-- Check: Required field (region_description should not be NULL/empty)
-- Expectation: No Results
SELECT
	region_description
FROM region
WHERE region_description IS NULL 
	OR TRIM(region_description) = '' 

-- ======================================================================
-- shippers
-- ======================================================================

-- Check: PK integrity (shipper_id must be unique and not NULL)
-- Expectation: No Results
SELECT 
	shipper_id,
	COUNT(*)
FROM shippers
GROUP BY shipper_id
HAVING COUNT(*) > 1 OR shipper_id IS NULL

-- Check: Required field (company_name should not be NULL/empty)
-- Expectation: No Results
SELECT 
	shipper_id,
	company_name
FROM shippers
WHERE company_name IS NULL OR TRIM(company_name) = '';

-- ======================================================================
-- suppliers
-- ======================================================================

-- Check: PK integrity (supplier_id must be unique and not NULL)
-- Expectation: No Results
SELECT 
	supplier_id,
	COUNT(*)
FROM suppliers
GROUP BY supplier_id
HAVING COUNT(*) > 1 OR supplier_id IS NULL

-- Check: Required field (company_name should not be NULL/empty)
-- Expectation: No Results
SELECT 
	supplier_id,
	company_name
FROM suppliers
WHERE company_name IS NULL OR TRIM(company_name) = ''

-- Check: Analytics field (country should not be NULL/empty for consistent grouping)
-- Expectation: No Results
SELECT 
	supplier_id,
	company_name
FROM suppliers
WHERE country IS NULL OR TRIM(country) = ''

-- ======================================================================
-- territories
-- ======================================================================

-- Check: PK integrity (territory_id must be unique and not NULL)
-- Expectation: No Results
SELECT 
	territory_id,
	COUNT(*)
FROM territories
GROUP BY territory_id
HAVING COUNT(*) > 1 OR territory_id IS NULL

-- Check: Required field (territory_description should not be NULL/empty)
-- Expectation: No Results
SELECT
	territory_description
FROM territories
WHERE territory_description IS NULL 
	OR TRIM(territory_description) = ''

-- ======================================================================
-- us_states
-- ======================================================================

-- Check: PK integrity (state_id must be unique and not NULL)
-- Expectation: No Results
SELECT
	state_id,
	COUNT(*)
FROM us_states
GROUP BY state_id
HAVING COUNT(*) > 1 OR state_id IS NULL

-- Check: Required field (state_name should not be NULL/empty)
-- Expectation: No Results
SELECT 
	state_id
FROM us_states
WHERE state_name IS NULL 
	OR TRIM(state_name) = ''

-- Check: Required field (state_abbr should not be NULL/empty)
-- Expectation: No Results
SELECT 
	state_id
FROM us_states
WHERE state_abbr IS NULL 
	OR TRIM(state_abbr) = ''

-- Check: Format rule (state_abbr should be exactly 2 characters after TRIM)
-- Expectation: No Results
SELECT 
	state_id, 
	state_abbr
FROM us_states
WHERE state_abbr IS NOT NULL 
	AND LENGTH(TRIM(state_abbr)) != 2;

-- Check: Uniqueness rule (state_abbr should not repeat)
-- Expectation: No Results
SELECT
	TRIM(state_abbr) AS state_abbr,
	COUNT(*)
FROM us_states
WHERE state_abbr IS NOT NULL
GROUP BY TRIM(state_abbr)
HAVING COUNT(*) > 1
