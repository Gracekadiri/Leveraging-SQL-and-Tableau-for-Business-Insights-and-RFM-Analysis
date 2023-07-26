--- Inspecting data
Select * from sales_data

--- checking for unique values
select distinct STATUS from sales_data
select distinct YEAR_ID from sales_data
select distinct PRODUCTLINE from sales_data
select distinct COUNTRY from sales_data
select distinct DEALSIZE from sales_data
select distinct TERRITORY from sales_data
select distinct MONTH_ID from sales_data
Where YEAR_ID = 2005


--- ANALYSIS

---"Which product line had the highest number of customers, and what were the total sales for that product line?"
 SELECT PRODUCTLINE, COUNT(DISTINCT CUSTOMERNAME) AS NumCustomers, SUM(SALES) AS TotalSales
FROM sales_data
GROUP BY PRODUCTLINE
ORDER BY 3 DESC;

---"What is the revenue generated for each year?  
Select YEAR_ID, SUM(SALES) As REVENUE
From sales_data
Group by YEAR_ID
Order by 2 Desc

---What is the revenue generated for each deal size ?
Select DEALSIZE, SUM(SALES) As REVENUE
From sales_data
Group by DEALSIZE
Order by 2 Desc

-- What was the best month for sales in all year? How much was earned?
Select MONTH_ID, COUNT(ORDERNUMBER) AS FREQUENCY, SUM(SALES) AS REVENUE
From sales_data
Group by MONTH_ID
Order by 2 Desc

-- November seems to be the month, what products do they sell in November
Select PRODUCTLINE, COUNT(ORDERNUMBER) AS FREQUENCY, SUM(SALES) AS REVENUE
From sales_data
Where MONTH_ID = 11 
Group by PRODUCTLINE
Order by 2 Desc;

-- Classic cars appear to be the products. How many quantities of classic cars were ordered in November?
SELECT PRODUCTLINE, SUM(QUANTITYORDERED) AS OrderValue
FROM sales_data
Where MONTH_ID = 11 AND PRODUCTLINE = 'Classic Cars'
GROUP BY  PRODUCTLINE;


-- Which of our customer falls into the 'Loyal' segment based on RFM analysis
WITH rfm AS (
    SELECT
        CUSTOMERNAME AS CUSTOMERTITLE,
        SUM(SALES) AS MONETARYVALUE,
        AVG(SALES) AS AVG_MONETARYVALUE,
        COUNT(ORDERNUMBER) AS FREQUENCY,
        MAX(ORDERDATE) AS LAST_ORDERDATE,
        (SELECT MAX(ORDERDATE) FROM sales_data) AS MAX_ORDERDATE,
        DATEDIFF(DAY, MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM sales_data)) AS RECENCY
    FROM sales_data
    GROUP BY CUSTOMERNAME
),
rfm_score AS (
    SELECT
        CUSTOMERTITLE,
        RECENCY,
        FREQUENCY,
        MONETARYVALUE,
        NTILE(4) OVER (ORDER BY RECENCY DESC) AS R,
        NTILE(4) OVER (ORDER BY FREQUENCY DESC) AS F,
        NTILE(4) OVER (ORDER BY MONETARYVALUE DESC) AS M
    FROM rfm
)
SELECT
    CUSTOMERTITLE,
    CONCAT(R, F, M) AS rfm_cell,
    (CASE
        WHEN R = 4 AND F >= 3 AND M >= 3 THEN 'Loyal'
		WHEN R = 2 AND F <= 3 AND M <= 3 THEN 'Potential churners'
		WHEN R >= 3 AND F >= 3 AND M >= 1 THEN 'Active Customers'
		WHEN R >= 3 AND F >= 1 AND M >= 1 THEN 'New Customers'
		WHEN R <= 3 AND F >= 3 AND M >= 3 THEN 'Slipping Away'
		WHEN R <= 2 AND F >= 1  AND M >= 1 THEN 'Lost Customers'
    END) AS CUSTOMER_SEGMENT
FROM rfm_score
ORDER BY rfm_cell DESC;




