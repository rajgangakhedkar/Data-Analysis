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
