
# 📊 SQL Sales Analysis Project

This repository contains a comprehensive SQL-based analysis of sales, products, and customers. The goal is to uncover trends, performance metrics, and business insights from a retail dataset using advanced SQL techniques.

---

## 📂 Data Sources

- `gold.fact_sales`: Transactional sales data  
- `gold.dim_products`: Product master table  
- `gold.dim_customers`: Customer master table  

---

## 🔍 Key Analyses & Insights

### 1. **Yearly & Monthly Sales Analysis**
- Identified 2013 as the highest-performing year.
- December recorded peak sales, indicating seasonal demand.

### 2. **Cumulative Sales Trend**
- Used CTE and window functions to visualize running total sales.
- Helps in identifying long-term growth patterns.

### 3. **Year-on-Year Performance**
- Implemented `LAG()` to compare current vs previous year sales.
- Useful for executive summaries and annual reviews.

### 4. **Product-Level Trend & Classification**
- Compared yearly sales against average performance.
- Classified products as “Above Avg”, “Below Avg”, or “Same”.
- Trend direction marked as “Increased”, “Decreased”, or “No change”.

### 5. **Category Contribution**
- Computed each category’s share in total sales.
- Helps in identifying high-performing product lines.

### 6. **Cost Segmentation**
- Segmented products by cost into brackets:
  - Below 100
  - 100–500
  - 500–1000
  - Above 1000

### 7. **Customer Segmentation**
- Segmented customers as:
  - `VIP`: >12 months active & spent >₹5000
  - `Regular`: >12 months & spent ≤₹5000
  - `New`: <12 months
- Built foundation for loyalty strategy and targeting.

---

## 🛠️ Reports Created

### 📋 `golden_report_customers` (SQL View)
- Age segmentation
- Order metrics
- Recency and frequency
- Lifetime sales and customer span

### 📦 `golden_report_product` (SQL View)
- Product lifecycle
- Average revenue/order/month
- Segmentation: `High performance`, `Mid Range`, `Low Performance`

---

## 💡 Skills & Concepts Applied

- **CTEs and Window Functions**
- **Data Aggregation & Joins**
- **Trend Analysis**
- **Segmentation Logic**
- **Performance Classification**
- **SQL View Creation for Reporting**

---

## 📎 How to Use

1. Connect to your data warehouse (ensure `gold` schema exists).
2. Run each SQL section incrementally to explore and validate.
3. Deploy views `golden_report_customers` and `golden_report_product` for dashboard/reporting tools.

---

## 📘 Learning Outcomes

- Ability to extract actionable insights from raw data.
- Proficiency in writing analytical SQL queries.
- Experience building reporting views for business consumption.

---
