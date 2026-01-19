# Sales Performance Dashboard - Final Conclusions

## Dashboard objective
The dashboard is designed to monitor sales performance over time and identify key sales drivers (countries, products, employees, categories) as well as the impact of discounts on revenue. In addition, it includes an operational logistics view (shipping time, on-time delivery) to assess whether order fulfillment supports sales performance.

---

## Key takeaways
- Sales are **geographically concentrated**: the highest share comes from the **USA and Germany**, followed by **Austria and Brazil** (Top 5 countries generate a significant portion of total sales).
- Sales are **product-concentrated**: a small number of products accounts for a substantial share of revenue (Top 5 products clearly dominate the rest).
- The sales trend over time shows **clear seasonal/monthly fluctuations** and periods of significant change in sales levels (months should be treated as the primary monitoring unit).
- Discounts have a **measurable financial impact**: the share of discounts in “pre-discount” sales value is **6.5%** (Discount Rate).
- Discount intensity **varies across categories**: some categories show a clearly higher discount share than others (risk of “burning margin” without a proportional volume increase).
- Logistics are **stable and timely**: the “Ship on Time” rate is approximately **96%**, and the average shipping time is around **8 days** (for the analyzed period).

---

# Business insights and potential decisions

## 1) Sales concentration (countries / products / employees)
Sales are unevenly distributed across markets and products. Performance is largely driven by top-selling countries and flagship products, indicating strong revenue concentration in key segments.

**Possible decisions**
- Prioritize actions in the **Top 2–3 countries** (allocation of sales/marketing budget, service capacity, availability).
- Product portfolio management: maintain availability and visibility of **Top products** and evaluate whether the “long tail” of products is profitable.

---

## 2) Discounts have a real revenue cost (6.5% of pre-discount value)
- **Discount Rate** represents the portion of sales value the company gives up through discounts (i.e. the percentage of list value reduced through price cuts).

**Possible decisions**
- Define a discount policy: discount caps or thresholds by category, customer, or country.
- Verify whether discounts actually drive volume: if a category has a high Discount Rate without growth in volume or sales share, discounts may be inefficient.
- Apply segmentation: maintain discounts where they support growth (e.g. strategic products) and limit them where they generate cost without effect.

---

## 3) Categories differ in discount profiles
- In some categories, discounts are an intentional part of the strategy (e.g. aggressively promoted groups), while in others sales occur with a lower “discount cost”.

**Possible decisions**
- Define “high-discount” categories as areas requiring closer control (competition, seasonality, inventory clearance).
- Compare categories in terms of **discount level vs. sales performance** and decide whether discounts should be reduced or reallocated.

---

## 4) Logistics support sales (on-time rate ~96%)
- High on-time delivery and predictable shipping times reduce complaint risk and support customer retention.

**Possible decisions**
- Maintain SLA standards and monitor **Ship on Time** as a core operational KPI supporting sales.
- If a carrier underperforms (delivery time or punctuality), consider adjusting volume allocation or contract conditions.

---

# Page-level conclusions (business view)

## Page 1 — Main (Executive overview)
- Provides a fast snapshot of total sales, volume, number of orders/customers, and key contributors (Top countries, products, employees).
- Answers key questions: *How much did we sell? Who and where generates results? Is performance improving over time?*

## Page 2 — Sales (Drivers: categories, customers, discounts)
- Shows sales structure by category and customer and the impact of discounts (Discount Rate) with variation across categories.
- Supports decisions on discount policy and sales prioritization (identifying where sales are “expensive” due to discounts).

## Page 3 — Ship (Operational: on-time delivery and shipping time)
- Provides operational context: fulfillment timeliness, stability, and shipment profiles by country and carrier.
- Supports carrier and SLA decisions without mixing operational KPIs with sales KPIs.

---

## Next steps / deeper analysis
The dashboard is complete as a portfolio project, but some questions are better addressed using Python or SQL-based EDA rather than Power BI alone. Potential follow-up analyses include:

1) **What drives the mid-year sales decline?**  
   (Order count, average order value, or product/category mix?)

2) **Why do the USA and Germany dominate sales?**  
   (Higher customer/order volume vs. higher basket size; role of specific categories?)

3) **What explains the dominance of the top product (e.g. Côte de Blaye)?**  
   (Volume, price level, or concentration among a few customers or countries?)

4) **Are discounts effective?**  
   (Does a higher *discount rate* correlate with higher volume or order count, or mainly reduce net revenue?)

---

## Final summary
- **The Sales Dashboard objective has been achieved**: it provides a clear KPI overview and key sales drivers, with the Ship page extending the analysis into operations.
- The data show **strong sales concentration** (geographies and top products) and a **moderate discount level (~6.5%)** with meaningful variation across categories.
- The highest business value at this stage lies in **market and category prioritization**, **discount control**, **salesforce performance evaluation**, and **on-time delivery monitoring**.
- The most important improvement before a production-ready version is ensuring **consistent Gross/Net/Discount definitions** and a **proper time axis with a correctly linked `dim_date` table**.
