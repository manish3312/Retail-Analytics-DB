create database Retail_Analytics;
use Retail_Analytics;

select * from customers;
select * from products;
select * from sales;

describe customers;
describe products;
describe sales;

-- ï»¿CustomerID Rename to CustomerID
-- ï»¿ProductID Rename to ProductID
-- ï»¿TransactionID Rename to TransactionID

ALTER TABLE sales
RENAME COLUMN ï»¿TransactionID TO TransactionID;

ALTER TABLE customers
RENAME COLUMN ï»¿CustomerID TO CustomerID;

ALTER TABLE products
RENAME COLUMN ï»¿ProductID TO ProductID;


-- 1. Remove Duplicates
-- Write a query to identify the number of duplicates in "sales_transaction" table. Also, 
-- create a separate table containing the unique values and remove the the original table from the databases 
-- and replace the name of the new table with the original name.
-- Hint:
-- Use the “Sales_transaction” table.
-- There will be two resulting tables in the output. First, the table where the count of duplicates will be identified 
-- and in the second table we can check if the duplicates were removed or not by selecting the whole table.
-- How many rows share the same TransactionID?
SELECT TransactionID, COUNT(*) AS cnt
FROM sales
GROUP BY TransactionID
HAVING COUNT(*) > 1
ORDER BY cnt DESC, TransactionID;

-- There will be two resulting tables in the output. First, the table where the count of 
-- duplicates will be identified and in the second table we can check if the duplicates were removed or not by selecting the whole table.
 CREATE TABLE sales_unique AS
SELECT DISTINCT * 
FROM sales;

DROP TABLE sales;
ALTER TABLE sales_unique RENAME TO sales;





-- 2. Fix incorrect Prices
-- rows where the transaction price doesn't match the inventory price
-- Write a query to identify the discrepancies in the price of the same product in "sales_transaction" and "product_inventory" tables. 
-- Also, update those discrepancies to match the price in both the tables.
-- Hint:
-- Use the "sales_transaction" and the "product_inventory" tables.
-- There will be two resulting tables in the output. First, the table where the discrepancies will be identified and 
-- in the second table we can check if the discrepancies were updated or not.
-- Method 1
select p.ProductID, 
        s.TransactionID, 
    s.price as TransactionPrice, 
    p.price as InventoryPrice 
from sales s 
join products p 
        on s.ProductID = p.ProductID 
    where p.price != s.price;
    
 set sql_safe_updates = 0;
 
Update sales s 
Set Price = (
        SELECT p.price from Products p 
    where s.ProductID = p.ProductID 
    ) 
    where s.ProductID in ( 
                Select ProductID 
        from products p 
        WHERE p.price <> s.price); 
SELECT *
FROM sales
ORDER BY TransactionID;

-- Method 2 
SELECT
    st.TransactionID,
    st.ProductID,
    st.Price        AS TransactionPrice,
    pi.Price        AS InventoryPrice
FROM sales st
JOIN products AS pi
  ON pi.ProductID = st.ProductID
WHERE st.Price <> pi.Price
ORDER BY st.TransactionID, st.ProductID;

set sql_safe_updates = 0;
-- Fix prices in sales_transaction to match product_inventory
UPDATE sales st
JOIN products pi
  ON pi.ProductID = st.ProductID
SET st.Price = pi.Price
WHERE st.Price <> pi.Price;

SELECT *
FROM sales
ORDER BY TransactionID;







-- 3. Fixing NULL Values 
-- Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.
-- Hint:
-- Use the customer_profiles table.
-- Identify the columns which contains null values and count the number of cells containing null values. 
-- Update those values with “unknown” and showcase the changes that the query has created.
select * from customers;
SELECT 
  SUM(CASE WHEN Location IS NULL OR TRIM(Location) = '' THEN 1 ELSE 0 END) AS "count(*)"
FROM customers;

UPDATE customers
SET Location = 'Unknown'
WHERE Location IS NULL 
   OR TRIM(Location) = '';
