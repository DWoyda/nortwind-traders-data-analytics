/* =====================================================================================
DDL Script: Create Silver Tables (Northwind)
Purpose:
    Create empty tables in the "silver" schema with column names + data types matching
    the current "public" Northwind tables, plus a technical load timestamp column
    (dwh_create_date). These tables will be populated later using INSERT.
===================================================================================== */

CREATE SCHEMA IF NOT EXISTS silver;

-- ==========================================================
-- categories
-- ==========================================================
DROP TABLE IF EXISTS silver.categories CASCADE;

CREATE TABLE IF NOT EXISTS silver.categories (
	category_id       SMALLINT NOT NULL,
	category_name     VARCHAR NOT NULL,
	description       TEXT,
	picture           BYTEA,
	dwh_create_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- customer_customer_demo
-- ==========================================================
DROP TABLE IF EXISTS silver.customer_customer_demo CASCADE;

CREATE TABLE IF NOT EXISTS silver.customer_customer_demo (
	customer_id       CHAR(5) NOT NULL,
	customer_type_id  CHAR(10) NOT NULL,
	dwh_create_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- customer_demographics
-- ==========================================================
DROP TABLE IF EXISTS silver.customer_demographics CASCADE;

CREATE TABLE IF NOT EXISTS silver.customer_demographics (
	customer_type_id  CHAR(10) NOT NULL,
	customer_desc     TEXT,
	dwh_create_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- customers
-- ==========================================================
DROP TABLE IF EXISTS silver.customers CASCADE;

CREATE TABLE IF NOT EXISTS silver.customers (
	customer_id     CHAR(5) NOT NULL,
	company_name    VARCHAR NOT NULL,
	contact_name    VARCHAR,
	contact_title   VARCHAR,
	address         VARCHAR,
	city            VARCHAR,
	region          VARCHAR,
	postal_code     VARCHAR,
	country         VARCHAR,
	phone           VARCHAR,
	fax             VARCHAR,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- employee_territories
-- ==========================================================
DROP TABLE IF EXISTS silver.employee_territories CASCADE;

CREATE TABLE IF NOT EXISTS silver.employee_territories (
	employee_id     SMALLINT NOT NULL,
	territory_id    VARCHAR NOT NULL,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- employees
-- ==========================================================
DROP TABLE IF EXISTS silver.employees CASCADE;

CREATE TABLE IF NOT EXISTS silver.employees (
	employee_id       SMALLINT NOT NULL,
	last_name         VARCHAR NOT NULL,
	first_name        VARCHAR NOT NULL,
	title             VARCHAR,
	title_of_courtesy VARCHAR,
	birth_date        DATE,
	hire_date         DATE,
	address           VARCHAR,
	city              VARCHAR,
	region            VARCHAR,
	postal_code       VARCHAR,
	country           VARCHAR,
	home_phone        VARCHAR,
	extension         VARCHAR,
	photo             BYTEA,
	notes             TEXT,
	reports_to        SMALLINT,
	photo_path        VARCHAR,
	dwh_create_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- order_details
-- ==========================================================
DROP TABLE IF EXISTS silver.order_details CASCADE;

CREATE TABLE IF NOT EXISTS silver.order_details (
	order_id        SMALLINT NOT NULL,
	product_id      SMALLINT NOT NULL,
	unit_price      REAL NOT NULL,
	quantity        SMALLINT NOT NULL,
	discount        REAL NOT NULL,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- orders
-- ==========================================================
DROP TABLE IF EXISTS silver.orders CASCADE;

CREATE TABLE IF NOT EXISTS silver.orders (
	order_id         SMALLINT NOT NULL,
	customer_id      CHAR(5),
	employee_id      SMALLINT,
	order_date       DATE,
	required_date    DATE,
	shipped_date     DATE,
	ship_via         SMALLINT,
	freight          REAL,
	ship_name        VARCHAR,
	ship_address     VARCHAR,
	ship_city        VARCHAR,
	ship_region      VARCHAR,
	ship_postal_code VARCHAR,
	ship_country     VARCHAR,
	dwh_create_date  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- products
-- ==========================================================
DROP TABLE IF EXISTS silver.products CASCADE;

CREATE TABLE IF NOT EXISTS silver.products (
	product_id        SMALLINT NOT NULL,
	product_name      VARCHAR NOT NULL,
	supplier_id       SMALLINT,
	category_id       SMALLINT,
	quantity_per_unit VARCHAR,
	unit_price        REAL,
	units_in_stock    SMALLINT,
	units_on_order    SMALLINT,
	reorder_level     SMALLINT,
	discontinued      INTEGER NOT NULL,
	dwh_create_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- region
-- ==========================================================
DROP TABLE IF EXISTS silver.region CASCADE;

CREATE TABLE IF NOT EXISTS silver.region (
	region_id          SMALLINT NOT NULL,
	region_description CHAR(50) NOT NULL,
	dwh_create_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- shippers
-- ==========================================================
DROP TABLE IF EXISTS silver.shippers CASCADE;

CREATE TABLE IF NOT EXISTS silver.shippers (
	shipper_id      SMALLINT NOT NULL,
	company_name    VARCHAR NOT NULL,
	phone           VARCHAR,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- suppliers
-- ==========================================================
DROP TABLE IF EXISTS silver.suppliers CASCADE;

CREATE TABLE IF NOT EXISTS silver.suppliers (
	supplier_id     SMALLINT NOT NULL,
	company_name    VARCHAR NOT NULL,
	contact_name    VARCHAR,
	contact_title   VARCHAR,
	address         VARCHAR,
	city            VARCHAR,
	region          VARCHAR,
	postal_code     VARCHAR,
	country         VARCHAR,
	phone           VARCHAR,
	fax             VARCHAR,
	homepage        TEXT,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- territories
-- ==========================================================
DROP TABLE IF EXISTS silver.territories CASCADE;

CREATE TABLE IF NOT EXISTS silver.territories (
	territory_id          VARCHAR NOT NULL,
	territory_description CHAR(50) NOT NULL,
	region_id             SMALLINT NOT NULL,
	dwh_create_date       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================================
-- us_states
-- ==========================================================
DROP TABLE IF EXISTS silver.us_states CASCADE;

CREATE TABLE IF NOT EXISTS silver.us_states (
	state_id        SMALLINT NOT NULL,
	state_name      VARCHAR,
	state_abbr      VARCHAR,
	state_region    VARCHAR,
	dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
