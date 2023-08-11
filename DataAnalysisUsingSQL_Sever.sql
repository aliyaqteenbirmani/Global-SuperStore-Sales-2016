USE PortfolioProject;
-- We have an excel file containing 3 sheets orders, returned and people so first we need to convert that each sheet of .xlsx file to different .csv files

-- I created this table with same column names of order.csv files columns and set data type VARCHAR(MAX) because when we trying to insert data 
-- into this Order table it gives error because of mis-matched data types  
CREATE TABLE Orders 
( 
	[Row ID] VARCHAR(MAX),
	[Order ID] VARCHAR(MAX),
	[Order Date] VARCHAR(MAX),
	[Ship Date] VARCHAR(MAX),
	[Ship Mode] VARCHAR(MAX),
	[Customer ID]VARCHAR(MAX),
	[Customer Name] VARCHAR(MAX),
	Segment VARCHAR(MAX),
	[Postal Code] VARCHAR(MAX),
	City VARCHAR(MAX),
	[State] VARCHAR(MAX),
	Country VARCHAR(MAX),
	Region VARCHAR(MAX),
	Market VARCHAR(MAX),
	[Product ID] VARCHAR(MAX),
	Category VARCHAR(MAX),
	[Sub Category] VARCHAR(MAX),
	Sales VARCHAR(MAX),
	Quantity VARCHAR(MAX),
	Discount VARCHAR(MAX),
	Profit VARCHAR(MAX),
	[Shipping Cost] VARCHAR(MAX),
	[Order Priority] VARCHAR(MAX),
	[Product Name] VARCHAR(MAX),
);

-- Returned table for Returned.csv with same column name and types
CREATE TABLE Returned 
(
	Returned VARCHAR(10),
	[Order ID] varchar(50),
	Region varchar(50)
);

-- People Table for People.csv with same column name and types
CREATE TABLE People
(
	Person varchar(50),
	Region varchar(50)
);

