/* 
Purpose:
    Full refresh load of the SILVER layer tables from PUBLIC (raw) Northwind tables.
    The script truncates each target table and reloads it, applying lightweight standardization
    (COALESCE + simple CASE) to make the data BI-ready.
*/

TRUNCATE TABLE silver.categories;

INSERT INTO silver.categories (
	category_id, 
	category_name, 
	description, 
	picture
)
SELECT 
	category_id, 
	category_name, 
	description, 
	picture
FROM categories;

TRUNCATE TABLE silver.customer_customer_demo;

INSERT INTO silver.customer_customer_demo(
	customer_id, 
	customer_type_id
)
SELECT
	customer_id, 
	customer_type_id
FROM customer_customer_demo;

TRUNCATE TABLE silver.customer_demographics;

INSERT INTO silver.customer_demographics (
	customer_type_id, 
	customer_desc
)
SELECT 
	customer_type_id, 
	customer_desc
FROM customer_demographics;

TRUNCATE TABLE silver.customers;

INSERT INTO silver.customers (
	customer_id, 
	company_name, 
	contact_name, 
	contact_title, 
	address, 
	city, 
	region, 
	postal_code, 
	country, 
	phone, 
	fax
)
SELECT
	customer_id, 
	company_name, 
	contact_name, 
	contact_title, 
	address, 
	city, 
	COALESCE(region, 'N/A') AS region,   -- standardize missing region for BI filters
	postal_code, 
	country, 
	phone, 
	COALESCE(fax, 'N/A') AS fax          -- standardize missing fax for BI exports
FROM customers;

TRUNCATE TABLE silver.employee_territories;

INSERT INTO silver.employee_territories (
	employee_id, 
	territory_id
)
SELECT 
	employee_id, 
	territory_id
FROM employee_territories;

TRUNCATE TABLE silver.employees;

INSERT INTO silver.employees (
	employee_id, 
	last_name, 
	first_name, 
	title, 
	title_of_courtesy, 
	birth_date, 
	hire_date, 
	address, 
	city, 
	region, 
	postal_code, 
	country, 
	home_phone, 
	extension, 
	photo, 
	notes, 
	reports_to, 
	photo_path
)
SELECT
	employee_id, 
	last_name, 
	first_name, 
	title, 
	title_of_courtesy, 
	birth_date, 
	hire_date, 
	address, 
	city, 
	COALESCE(region, 'N/A') AS region,   -- align missing region with customers logic
	postal_code, 
	country, 
	home_phone, 
	extension, 
	photo, 
	notes, 
	COALESCE(reports_to, 0) AS reports_to, -- standardize missing manager reference
	photo_path
FROM employees;

TRUNCATE TABLE silver.order_details;

INSERT INTO silver.order_details (
	order_id, 
	product_id, 
	unit_price, 
	quantity, 
	discount
)
SELECT 
	order_id, 
	product_id, 
	unit_price, 
	quantity, 
	discount
FROM order_details;

TRUNCATE TABLE silver.orders;

INSERT INTO silver.orders (
	order_id, 
	customer_id, 
	employee_id, 
	order_date, 
	required_date, 
	shipped_date, 
	ship_via, 
	freight, 
	ship_name, 
	ship_address, 
	ship_city, 
	ship_region, 
	ship_postal_code, 
	ship_country
)
SELECT 
	order_id, 
	customer_id, 
	employee_id, 
	order_date, 
	required_date, 
	shipped_date, 
	ship_via, 
	freight, 
	ship_name, 
	ship_address, 
	ship_city, 
	COALESCE(ship_region, 'N/A') AS ship_region, -- keep shipping region non-null for slicing
	ship_postal_code, 
	ship_country
FROM orders;

TRUNCATE TABLE silver.products;

INSERT INTO silver.products (
	product_id, 
	product_name, 
	supplier_id, 
	category_id, 
	quantity_per_unit, 
	unit_price, 
	units_in_stock, 
	units_on_order, 
	reorder_level, 
	discontinued
)
SELECT
	product_id, 
	product_name, 
	supplier_id, 
	category_id, 
	quantity_per_unit, 
	unit_price, 
	units_in_stock, 
	units_on_order, 
	CASE 
		WHEN discontinued = 1 THEN 0      -- normalize reorder_level for discontinued products
		ELSE reorder_level 
	END AS reorder_level,
	discontinued
FROM products;

TRUNCATE TABLE silver.region;

INSERT INTO silver.region (
	region_id, 
	region_description
)
SELECT 
	region_id, 
	region_description
FROM region;

TRUNCATE TABLE silver.shippers;

INSERT INTO silver.shippers (
	shipper_id, 
	company_name, 
	phone
)
SELECT
	shipper_id, 
	company_name, 
	phone
FROM shippers;

TRUNCATE TABLE silver.suppliers;

INSERT INTO silver.suppliers (
	supplier_id, 
	company_name, 
	contact_name, 
	contact_title, 
	address, 
	city, 
	region, 
	postal_code, 
	country, 
	phone, 
	fax, 
	homepage
)
SELECT 
	supplier_id, 
	company_name, 
	contact_name, 
	contact_title, 
	address, 
	city, 
	COALESCE(region, 'N/A') AS region,   -- standardize missing region
	postal_code, 
	country, 
	phone, 
	COALESCE(fax, 'N/A') AS fax,         -- standardize missing fax
	COALESCE(homepage, 'N/A') AS homepage -- standardize missing homepage
FROM suppliers;

TRUNCATE TABLE silver.territories;

INSERT INTO silver.territories (
	territory_id, 
	territory_description, 
	region_id
)
SELECT 
	territory_id, 
	territory_description, 
	region_id
FROM territories;

TRUNCATE TABLE silver.us_states;

INSERT INTO silver.us_states (
	state_id, 
	state_name, 
	state_abbr, 
	state_region
)
SELECT
	state_id, 
	state_name, 
	state_abbr, 
	state_region
FROM us_states;