-- (equivalently) WHERE NULLIF(TRIM(Location), '') IS NULL;

SELECT * FROM customers;







-- 4.Cleaning Date
-- Write a SQL query to clean the DATE column in the dataset.
-- Steps:
-- Create a separate table and change the data type of the date column as it is in TEXT format and name it as you wish to.
-- Remove the original table from the database.
-- Change the name of the new table and replace it with the original name of the table.
-- Hint:
-- Use the “Sales_transaction” tables.
-- The resulting table will display a separate column named TransactionDate_updated.

-- Step 1: Create a copy of the original table
CREATE TABLE sales_date_fixed AS
SELECT * FROM sales;

-- Step 2: Add a new column for cleaned date
ALTER TABLE sales_date_fixed
ADD COLUMN TransactionDate_Updated DATE;

-- Step 3: Populate the new column by converting text to date
UPDATE sales_date_fixed
SET TransactionDate_Updated = STR_TO_DATE(TransactionDate, '%d/%m/%Y');

-- Step 4: Delete old table and update new table's name
DROP TABLE sales;
ALTER TABLE sales_date_fixed RENAME TO sales;

-- Step 5: Verify results
SELECT * FROM sales;







-- 5. Total Sales Summary
-- Write a SQL query to summarize the total sales and quantities sold per product by the company.
-- (Here, the data has been already cleaned in the previous steps and from here we will be understanding 
-- the different types of data analysis from the given dataset.)
-- Hint:
-- Use the “Sales_transaction” table.
-- The resulting table will display the total quantity purchased by the customers and 
-- the total sales done by the company to evaluate the product performance.
-- Return the result table in descending order corresponding to Total Sales Column.
SELECT 
    ProductID,
    SUM(QuantityPurchased) AS TotalUnitsSold,
    SUM(QuantityPurchased * Price) AS TotalSales
FROM 
    sales
GROUP BY 
    ProductID
ORDER BY 
    TotalSales DESC;
    
    
    
    
    
    
-- 6. Customer Purchase Frequency
-- Write a SQL query to count the number of transactions per customer to understand purchase frequency.
-- Hint:
-- Use the “Sales_transaction” table.
-- The resulting table will be counting the number of transactions corresponding to each customerID.
-- Return the result table ordered by NumberOfTransactions in descending order.
    SELECT 
    CustomerID,
    COUNT(TransactionID) AS NumberOfTransactions
FROM 
    sales
GROUP BY 
    CustomerID
ORDER BY 
    NumberOfTransactions DESC;
    
    
    
    
    
    
-- 7. Product Categories Performance
-- Write a SQL query to evaluate the performance of the product categories based on 
-- the total sales which help us understand the product categories which needs to be promoted in the marketing campaigns.
-- Hint:
-- Use the “Sales_transaction” and "product_inventory" table.
-- The resulting table must display product categories, the aggregated count of units 
-- sold for each category, and the total sales value per category.
-- Return the result table ordering by TotalSales in descending order.
    SELECT 
    p.Category,
    SUM(s.QuantityPurchased) AS TotalUnitsSold,
    SUM(s.QuantityPurchased * s.Price) AS TotalSales
FROM 
    sales s
JOIN 
    products p
    ON s.ProductID = p.ProductID
GROUP BY 
    p.Category
ORDER BY 
    TotalSales DESC;
    
    
    
    
    
    
    
-- 8. High Sales Product 
-- Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions.
-- This will help the company to identify the High sales products which needs to be focused to increase the revenue of the company.
-- Hint:
-- Use the “Sales_transaction” table.
-- The resulting table should be limited to 10 productIDs whose TotalRevenue (Product of Price and QuantityPurchased) is the highest.
-- Return the result table ordering by TotalRevenue in descending order.
SELECT 
    ProductID,
    SUM(QuantityPurchased * Price) AS TotalRevenue
FROM 
    sales
GROUP BY 
    ProductID
ORDER BY 
    TotalRevenue DESC
LIMIT 10;






