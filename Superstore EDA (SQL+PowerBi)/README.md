SuperStore SQL Data Warehouse Project
Overview
This project transforms the raw SuperStore dataset into a structured star schema using SQL Server. The resulting model supports efficient analysis and reporting in tools like Power BI.
________________________________________
Objectives
•	Clean and preprocess raw data
•	Build a fact table and supporting dimension tables
•	Create surrogate keys and remove redundancy
•	Prepare data for visual analytics
________________________________________
Steps Performed
1. Initial Exploration and Cleaning
•	Queried the train table to examine the structure.
•	Checked for duplicate Product IDs using window functions.
•	Counted how many product IDs occurred more than once.
2. Fact Table Creation: SuperStoreDB
•	Created a Product_fact table to store sales transactions.
•	Cleaned Product Name by removing quotes.
•	Renamed the table to SuperStoreDB.
3. Product Dimension: Productdim
•	Created a dimension table with:
o	Pid_unique (surrogate key)
o	Product_ID, Category, Sub-Category, Product_name
•	Used ROW_NUMBER() for unique keys.
•	Linked SuperStoreDB to Productdim and dropped original columns.
4. Location Dimension: location_dim
•	Cleaned and standardized Country, City, State, Postal Code.
•	Filled in missing postal codes (e.g., Burlington, Vermont).
•	Created surrogate key uniq_loc.
•	Updated fact table and removed original location columns.
5. Junk Dimension: junkdim
•	Combined Ship Mode, Segment, and Region into one dimension.
•	Created a surrogate key uniq_junk.
•	Updated fact table with the new key and dropped original columns.
6. Cleaning Sales Column
•	Cleaned Sales values containing commas.
•	Converted text-based sales to FLOAT.
7. Date Conversion
•	Converted [Order Date] and [Ship Date] to DATE format using style 105 (dd-mm-yyyy).
8. Date Dimension: datedim
•	Created a date dimension table with distinct [Order Date] values.
•	Laid groundwork for linking shipping dates as well.
________________________________________
Resulting Schema
Fact Table: - SuperStoreDB
Dimension Tables: - Productdim (product-related) - location_dim (geography-related) - junkdim (low-cardinality attributes) - datedim (time)
This schema supports robust reporting and is ready for use in Power BI.
________________________________________
Next Step
•	Integrate this model with a Power BI dashboard (to be added in a separate .pbix file or Power BI Service link).

------------------ Power Bi--------------------

Project Findings – Sales & Shipment Analysis:
-------------------------------------------------------------------------------------------------------------------------------
Technology Leads in Sales
Technology is the top-selling product category, contributing 36.6% of total revenue. High-ticket tech products such as the Canon imageCLASS 2200 Copier consistently drive sales, with a single product generating $61K alone. This suggests that focusing marketing or bundling strategies around tech products could boost revenue further.

--------------------------------------------------------------------------------------------------------------------------------
Customer Engagement Varies Widely
Out of 793 users:
- 527 are Regular (purchased in the last 3 months)
- 96 are Occasional (purchased in 3-6 months)
- 170 are Inactive (>6 months)
This shows a healthy base of engaged customers, but also highlights a retention gap — targeting inactive users with re-engagement campaigns could increase conversions.

----------------------------------------------------------------------------------------------------------------------------------
Year-over-Year Sales Trends Show Strong Growth
Sales grew from $459K in 2016 to $722K in 2018, a 57% increase over two years. The strongest growth came in 2017 (+30.6% YoY), indicating successful momentum that should be sustained. A dip in 2016 sales (-4.3%) could reflect seasonal or operational issues worth further investigation.

----------------------------------------------------------------------------------------------------------------------------------
California & New York Dominate Sales — But Also Delays
Top States by Sales:
- California: $446K
- New York: $306K
However, these states also lead in shipment delays, especially postal codes in New York (10035, 10024, etc.). This points to logistics bottlenecks in key markets — improving delivery in these areas could improve customer satisfaction and reduce churn.

----------------------------------------------------------------------------------------------------------------------------------
Shipments Face Reliability Challenges
1,586 delayed shipments were recorded, with Standard Class being the most delayed mode (2,944 delays). Tuesdays and Saturdays are the most delay-prone days. The West and East regions have the highest number of delays.
These trends indicate the need to:
- Re-evaluate shipping partner performance
- Adjust logistics planning on high-delay weekdays
- Use this insight to negotiate SLAs or improve delivery tracking.

----------------------------------------------------------------------------------------------------------------------------------
Consistent Top Products Drive Monthly Performance
Each month is dominated by a standout product, showing strong seasonal trends.
For example:
- Mar: Cisco Videoconferencing System → $22.6K
- Oct: Canon Copier → $28.7K
This insight can inform inventory planning, seasonal promotions, and stock prioritization.

----------------------------------------------------------------------------------------------------------------------------------
Delayed Shipment Risk Can Be Geographically Targeted
Most delays are clustered in a few postal codes and regions.
For example:
- 10035 (New York): 85 delays
- 94122 (California): 64 delays
This suggests an opportunity for localized interventions — like alternate courier partnerships or fulfillment centers in those areas.

----------------------------------------------------------------------------------------------------------------------------------
Overall Summary
This dashboard enables actionable insights such as:
- Prioritizing high-performing categories and products
- Identifying underperforming regions in logistics
- Segmenting customers for better engagement
- Planning based on year-over-year trends and order cycles

