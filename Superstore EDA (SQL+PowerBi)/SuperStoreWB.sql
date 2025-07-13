select * from train

---- looking for duplicate Product ID

select [Product ID], Category, [Sub-Category], REPLACE([Product Name], '"','') as Product_name, 
count([Product ID]) over (partition by [Product ID] order by [Product ID]) as occurance_pid
from train
group by [Product ID], Category, [Sub-Category], [Product Name]
order by count([Product ID]) over (partition by [Product ID] order by [Product ID]) desc

--- to count number of duplicates Product ID

with dup as (
select [Product ID], Category, [Sub-Category], REPLACE([Product Name], '"','') as Product_name, 
count([Product ID]) over (partition by [Product ID] order by [Product ID]) as occurance_pid
from train
group by [Product ID], Category, [Sub-Category], [Product Name]
)
select COUNT(distinct([Product ID])) as no_dup_product
from dup
where occurance_pid>1


---- making new fact table ----
create table Product_fact(
[Row ID] varchar(200),
[Order ID] varchar(200),
[Order Date] varchar(200),
[Ship Date] varchar(200),
[Ship Mode] varchar(200),
[Customer ID] varchar(200),
[Customer Name] varchar(200),
[Segment] varchar(200),
[Country] varchar(200),
[City] varchar(200),
[State] varchar(200),
[Postal Code] varchar(200),
[Region] varchar(200),
[Product ID] varchar(200),
[Category] varchar(200),
[Sub-Category] varchar(200),
[Product Name] varchar(200),
[Sales] varchar(200)
)

insert into Product_fact([Row ID],[Order ID],[Order Date],[Ship Date],[Ship Mode],[Customer ID],[Customer Name],Segment,Country,City,[State],[Postal Code],
Region,[Product ID],Category,[Sub-Category],[Product Name],Sales)
select [Row ID],[Order ID],[Order Date],[Ship Date],[Ship Mode],[Customer ID],[Customer Name],Segment,Country,City,[State],[Postal Code],
Region,[Product ID],Category,[Sub-Category],REPLACE([Product Name], '"','') as Product_name,Sales
from train

---renaming Product_fact

sp_rename 'Product_fact','SuperStoreDB'

select top(5) * from SuperStoreDB

-----------------------------------------------
-----------------------------------------------
--- creating dimension table for Products-----

create table Productdim(
Pid_unique int primary key not null,
Product_ID varchar(200),
Category varchar(200),
Sub_category varchar(200),
Product_name varchar(200)
)

Insert into Productdim(Pid_unique,Product_ID,Category,Sub_category,Product_name)
select 
ROW_NUMBER() over (order by [Product ID], Category, [Sub-Category], [Product Name]) as unique_pid
,[Product ID], Category, [Sub-Category], [Product Name]
from SuperStoreDB
group by [Product ID], Category, [Sub-Category], [Product Name]
order by ROW_NUMBER() over (order by [Product ID], Category, [Sub-Category], [Product Name])


--------- To Insert unique_pid into fact table 

alter table SuperStoreDB
add Pid_unique int

select * from SuperStoreDB


update s
set s.Pid_unique = p.Pid_unique
from SuperStoreDB as s join Productdim as p on
s.[Product ID] = p.Product_ID AND
s.Category=p.Category AND
s.[Sub-Category]=p.Sub_category AND
s.[Product Name]=p.Product_name


alter table SuperStoreDB
drop column [Product ID], Category, [Sub-Category], [Product Name]


---- looking for location

select distinct(Trim([Postal Code]))
from SuperStoreDB

-- found null postalcode so updating it ** Source google
update SuperStoreDB
set [Postal Code] = 05401
where [State] = 'Vermont' and City = 'Burlington'


-----------------------------Creating unique location for location dimension--------------------------------

select ROW_NUMBER() over (order by Trim(Country),Trim(City) ,Trim([State]),Trim([Postal Code])) as 
uni_loc,
Trim(Country) as Country,Trim(City) as City,Trim([State]) as [State],Trim([Postal Code]) as [Postal Code]
from SuperStoreDB
group by Trim(Country),Trim(City),Trim([State]),Trim([Postal Code])

----------------Creating location_dim table------------------

create table location_dim(
uniq_loc int primary key not null,
Country varchar(200),
City varchar(200),
[State] varchar(200),
Postal_Code int
)

WITH CleanedLocations AS (
    SELECT DISTINCT
        TRIM(Country) AS Country,
        TRIM(City) AS City,
        TRIM([State]) AS [State],
        TRIM(CAST([Postal Code] AS VARCHAR)) AS Postal_Code
    FROM SuperStoreDB
    WHERE [Postal Code] IS NOT NULL
),
RankedLocations AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY Country, City, [State], Postal_Code) AS uniq_loc,
        Country,
        City,
        [State],
        Postal_Code
    FROM CleanedLocations
)
INSERT INTO location_dim (uniq_loc, Country, City, [State], Postal_Code)
SELECT * FROM RankedLocations;


select * from location_dim

select * from SuperStoreDB
-------------------------------------------- Updating Fact table with locationdim keys
alter table SuperStoreDB
add uniq_loc int

update s
set s.uniq_loc = l.uniq_loc
from SuperStoreDB as s join location_dim as l
on s.Country=l.Country AND
s.City=l.City AND
s.[State] = l.[State] AND
s.[Postal Code] = l.Postal_Code

alter table SuperStoreDB
drop column Country,City,[State],[Postal Code]


------------------------ JUNK dimension--------------------
select ROW_NUMBER() over (order by [Ship Mode],Segment,Region ) as uniq_junk, [Ship Mode],Segment,Region
from SuperStoreDB
group by [Ship Mode],Segment,Region

create table junkdim(
uniq_junk int primary key not null,
[Ship Mode] varchar(200),
Segment varchar(200),
Region varchar(200)
)

----- Adding into junkdim------------
insert into junkdim
select ROW_NUMBER() over (order by [Ship Mode],Segment,Region ) as uniq_junk, [Ship Mode],Segment,Region
from SuperStoreDB
group by [Ship Mode],Segment,Region


alter table SuperStoreDB
add uniq_junk int 

select * from junkdim
select * from SuperStoreDB

update s
set s.uniq_junk = j.uniq_junk
from SuperStoreDB s join junkdim j on
s.[Ship Mode]=j.[Ship Mode] AND
s.Segment=j.Segment AND
s.Region=j.Region

alter table SuperStoreDB
drop column [Ship Mode], Segment, Region



--------------------------------Cleaning Sales column----------------

select CHARINDEX(',', REVERSE(Sales))
from SuperStoreDB

update SuperStoreDB
set Sales = 	case
when CHARINDEX(',', REVERSE(Sales))>0
then
cast( Replace(RIGHT(Sales, CHARINDEX(',', REVERSE(Sales))),',','') as FLOAT)
else CAST(trim(Sales) as Float) end

select * from SuperStoreDB 
where Sales is null

---- Converting date 
update SuperStoreDB
set [Order Date]= CONVERT(DATE, [Order Date], 105) 

update SuperStoreDB
set [Ship Date]= CONVERT(DATE, [Ship Date], 105) 

select min([Order Date]), MAX([Order Date]) from SuperStoreDB

----------- CREATING DATEDIM----------------

create table datedim(
Order_date DATE,
Shipped_date DATE
)

insert into datedim(Order_date)
select distinct([Order Date])
from SuperStoreDB




--------------