-- 9.Low Sales Products
-- Write a SQL query to find the ten products with the least amount of units sold from the sales transactions, 
-- provided that at least one unit was sold for those products.
-- Hint:
-- Use the “Sales_transaction” table.
-- The resulting table should be limited to 10 productIDs whose TotalUnitsSold (sum of QuantityPurchased) is the least.
-- (The limit value can be adjusted accordingly)
-- Return the result table ordering by TotalUnitsSold in ascending order.
SELECT 
    ProductID,
    SUM(QuantityPurchased) AS TotalUnitsSold
FROM 
    sales
GROUP BY 
    ProductID
HAVING 
    SUM(QuantityPurchased) > 0
ORDER BY 
    TotalUnitsSold ASC
LIMIT 10;






-- 10. Sales Trend
-- Write a SQL query to identify the sales trend to understand the revenue pattern of the company.
-- Hint:
-- Use the “sales_transaction” table.
-- The resulting table must have DATETRANS in date format, count the number of transaction on that particular date, 
-- total units sold and the total sales took place.
-- Return the result table ordered by datetrans in descending order.
SELECT 
    DATE(TransactionDate) AS DATETRANS,
    COUNT(TransactionID) AS Transaction_count,
    SUM(QuantityPurchased) AS TotalUnitsSold,
    SUM(QuantityPurchased * Price) AS TotalSales
FROM 
    sales
GROUP BY 
    DATE(TransactionDate)
ORDER BY 
    DATETRANS DESC;
    
    
    
    
    
    
    
--  11. Growth Rate of Sales
-- Write a SQL query to understand the month on month growth rate of sales of the company which will help understand the growth trend of the company.
-- Hint:
-- Use the “sales_transaction” table.
-- The resulting table must extract the month from the transactiondate and then the Month on month growth percentange should be calculated. 
-- (Total sales present month - total sales previous month/ total sales previous month * 100)
-- Round all numerical answers to 2 decimal places
-- Return the result table ordering by month.

WITH monthly_sales AS (
    SELECT 
        MONTH(TransactionDate) AS month,
        ROUND(SUM(QuantityPurchased * Price), 2) AS total_sales
    FROM sales
    GROUP BY MONTH(TransactionDate)
)
SELECT
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales,
    ROUND(
        ((total_sales - LAG(total_sales) OVER (ORDER BY month)) 
         / NULLIF(LAG(total_sales) OVER (ORDER BY month), 0)) * 100,
        2
    ) AS mom_growth_percentage
FROM monthly_sales
ORDER BY month;






-- 12. High Purchase Feequency
-- Problem statement
-- Write a SQL query that describes the number of transaction along with the total amount spent by each 
-- customer which are on the higher side and will help us understand the customers who are the high frequency purchase customers in the company.
-- Hint:
-- Use the “sales_transaction” table.
-- The resulting table must have number of transactions more than 10 and 
-- TotalSpent more than 1000 on those transactions by the corresponding customers.
-- Return the result table on the “TotalSpent” in descending order.
SELECT
  CustomerID,
  COUNT(*) AS NumberOfTransactions,
  SUM(Price * QuantityPurchased) AS TotalSpent
FROM sales
GROUP BY CustomerID
HAVING COUNT(*) > 10
   AND SUM(Price * QuantityPurchased) > 1000
ORDER BY TotalSpent DESC;







-- 13. Occasional Customers
-- Problem statement
-- Write a SQL query that describes the number of transaction along with the total amount spent by each customer,
--  which will help us understand the customers who are occasional customers or have low purchase frequency in the company.
-- Hint:
-- Use the “Sales_transaction” table.
-- The resulting table must have number of transactions less than or equal to 2 and 
-- corresponding total amount spent on those transactions by related customers.
-- Return the result table of “NumberOfTransactions” in ascending order and “TotalSpent” in descending order.
SELECT
  CustomerID,
  COUNT(*) AS NumberOfTransactions,
  SUM(Price * QuantityPurchased) AS TotalSpent
