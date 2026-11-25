\-- ==========================================
-- COFFEE SHOP SALES ANALYSIS
-- Author: Emmanuel Ahiati
-- Description: SQL queries used to clean data and analyze sales
-- ==========================================

-- ==========================================
-- 1. DATA CLEANING & PREPARATION
-- ==========================================

-- Clean the Revenue column by removing the dollar sign and converting it to a number
UPDATE transactions 
SET Revenue = REPLACE(Revenue, '$', '');

ALTER TABLE transactions 
MODIFY Revenue DECIMAL(10,2);

-- Add Month columns that were missing from the final table
ALTER TABLE transactions ADD COLUMN Month_Num INT;
ALTER TABLE transactions ADD COLUMN Month_Name VARCHAR(20);

-- Populate the new Month columns from the raw data table
UPDATE transactions t
JOIN raw_transactions r ON t.transaction_id = r.transaction_id
SET t.Month_Num = r.Month_Num, 
    t.Month_Name = r.Month_Name;

-- ==========================================
-- 2. BUSINESS ANALYSIS QUERIES
-- ==========================================

-- Q1: Revenue by Store
-- Goal: Compare total revenue across the three store locations.
SELECT 
    s.store_location, 
    SUM(t.Revenue) AS Total_Revenue
FROM 
    transactions t
JOIN 
    stores s ON t.store_id = s.store_id
GROUP BY 
    s.store_location
ORDER BY 
    Total_Revenue DESC;


-- Q2: Monthly Revenue Trend
-- Goal: Show how revenue changed from January to June.
SELECT 
    Month_Name,
    Month_Num,
    SUM(Revenue) AS Total_Revenue
FROM 
    transactions
GROUP BY 
    Month_Name, Month_Num
ORDER BY 
    Month_Num ASC;


-- Q3: Revenue by Hour (Formatted)
-- Goal: Identify the busiest hours of the day.
SELECT 
    Hour,
    CASE 
        WHEN Hour = 0 THEN '12am'
        WHEN Hour < 12 THEN CONCAT(Hour, 'am')
        WHEN Hour = 12 THEN '12pm'
        ELSE CONCAT(Hour - 12, 'pm')
    END AS Time_Label,
    SUM(Revenue) AS Total_Revenue
FROM 
    transactions
GROUP BY 
    Hour, Time_Label
ORDER BY 
    Hour ASC;


-- Q4: Revenue by Product Category
-- Goal: Identify which product categories drive the most revenue.
SELECT 
    p.product_category,
    SUM(t.Revenue) AS Total_Revenue
FROM 
    transactions t
JOIN 
    products p ON t.product_id = p.product_id
GROUP BY 
    p.product_category
ORDER BY 
    Total_Revenue DESC;


-- Q5: Top 5 Categories for Hell's Kitchen
-- Goal: Store-specific analysis for management.
SELECT 
    p.product_category,
    SUM(t.Revenue) AS Total_Revenue
FROM 
    transactions t
JOIN 
    products p ON t.product_id = p.product_id
JOIN 
    stores s ON t.store_id = s.store_id
WHERE 
    s.store_location = 'Hell''s Kitchen'
GROUP BY 
    p.product_category
ORDER BY 
    Total_Revenue DESC
LIMIT 5;