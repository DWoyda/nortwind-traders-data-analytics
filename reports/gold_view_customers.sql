/*
===============================================================================
Customer Dimension — gold.dim_customers
===============================================================================
Purpose:
    - Expose customer master data for slicing and filtering sales.

Highlights:
    - Key: customer_id
    - Attributes: company/contact details and location fields
===============================================================================
*/
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