FROM sales
GROUP BY CustomerID
HAVING COUNT(*) <= 2
ORDER BY NumberOfTransactions ASC, TotalSpent DESC;









-- 14. Repeat Purchases
-- Write a SQL query that describes the total number of purchases made by each customer 
-- against each productID to understand the repeat customers in the company.
-- Hint:
-- Use the “Sales_transaction” table.
-- The resulting table must have "CustomerID", "ProductID" and the number of times that particular customer have purchases the product.
-- The number of times the customer has purchased should be more than once.
-- Return the result table in descending order corresponding to the TimesPurchased column.
SELECT
  CustomerID,
  ProductID,
  COUNT(*) AS TimesPurchased
FROM sales
GROUP BY CustomerID, ProductID
HAVING COUNT(*) > 1
ORDER BY TimesPurchased DESC;








-- 15. Loyalty Indicator
-- Write a SQL query that describes the duration between the first and the last purchase of 
-- the customer in that particular company to understand the loyalty of the customer.
-- Hints:
-- Use the "Sales_transaction" table.
-- The DATE column will be majorly in use in the question and the TransactionDate column 
-- in Sales_transaction is in text format. Thus, the format of the TransactionDate column should be changed.
-- The resulting table must have the first date of purchase, the last date of purchase
--  and the difference between the first and the last date of purchase.
-- The difference between the first and the last date of purchase should be more than 0.
-- Return the table in descending order corresponding to DaysBetweenPurchases.
SELECT
  CustomerID,
  MIN(TransactionDate_Updated) AS FirstPurchase,
  MAX(TransactionDate_Updated) AS LastPurchase,
  DATEDIFF(MAX(TransactionDate_Updated), MIN(TransactionDate_Updated)) AS DaysBetweenPurchases
FROM sales
GROUP BY CustomerID
HAVING DaysBetweenPurchases > 0
ORDER BY DaysBetweenPurchases DESC;








-- 16. Customer Segmentation
-- Write an SQL query that segments customers based on the total quantity of products they have purchased. Also, 
-- count the number of customers in each segment which will help us target a particular segment for marketing.
-- Hint:
-- Use the customer_profiles and sales_transaction tables.
-- Create a separate table named customer_segment and create the segments on the total quantity of the purchased products.
-- To segment customers based on their purchasing behavior for targeted marketing campaigns. Create Customer segments on the following criteria-
-- Italian Trulli
-- The resulting table should count the number of customers in different customer segments.
-- Return the result table in any order.
WITH totals AS (
  SELECT
    CustomerID,
    SUM(QuantityPurchased) AS total_qty
  FROM sales
  GROUP BY CustomerID
),
segmented AS (
  SELECT
    CustomerID,
    total_qty,
    CASE
      WHEN total_qty BETWEEN 1 AND 10 THEN 'Low'
      WHEN total_qty BETWEEN 11 AND 30 THEN 'Med'
      WHEN total_qty > 30 THEN 'High'
      ELSE 'None'
    END AS CustomerSegment
  FROM totals
)
SELECT
  CustomerSegment,
  COUNT(*) AS "COUNT(*)"
FROM segmented
WHERE CustomerSegment <> 'None'
GROUP BY CustomerSegment;

-- Create_Table(16)
CREATE TABLE customer_segment AS
SELECT
  st.CustomerID,
  SUM(st.QuantityPurchased) AS total_qty,
  CASE
    WHEN SUM(st.QuantityPurchased) BETWEEN 1 AND 10 THEN 'Low'
    WHEN SUM(st.QuantityPurchased) BETWEEN 11 AND 30 THEN 'Med'
    WHEN SUM(st.QuantityPurchased) > 30 THEN 'High'
    ELSE 'None'
  END AS CustomerSegment
FROM sales st
GROUP BY st.CustomerID;

SELECT CustomerSegment, COUNT(*) AS NumCustomers
FROM customer_segment
WHERE CustomerSegment <> 'None'
GROUP BY CustomerSegment;




