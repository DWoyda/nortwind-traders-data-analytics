/*
=============================================================
gold_views.sql (PostgreSQL)
=============================================================
Purpose:
    Create a BI-ready GOLD layer (views) on top of the SILVER layer for a Sales Performance dashboard.

    The GOLD layer is the presentation/semantic layer used directly by BI tools (e.g., Power BI).
    It contains:
        - gold.fact_sales   (line-level sales facts)
        - gold.dim_customers
        - gold.dim_products
        - gold.dim_employees
        - gold.dim_shippers
        - gold.dim_date     (calendar dimension derived from orders)

What this script does:
    1. Ensures the "gold" schema exists.
    2. Drops GOLD views if they already exist (to avoid conflicts).
    3. Recreates the views in a consistent, BI-friendly form.

Usage:
    Run this script after SILVER is loaded/refreshed.
    BI tools should connect to these GOLD views.

=============================================================
*/

-- Create schema for the presentation layer (GOLD).

CREATE SCHEMA IF NOT EXISTS gold;

-- =============================================================================
-- Create Fact View: gold.fact_sales
-- =============================================================================

DROP VIEW IF EXISTS gold.fact_sales CASCADE;

CREATE VIEW gold.fact_sales AS
(
SELECT
    od.order_id,
    od.product_id,
    o.customer_id,
    o.employee_id,
    o.ship_via            AS shipper_id,
    -- dates
    o.order_date,
    o.required_date,
    o.shipped_date,
    -- order attributes
    o.ship_name,
    o.ship_city,
    o.ship_country,
    o.ship_region,
    -- measures
    od.unit_price,
    od.quantity,
    od.discount,
	ROUND((od.unit_price * od.quantity)::numeric,2) AS sales,
	ROUND((od.quantity * od.unit_price * (1 - od.discount))::numeric,2) AS sales_discount,
	ROUND((od.unit_price * od.quantity * od.discount)::numeric, 2) AS discount_amount
FROM silver.order_details AS od
LEFT JOIN silver.orders AS o
	ON od.order_id = o.order_id
);

-- =============================================================================
-- Create Dimension View: gold.dim_customers
-- =============================================================================
DROP VIEW IF EXISTS gold.dim_customers CASCADE;

CREATE VIEW gold.dim_customers AS
SELECT
    c.customer_id,
    c.company_name,
    c.contact_name,
    c.contact_title,
    c.address,
    c.city,
    c.region,
    c.postal_code,
    c.country,
    c.phone,
    c.fax
FROM silver.customers AS c;

-- =============================================================================
-- Create Dimension View: gold.dim_products
-- =============================================================================
DROP VIEW IF EXISTS gold.dim_products CASCADE;

CREATE VIEW gold.dim_products AS
(
SELECT
    p.product_id,
    p.product_name,

    -- Category attributes (denormalized into the product dimension)
    p.category_id,
    c.category_name,

    -- Supplier attributes (denormalized into the product dimension)
    p.supplier_id,
    s.company_name AS supplier_name,
    s.city         AS supplier_city,
    s.country      AS supplier_country,

    -- Product attributes
    p.quantity_per_unit,
    p.unit_price   AS list_unit_price,  -- catalog/list price; NOT used for sales KPI
    p.units_in_stock,
    p.units_on_order,
    p.reorder_level,
    p.discontinued
FROM silver.products AS p
LEFT JOIN silver.suppliers AS s
    ON p.supplier_id = s.supplier_id
LEFT JOIN silver.categories AS c
    ON p.category_id = c.category_id
);

-- =============================================================================
-- Create Dimension View: gold.dim_employees
-- =============================================================================
DROP VIEW IF EXISTS gold.dim_employees CASCADE;

CREATE VIEW gold.dim_employees AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.title,
    e.title_of_courtesy,
    e.birth_date,
    e.hire_date,
    e.address,
    e.city,
    e.region,
    e.postal_code,
    e.country,
    e.home_phone,
    e.extension,
    e.reports_to,
    e.photo_path
FROM silver.employees AS e;

-- =============================================================================
-- Create Dimension View: gold.dim_shippers
-- =============================================================================
DROP VIEW IF EXISTS gold.dim_shippers CASCADE;

CREATE VIEW gold.dim_shippers AS
SELECT
    sh.shipper_id,
    sh.company_name,
    sh.phone
FROM silver.shippers AS sh;

-- =============================================================================
-- Create Dimension View: gold.dim_date
-- =============================================================================
DROP VIEW IF EXISTS gold.dim_date CASCADE;

CREATE VIEW gold.dim_date AS
WITH date_range AS (
    -- Calendar bounds based on available order dates (prevents generating unnecessary years)
    SELECT
        MIN(order_date)::date AS min_date,
        MAX(order_date)::date AS max_date
    FROM silver.orders
    WHERE order_date IS NOT NULL
)
SELECT
    d::date AS date,
    EXTRACT(YEAR    FROM d)::int AS year,
    EXTRACT(QUARTER FROM d)::int AS quarter,
    EXTRACT(MONTH   FROM d)::int AS month,
    TO_CHAR(d, 'Mon')            AS month_name,
    EXTRACT(WEEK    FROM d)::int AS week_of_year,
    EXTRACT(DAY     FROM d)::int AS day,
    TO_CHAR(d, 'Dy')             AS day_name,
    (EXTRACT(ISODOW FROM d) IN (6, 7)) AS is_weekend
FROM date_range AS r
CROSS JOIN generate_series(r.min_date, r.max_date, interval '1 day') AS d;
