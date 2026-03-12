USE superstore;
SHOW TABLES;
SELECT * FROM cleaned_superstore LIMIT 10;
drop table superstore;
ALTER TABLE cleaned_superstore RENAME TO superstore;
SELECT * FROM superstore LIMIT 10;
-- 1. Overall Business Performance
SELECT 
    ROUND(SUM(Sales), 0) AS Total_Sales,
    ROUND(SUM(Profit), 0) AS Total_Profit,
    ROUND(SUM(Profit)/SUM(Sales) * 100, 2) AS Overall_Profit_Margin_Percent,
    COUNT(DISTINCT "Order ID") AS Total_Orders
FROM superstore;

-- 2. Yearly Performance Trend
SELECT 
    Year,
    ROUND(SUM(Sales), 0) AS Sales,
    ROUND(SUM(Profit), 0) AS Profit,
    ROUND(SUM(Profit)/SUM(Sales) * 100, 2) AS Profit_Margin
FROM superstore
GROUP BY Year
ORDER BY Year;


-- 3. Monthly Sales Trend (for seasonality)
SELECT 
    YearMonth,
    ROUND(SUM(Sales), 0) AS Monthly_Sales,
    ROUND(SUM(Profit), 0) AS Monthly_Profit
FROM superstore
GROUP BY YearMonth
ORDER BY YearMonth;
-- 4. Profit by Category
SELECT 
    Category,
    ROUND(SUM(Sales), 0) AS Sales,
    ROUND(SUM(Profit), 0) AS Profit,
    ROUND(SUM(Profit)/SUM(Sales) * 100, 2) AS Profit_Margin
FROM superstore
GROUP BY Category
ORDER BY Profit DESC;
-- 6. Top 10 Most Profitable Products
SELECT 
    "Product Name",
    ROUND(SUM(Profit), 0) AS Total_Profit,
    ROUND(SUM(Sales), 0) AS Total_Sales
FROM superstore
GROUP BY "Product Name"
ORDER BY Total_Profit DESC
LIMIT 10;
-- 7. Top 10 Loss-Making Products
SELECT 
    "Product Name",
    ROUND(SUM(Profit), 0) AS Total_Profit
FROM superstore
GROUP BY "Product Name"
HAVING Total_Profit < 0
ORDER BY Total_Profit ASC
LIMIT 10;
-- 8. Impact of Discount Levels on Profit
SELECT 
    CASE 
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.2 THEN 'Low Discount (0-20%)'
        ELSE 'High Discount (>20%)'
    END AS Discount_Level,
    COUNT(*) AS Order_Count,
    ROUND(SUM(Sales), 0) AS Total_Sales,
    ROUND(SUM(Profit), 0) AS Total_Profit,
    ROUND(AVG(Profit), 2) AS Avg_Profit_Per_Item
FROM superstore
GROUP BY Discount_Level
ORDER BY Total_Profit DESC;
-- 9. Performance by Region and Segment
SELECT 
    Region,
    Segment,
    ROUND(SUM(Sales), 0) AS Sales,
    ROUND(SUM(Profit), 0) AS Profit,
    ROUND(AVG(Discount), 3) AS Avg_Discount
FROM superstore
GROUP BY Region, Segment
ORDER BY Profit DESC;
-- 10. Best and Worst Performing Regions
SELECT 
    Region,
    ROUND(SUM(Profit), 0) AS Total_Profit
FROM superstore
GROUP BY Region
ORDER BY Total_Profit DESC;

-- 11. Top 10 Most Valuable Customers
SELECT 
    "Customer Name",
    COUNT(DISTINCT "Order ID") AS Total_Orders,
    ROUND(SUM(Sales), 0) AS Total_Sales,
    ROUND(SUM(Profit), 0) AS Total_Profit
FROM superstore
GROUP BY "Customer Name"
ORDER BY Total_Profit DESC
LIMIT 10;
-- 12. Shipping Mode Performance
SELECT 
    "Ship Mode",
    COUNT(*) AS Total_Orders,
    ROUND(AVG("Shipping Delay"), 1) AS Avg_Delay_Days,
    ROUND(SUM(Profit), 0) AS Total_Profit
FROM superstore
GROUP BY "Ship Mode"
ORDER BY Total_Profit DESC;
-- 13. Monthly Growth Rate (%) using Window Function
WITH monthly AS (
    SELECT 
        YearMonth,
        SUM(Sales) AS Monthly_Sales
    FROM superstore
    GROUP BY YearMonth
)
SELECT 
    YearMonth,
    ROUND(Monthly_Sales, 0) AS Sales,
    ROUND(
        (Monthly_Sales - LAG(Monthly_Sales) OVER (ORDER BY YearMonth)) / 
        LAG(Monthly_Sales) OVER (ORDER BY YearMonth) * 100, 2
    ) AS Growth_Percent
FROM monthly
ORDER BY YearMonth;
-- 15. Products with Highest Discount but Negative Profit
SELECT 
    "Product Name",
    "Sub-Category",
    AVG(Discount) AS Avg_Discount,
    ROUND(SUM(Profit), 0) AS Total_Profit
