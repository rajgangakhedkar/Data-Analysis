-- 📊 ANALYZING SALES OVER TIME

-- Get all raw sales data
select *
from [gold.fact_sales]

-- Get distinct years from order dates
select distinct(Year(cast(order_date as Date)))
from [gold.fact_sales]

-- 🔍 Year-wise analysis of total sales, customer count, and quantity
select Year(cast(order_date as Date)) as order_year, 
       sum(sales_amount) as total_sales, 
       count(customer_key) as total_customer,
       sum(quantity) as total_quantity
from [gold.fact_sales]
where order_date is not null
group by Year(cast(order_date as Date))
order by Year(cast(order_date as Date))

-- 🧠 LEARNED: Yearly trends in sales and customer engagement. Observed 2013 as highest-performing year, showing correlation between customers and sales.

-- 📅 Monthly sales trend analysis to capture seasonality
select Month(cast(order_date as Date)) as order_year, 
       sum(sales_amount) as total_sales, 
       count(customer_key) as total_customer,
       sum(quantity) as total_quantity
from [gold.fact_sales]
where order_date is not null
group by Month(cast(order_date as Date))
order by Month(cast(order_date as Date))

-- 🧠 LEARNED: Highest sales in December indicating seasonal buying behavior, likely due to holidays. Seasonality is a key factor.

-- 📈 Cumulative monthly sales over time using CTE + window function
with cte as(
    select DATETRUNC(MONTH,order_date) as order_d,
           sum(sales_amount) as total_sale
    from [gold.fact_sales]
    where DATETRUNC(MONTH,order_date) is not null
    group by DATETRUNC(MONTH,order_date)
)
select order_d, 
       total_sale,
       SUM(total_sale) over (order by order_d) as running_total
from cte

-- 🧠 LEARNED: Applied cumulative sum logic to visualize running sales growth. Helpful for trend analysis.

-- 📊 PERFORMANCE ANALYSIS: Comparing year-on-year sales
with previous_year as (
    select Year(cast(order_date as Date)) as order_year,
           LAG(SUM(sales_amount),1) over(order by Year(cast(order_date as Date))) as previous_yr_sale,
           SUM(sales_amount) as current_yr_sale 
    from [gold.fact_sales]
    where Year(cast(order_date as Date)) is not null
    group by Year(cast(order_date as Date))
)
select order_year, 
       current_yr_sale, 
       previous_yr_sale, 
       (current_yr_sale - previous_yr_sale) as diff
from previous_year

-- 🧠 LEARNED: Used LAG function to calculate performance change compared to previous year. Good for executive summaries.

-- 📦 PRODUCT-WISE YEARLY SALES VS AVERAGE AND TREND

with yearly_sale as(
    select Year(cast(gs.order_date as Date)) as order_year,
           gp.product_name as p_name,
           Sum(gs.sales_amount) as sum_sales
    from [gold.fact_sales] as gs 
    left join [gold.dim_products] as gp on gs.product_key = gp.product_key
    where Year(cast(gs.order_date as Date)) is not null
    group by Year(cast(gs.order_date as Date)), gp.product_name
)

select order_year, p_name, sum_sales,
       AVG(sum_sales) over (partition by p_name) as avg_sales,
       sum_sales - AVG(sum_sales) over (partition by p_name) as diff_avg,
       -- Classification flag
       case 
           when sum_sales - AVG(sum_sales) over (partition by p_name) > 0 then 'Above avg' 
           when sum_sales - AVG(sum_sales) over (partition by p_name) < 0 then 'Below Avg' 
           else 'Same' 
       end as flag,
       -- Trend over previous year
       LAG(sum_sales, 1) over (partition by p_name order by order_year) as previous_sum_sales,
       sum_sales - LAG(sum_sales, 1) over (partition by p_name order by order_year) as diff_sales,
       case 
           when sum_sales - LAG(sum_sales, 1) over (partition by p_name order by order_year) > 0 then 'Increased' 
           when sum_sales - LAG(sum_sales, 1) over (partition by p_name order by order_year) < 0 then 'Decreased' 
           else 'No change' 
       end as change_in_sale
from yearly_sale

-- 🧠 LEARNED: Compared sales against average and tracked change over time. Used WINDOW functions like AVG and LAG effectively.

-- 🔍 CATEGORY-WISE SALES CONTRIBUTION

with total_cat_sales as(
    select gp.category as cat, 
           sum(gs.sales_amount) as total_sales
    from [gold.fact_sales] as gs 
    left join [gold.dim_products] as gp on gs.product_key = gp.product_key
    group by gp.category
)
select cat,
       total_sales,
       sum(total_sales) over () as overall_sales,
       concat(Round((cast(total_sales as float)/sum(total_sales) over ())*100,2),'%') as percen
from total_cat_sales
order by percen desc

-- 🧠 LEARNED: Identified which product categories contribute most to overall sales using window functions for overall total.

-- 🧾 SEGMENTING PRODUCTS INTO COST BRACKETS

with ran as (
    select product_key, 
           product_name,
           cost,
           Case 
               when cost <100 then 'Below 100'
               when cost between 100 and 500 then '100-500'
               when cost between 500 and 1000 then '500-1000'
               else 'Above 1000' 
           end as cost_range
    from [gold.dim_products]
)
select cost_range, count(*) as total
from ran
group by cost_range
order by total desc

