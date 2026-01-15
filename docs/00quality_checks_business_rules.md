# Quality Checks — Business Rules (Northwind / public RAW)

## Purpose
These business rules define what the project considers a **data quality issue** before building the Silver layer.
Rules are grouped into:
- **Hard rules**: must pass (Expectation: 0 issues / no rows returned)
- **Profiling rules**: informational outputs used to decide Silver transformations

---

## 1) Hard rules (must pass)

### 1.1 Primary Key integrity
A primary key must be:
- **NOT NULL**
- **unique** (no duplicates)

Tables checked:
- `categories(category_id)`
- `customers(customer_id)`
- `employees(employee_id)`
- `orders(order_id)`
- `products(product_id)`
- `region(region_id)`
- `shippers(shipper_id)`
- `suppliers(supplier_id)`
- `territories(territory_id)`
- `us_states(state_id)`

Composite keys checked:
- `employee_territories(employee_id, territory_id)` must be unique
- `order_details(order_id, product_id)` must be unique and not contain NULLs

---

### 1.2 Required descriptive fields
These fields are required for stable reporting and dimension usability:
- `categories.category_name` must not be NULL/empty
- `employees.first_name`, `employees.last_name` must not be NULL/empty
- `region.region_description` must not be NULL/empty
- `shippers.company_name` must not be NULL/empty
- `suppliers.company_name` must not be NULL/empty
- `territories.territory_description` must not be NULL/empty
- `us_states.state_name`, `us_states.state_abbr` must not be NULL/empty

---

### 1.3 Sales-critical numeric sanity (order line level)
To compute sales correctly at the order-line level:
- `order_details.unit_price` must be NOT NULL and `> 0`
- `order_details.quantity` must be NOT NULL and `> 0`
- `order_details.discount` must be NOT NULL and `>= 0`

---

### 1.4 Orders numeric sanity
Project rule:
- `orders.freight` must be NOT NULL and `> 0`

Note: In real datasets, `freight = 0` can be valid (free shipping).  
If such cases exist, the rule should be adjusted and documented.

---

### 1.5 Orders date sanity
Project rule:
- `orders.order_date` must be NOT NULL
- `orders.shipped_date` must be later than `orders.order_date` (based on the current check)

Note: In real datasets, `shipped_date` can be NULL (not shipped yet).  
If your dataset contains NULL shipped dates, update the rule to validate only when `shipped_date IS NOT NULL`.

---

### 1.6 Product pricing and inventory sanity
- `products.unit_price` must be NOT NULL and not negative
- `products.units_in_stock`, `products.units_on_order`, `products.reorder_level` must not be negative

---

### 1.7 US states formatting rules
- `us_states.state_abbr` must be exactly 2 characters after trimming
- `us_states.state_abbr` must be unique

---

## 2) Soft rule (review list)
### 2.1 Discontinued vs reorder level (products)
The script lists rows where:
- `discontinued = 1 AND reorder_level > 0`

This is not automatically wrong. It is a **review list** that requires a business decision:
- either keep as-is and document it,
- or enforce a cleanup rule in Silver.

---

## 3) Profiling rules (informational)
These outputs are used to understand the dataset and decide Silver transformations:
- `customers.country` distribution
- `customers.postal_code` length outliers
- `customers.region` NULL/empty counts
- `order_details.discount` min/max to determine discount scale (0–1 vs 0–100)
