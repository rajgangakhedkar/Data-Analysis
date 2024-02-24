create procedure rws
as
select top(1) * from ..pizza_sales

--TOTAL SALE--
select round(SUM(total_price),2) as Total_revenue
from ..pizza_sales

-- avg order value--
select SUM(total_price)/ COUNT(distinct(Order_id)) as avg_value
from ..pizza_sales

-- total pizza sold --

select sum(quantity) as total_pizza
from ..pizza_sales


-- total order --
select count(distinct(order_id))
from ..pizza_sales

-- avg pizzas per order --

exec rws

select cast(cast(sum(quantity)as decimal(10,2)) /cast(count(distinct(order_id)) as decimal(10,2)) 
as decimal(10,2))
from..pizza_sales

--- daily trend for total orders ---



SELECT datename(dw,order_date) as days, count(distinct(order_id))
from ..pizza_sales
group by datename(dw,order_date)

--- monthly trend of orders ---

select DATENAME(MONTH, order_date) as months, count(distinct(order_id))
from ..pizza_sales
group by DATENAME(MONTH, order_date)


-- % sale by each piza category ---
select  pizza_category, cast(sum(total_price)/(select sum(total_price) from ..pizza_sales ) *100 as decimal(10,2))
 as cat
from ..pizza_sales
group by pizza_category
order by cat

-- % sale by pizza size --

select pizza_size, cast(sum(total_price)/(select sum(total_price) from ..pizza_sales) *100 as decimal(10,2)) as sales_per
from ..pizza_sales
group by pizza_size

-- total pizzas sold by each category --

select pizza_category, sum(quantity) as total_quan
from ..pizza_sales
group by pizza_category

-- top 5 pizzas by revenue --

exec rws

select top(5) pizza_name, round(sum(total_price),2) as total_rev
from ..pizza_sales
group by pizza_name
order by total_rev desc

-- bottom 5 pizzas by revenue --

select top(5) pizza_name, round(sum(total_price),2) as total_rev
from ..pizza_sales
group by pizza_name
order by total_rev asc

-- top 5 pizzas by quantity --

select top(5) pizza_name , sum(quantity) as total_quan
from ..pizza_sales
group by pizza_name
order by total_quan desc

-- bottom 5 pizzas by quantity --

exec rws
select top(5) pizza_name, sum(quantity)
from ..pizza_sales
group by pizza_name
order by sum(quantity) 

-- top 5 pizza orders by total orders ---
select top(5) pizza_name, count(distinct(order_id)) as orders
from ..pizza_sales
group by pizza_name
order by orders desc

-- bottom 5 pizza orders by total orders ---
select top(5) pizza_name, count(distinct(order_id)) as orders
from ..pizza_sales
group by pizza_name
order by orders 