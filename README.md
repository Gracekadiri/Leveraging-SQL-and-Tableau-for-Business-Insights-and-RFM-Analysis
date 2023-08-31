# Leveraging-SQL-and-Tableau-for-Business-Insights-and-RFM-Analysis

## Introduction
In this project, I analyzed sales data using SQL queries and leveraged Tableau's visualization capabilities to derive meaningful business insights. Additionally, I performed RFM analysis to assess customer behavior based on their recency, frequency, and monetary value. The segmentation of customers allowed me to understand distinct customer groups and tailor marketing strategies to improve customer retention and drive revenue growth.


## Dashboard

https://public.tableau.com/app/profile/kadiri.grace.edose/viz/SalesDashboard_16899151589960/Dashboard1?publish=yes

![Sales Analysis Tableau](https://github.com/Kadiis/Leveraging-SQL-and-Tableau-for-Business-Insights-and-RFM-Analysis/assets/106782819/998ce6cc-493b-4286-9dd5-5ab50d34cf3d)


## Analysis
```ruby
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
```

##  Quick Insights from the Analysis:

Revenue by Year: The year 2004 saw the highest revenue, totaling around £4,724,162.59. However, in 2005, the revenue decreased significantly to approximately £1,791,486.71.

Revenue by Deal Size: Customers in the "Medium" deal size category contributed the most to the revenue, generating around £6,087,432.24. The "Small" deal size category followed with approximately £2,643,077.35 in revenue, while the "Large" category had the lowest revenue of about £1,302,119.26.

Best Sales Month: November was the most profitable month, with 597 orders and a total revenue of approximately £2,118,885.67.

Best Selling Product Line in November: In November, "Classic Cars" were the best-selling products, with 219 orders and a total revenue of around £825,156.26.

Quantity of Classic Cars Ordered in November: In November, a total of 7,548 units of "Classic Cars" were ordered, making it the most popular product.


## Customer Segmentation using RFM

```ruby
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

```

## Conclusion 
Based on these segments, the company can tailor its marketing and retention strategies accordingly. It should focus on providing exceptional service and personalized offers to Loyal and Active Customers, while implementing targeted campaigns to re-engage Potential Churners and Slipping Away customers. For Lost Customers, the company may consider offering special incentives to win them back. By understanding the different customer segments, the company can optimize its efforts to maximize customer retention and revenue growth.