-- 🧠 LEARNED: Performed cost-based segmentation to understand price-point distribution of products.

-- 🧑 CUSTOMER ANALYSIS SETUP

-- Sample joins to explore customer and sales relationships
select *
from [gold.dim_customers]

select gc.customer_key, sales_amount, order_date
from [gold.fact_sales] as gs 
left join [gold.dim_customers] as gc on gs.customer_key = gc.customer_key

-- 🧠 LEARNED: Explored customer-level data, built foundation for advanced segmentation.

-- 🧑 CUSTOMER SEGMENTATION BASED ON ACTIVITY AND SPENDING

with new_dates as (
    select gc.customer_key as ck, 
           sum(sales_amount) as total_spending,
           MIN(order_date) as first_order_date, 
           MAX(order_date) as last_order_date
    from [gold.fact_sales] as gs 
    left join [gold.dim_customers] as gc on gs.customer_key = gc.customer_key
    group by gc.customer_key
),
diff_date as (
    select ck, total_spending, first_order_date, last_order_date,
           DATEDIFF(MONTH, first_order_date, last_order_date) as month_diff
    from new_dates
)
select customer_rank, count(*) as total_cus
from (
    select ck, total_spending, month_diff,
           case 
               when month_diff >= 12 and total_spending > 5000 then 'VIP'
               when month_diff >= 12 and total_spending <= 5000 then 'Regular'
               else 'New' 
           end as customer_rank
    from diff_date
) t
group by customer_rank
order by total_cus desc

-- 🧠 LEARNED: Created customer personas (VIP, Regular, New) based on purchase behavior and engagement time span.

-- 📋 CREATE GOLDEN REPORT FOR CUSTOMER METRICS

create view golden_report_customers as 
with base_query as (
    select gs.order_number, gs.product_key, gs.order_date, gs.sales_amount, gs.quantity,
           gc.customer_key, gc.customer_number,
           CONCAT(gc.first_name,' ', gc.last_name) as customer_name,
           DATEDIFF(YEAR, gc.birthdate, GETDATE()) as age
    from [gold.fact_sales] gs 
    left join [gold.dim_customers] gc on gs.customer_key = gc.customer_key
    where order_date is not null
),
customer_aggregation as (
    select customer_key, customer_number, customer_name, age,
           COUNT(distinct(order_number)) as total_order,
           sum(sales_amount) as total_sales,
           sum(quantity) as total_quantity,
           count(distinct(product_key)) as total_products,
           MAX(order_date) as last_order,
           DATEDIFF(MONTH,min(order_date), max(order_date)) as cus_span
    from base_query
    group by customer_key, customer_number, customer_name, age
)
select customer_key, customer_number, customer_name, age, 
       -- Age segmentation
       case 
           when age < 20 then 'Under 20'
           when age between 20 and 29 then '20-29'
           when age between 30 and 39 then '30-39'
           when age between 40 and 49 then '40-49'
           else '50 and above' 
       end as age_seg,
       -- Customer segment based on span and sales
       case 
           when cus_span >= 12 and total_sales > 5000 then 'VIP'
           when cus_span >= 12 and total_sales <= 5000 then 'Regular'
           else 'New' 
       end as cus_seg,
       total_order, total_sales, total_quantity, total_products,
       last_order, DATEDIFF(MONTH,last_order,GETDATE()) as recency,
       case when total_order = 0 then 0 else (total_sales/total_order) END as avg_sale,
       case when cus_span = 0 then 0 else (total_sales/cus_span) END as avg_month_sales,
       cus_span
from customer_aggregation

-- 🧠 LEARNED: Created a comprehensive customer report with segmentation, metrics, and recency/frequency indicators.

-- 📦 CREATE GOLDEN REPORT FOR PRODUCTS

create view golden_report_product as
with base_product as (
    select gs.order_number, gs.order_date, gs.customer_key,
           gs.sales_amount, gs.quantity,
           gp.product_key, gp.product_name, gp.category, gp.subcategory, gp.cost
    from [gold.fact_sales] as gs 
    left join [gold.dim_products] as gp on gs.product_key = gp.product_key
    where order_date is not Null
),
prod_agg as (
    select product_key, product_name, category, subcategory, cost,
           datediff(MONTH, MIN(order_date), MAX(order_date)) as life_span,
           MAX(order_date) as last_order,
           count(distinct(order_number)) as total_order,
           count(distinct(customer_key)) as cus,
           sum(sales_amount) as total_sales,
           sum(quantity) as quan_sold,
           Round(AVG(cast(sales_amount as float)/quantity), 2) as avg_selling_price
    from base_product
    group by product_key, product_name, category, subcategory, cost
)
select product_key, product_name, category, subcategory, cost,
       last_order, DATEDIFF(MONTH, last_order, GETDATE()) as recency,
       case 
           when total_sales > 50000 then 'High performance'
           when total_sales >= 10000 then 'Mid Range'
           else 'Low Performance' 
       end as prod_seg,
       life_span, total_order, total_sales, quan_sold, cus,
       avg_selling_price,
       case when total_order = 0 then 0 else total_sales/total_order end as avg_order_rev,
       case when life_span = 0 then 0 else total_sales/life_span end as avg_month_rev
from prod_agg

-- 🧠 LEARNED: Created product-level KPIs like lifetime, performance, and profitability metrics to evaluate SKUs.

-- Preview product report
select * from golden_report_product