-- Insert whole data into Orders, Returned & People Table in one go Using BULK command 
GO
BULK INSERT dbo.Orders FROM 'C:\Users\Public\Orders.csv' WITH(FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
BULK INSERT dbo.Returned FROM 'C:\Users\Public\Returned.csv' WITH(FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');
BULK INSERT dbo.People FROM 'C:\Users\Public\People.csv' WITH(FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

-- Use below query to check data types of any table
SELECT Column_name, data_type FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Orders';


-- Altering Orders Table to change columns data type according to the data nature
ALTER TABLE Orders ALTER Column [Row ID] INT; 
ALTER TABLE Orders ALTER COLUMN Sales INT;
ALTER TABLE Orders ALTER COLUMN Quantity INT;
ALTER TABLE Orders ALTER COLUMN Discount FLOAT; 
ALTER TABLE Orders ALTER COLUMN Profit INT;
ALTER TABLE Orders ALTER COLUMN [Shipping Cost] INT;
ALTER TABLE Orders ALTER COLUMN [Order Date] DATE;
ALTER TABLE Orders ALTER COLUMN [Ship Date] DATE;

-- You can also run this command to check table
EXEC sp_help 'Orders';


-- Now our tables are ready for Data Analysis and Validation so lets start 
-- We have 5 KPI's so first start with KPI's

-------------------------------------------------------
				-- KPI's Validation --
-------------------------------------------------------
		--
		--,DAY([Ship Date] - [Order Date]) as [Avg Delivery Day]
SELECT SUM(Sales) as [Total Sales], 
	   SUM(Sales+Profit) AS Revenue,
	   sum(Profit) as Profit,
	   SUM(Quantity) AS Quantity_Sold,
	   AVG(DATEDIFF(day,[Order Date],[Ship Date])+1) AS [Avg Delivery Day]
From Orders;

SELECT Returned, COUNT(Returned) AS [COUNT] from Returned GROUP BY Returned;

-- Hurray our Answers matched with KPI's Values


-------------------------------------------------------
				-- Bar Chart's Value Validation --
-------------------------------------------------------


-- Now Find Top 6 Product by Profit 
-- For this we need to create filter so lets start

SELECT TOP 6 [Product Name] AS [Product by Profit], Sum(Profit) AS Profit from Orders GROUp BY [Product Name] ORDER BY Profit DESC;


-- Now Find Top 6 Product by Loss 
-- For this we can use the same filter just order in ascending 
SELECT TOP 6 [Product Name] AS [Product by Loss], Sum(Profit) AS Profit from Orders GROUP BY [Product Name] ORDER BY Profit ASC;


-------------------------------------------------------
		-- Donut & Pie Chart's Value Validation --
-------------------------------------------------------

-- To get the Donut and pie chart values i created a variable TotalSales to store total sales so the we can divide each Market sales by total
DECLARE @TotalSales DECIMAL(18, 2);
SET @TotalSales = (Select SUM(Sales) from Orders);
Select Market,CAST(ROUND(sum(Sales)/@TotalSales*100,0) AS INT) AS [Market Contribution %]  from Orders Group by Market;
Select Segment,CAST(ROUND(sum(Sales)/@TotalSales*100,2) AS FLOAT) AS [Segment Contribution %]  from Orders Group by Segment;


-------------------------------------------------------
		-- Column Chart's Value Validation --
-------------------------------------------------------

-- TOP 10 Customer by Profit 
SELECT TOP 10 [Customer Name], SUM(Profit) AS Profit FROM Orders GROUP BY [Customer Name] ORDER BY Profit DESC;


-- From Here I have written some extra queries to analyze data by Region, Country, Yearly Sales, Revenue and Quantity Sold by Category and sales by sub-category 
-- TOP 10 Customer by Loss 
SELECT TOP 10 [Customer Name], SUM(Profit) AS Profit FROM Orders GROUP BY [Customer Name] ORDER BY Profit ASC;


-------------------------------------------------------
		-- Sales by Region,Country and State --
-------------------------------------------------------
SELECT TOP 5 Region ,CAST(SUM(Sales) AS FLOAT)/1000 as [Sales in K] FROM Orders GROUP BY Region ORDER BY [Sales in K] DESC;


SELECT TOP 5 Country,SUM(Sales) as TotalSales FROM Orders GROUP BY Country ORDER BY TotalSales DESC


SELECT TOP 5 State,SUM(Sales) as TotalSales FROM Orders GROUP BY State ORDER BY TotalSales DESC


-------------------------------------------------------
		-- Yearly Sales, Revenue and Quantity  --
-------------------------------------------------------

SELECT YEAR([Order Date]) as Years,
	   CAST(ROUND(CAST(SUM(Sales) AS FLOAT)/1000000,2) AS VARCHAR(20)) + 'M' AS [Total Sales],
	   CAST(ROUND(CAST(SUM(Quantity) AS FLOAT)/1000,2) AS VARCHAR(20)) + 'K' AS [Quantity Sold],
	   CAST(ROUND(CAST(SUM(Sales + Profit) AS FLOAT)/1000000,2) AS VARCHAR(20)) + 'M' AS Revenue
from Orders GROUP BY YEAR([Order Date])  ORDER BY Years ASC

-------------------------------------------------------
		-- Category and Sub-Category  --
-------------------------------------------------------

-- Category with Quantity
SELECT Category, SUM(Quantity) as Quantity FROM ORDERS GROUP BY Category

-- TOP 5 Sub-Category with Quantity and Total Sales

SELECT TOP 5 [Sub Category],SUM(Quantity) as Quantity, SUM(Sales) as Sales FROM ORDERS GROUP BY [Sub Category]


-- WE have done our analysis here, If any of you have any question related to these queries plz email me at aliyaqteenbirmani512@gmail.com. I'll try to answer you.