FROM superstore
GROUP BY "Product Name", "Sub-Category"
HAVING AVG(Discount) > 0.3 AND SUM(Profit) < 0
ORDER BY Total_Profit ASC
LIMIT 15;

-- 5. Profit by Sub-Category (very important — Furniture sub-cats often drag profit down)
SELECT 
    "Sub-Category",
    ROUND(SUM(Sales), 0) AS Sales,
    ROUND(SUM(Profit), 0) AS Profit,
    ROUND(SUM(Profit)/SUM(Sales) * 100, 2) AS Profit_Margin
FROM superstore
GROUP BY "Sub-Category"
ORDER BY Profit DESC;

-- 14. Year-over-Year Sales and Profit Growth
WITH yearly AS (
    SELECT 
        Year,
        SUM(Sales) AS Sales,
        SUM(Profit) AS Profit
    FROM superstore
    GROUP BY Year
)
SELECT 
    Year,
    ROUND(Sales, 0) AS Sales,
    ROUND(Profit, 0) AS Profit,
    ROUND(
        (Sales - LAG(Sales) OVER (ORDER BY Year)) / 
        LAG(Sales) OVER (ORDER BY Year) * 100, 2
    ) AS YoY_Sales_Growth_Percent,
    ROUND(
        (Profit - LAG(Profit) OVER (ORDER BY Year)) / 
        LAG(Profit) OVER (ORDER BY Year) * 100, 2
    ) AS YoY_Profit_Growth_Percent
FROM yearly
ORDER BY Year;

-- 16. Customer Segmentation by Profitability (RFM-like: Recency, Frequency, Monetary)
SELECT 
    "Customer Name",
    COUNT(DISTINCT "Order ID") AS Order_Count,
    ROUND(SUM(Sales), 0) AS Total_Sales,
    ROUND(SUM(Profit), 0) AS Total_Profit,
    MAX("Order Date") AS Last_Order_Date,
    ROUND(SUM(Profit) / COUNT(DISTINCT "Order ID"), 0) AS Avg_Profit_Per_Order
FROM superstore
GROUP BY "Customer Name"
ORDER BY Total_Profit DESC
LIMIT 20;

-- 17. Correlation between Discount and Profit (average discount by profit bucket)
SELECT 
    CASE 
        WHEN Profit >= 100 THEN 'High Profit (>=100)'
        WHEN Profit >= 0 THEN 'Low Profit (0-99)'
        WHEN Profit >= -50 THEN 'Small Loss (-1 to -50)'
        ELSE 'Large Loss (<-50)'
    END AS Profit_Bucket,
    COUNT(*) AS Order_Line_Count,
    ROUND(AVG(Discount), 3) AS Avg_Discount,
    ROUND(AVG(Sales), 0) AS Avg_Sales
FROM superstore
GROUP BY Profit_Bucket
ORDER BY 
    CASE Profit_Bucket
        WHEN 'High Profit (>=100)' THEN 1
        WHEN 'Low Profit (0-99)' THEN 2
        WHEN 'Small Loss (-1 to -50)' THEN 3
        ELSE 4
    END;

-- 18. Top 5 Products per Category by Profit
WITH ranked_products AS (
    SELECT 
        Category,
        "Product Name",
        ROUND(SUM(Profit), 0) AS Total_Profit,
        ROW_NUMBER() OVER (PARTITION BY Category ORDER BY SUM(Profit) DESC) AS rank_profit
    FROM superstore
    GROUP BY Category, "Product Name"
)
SELECT 
    Category,
    "Product Name",
    Total_Profit
FROM ranked_products
WHERE rank_profit <= 5
ORDER BY Category, rank_profit;

-- 19. Regional Performance with Market Share
SELECT 
    Region,
    ROUND(SUM(Sales), 0) AS Regional_Sales,
    ROUND(SUM(Profit), 0) AS Regional_Profit,
    ROUND(SUM(Sales) / (SELECT SUM(Sales) FROM superstore) * 100, 2) AS Sales_Market_Share_Percent,
    ROUND(SUM(Profit) / (SELECT SUM(Profit) FROM superstore) * 100, 2) AS Profit_Market_Share_Percent
FROM superstore
GROUP BY Region
ORDER BY Regional_Profit DESC;

-- 20. Seasonal Pattern: Monthly Sales as % of Yearly Average
WITH monthly AS (
    SELECT 
        Year,
        YearMonth,
        SUM(Sales) AS Monthly_Sales
    FROM superstore
    GROUP BY Year, YearMonth
),
yearly_avg AS (
    SELECT 
        Year,
        AVG(Monthly_Sales) AS Avg_Monthly_Sales
    FROM monthly
    GROUP BY Year
)
SELECT 
    m.YearMonth,
    ROUND(m.Monthly_Sales, 0) AS Sales,
    ROUND(m.Monthly_Sales / y.Avg_Monthly_Sales * 100, 1) AS Percent_of_Yearly_Monthly_Avg
FROM monthly m
JOIN yearly_avg y ON m.Year = y.Year
ORDER BY m.YearMonth;




