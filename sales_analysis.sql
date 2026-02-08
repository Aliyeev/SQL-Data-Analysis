--Total Sales Amount
SELECT 
    SUM(Sales_Amount) AS total_sales
FROM sales_table;


--Total Profit Generated
SELECT 
    SUM(Profit) AS total_profit
FROM sales_table;


--Average Sales by Customer Segment
SELECT 
    Customer_Segment,
    AVG(Sales_Amount) AS avg_sales
FROM sales_table
GROUP BY Customer_Segment;


--Loss Orders Count
SELECT 
    COUNT(*) AS loss_orders
FROM sales_table
WHERE Profit < 0;


--Average Delivery Time
SELECT 
    AVG(Ship_Date - Order_Date) AS avg_delivery_days
FROM sales_table;


--Sales and Profit by Region
SELECT 
    Region,
    SUM(Sales_Amount) AS total_sales,
    SUM(Profit) AS total_profit
FROM sales_table
GROUP BY ROLLUP(Region)
ORDER BY total_sales DESC;


--Top 5 Customers by Orders
SELECT *
FROM (
    SELECT 
        c.Customer_Name,
        COUNT(s.Order_ID) AS order_count,
        SUM(s.Sales_Amount) AS total_sales,
        RANK() OVER (ORDER BY COUNT(s.Order_ID) DESC) AS order_rank
    FROM sales_table s
    JOIN customer_table c
        ON s.Customer_Name = c.Customer_Name
    GROUP BY c.Customer_Name
)
WHERE order_rank <= 5
ORDER BY order_count DESC;


--Profit Trend by Month
WITH monthly_profit AS (
    SELECT 
        EXTRACT(MONTH FROM Order_Date) AS month,
        SUM(Profit) AS total_profit
    FROM sales_table
    GROUP BY EXTRACT(MONTH FROM Order_Date)
)
SELECT 
    month,
    total_profit,
    LAG(total_profit) OVER (ORDER BY month) AS prev_month_profit,
    total_profit - LAG(total_profit) OVER (ORDER BY month) AS profit_change
FROM monthly_profit
ORDER BY month;


--Sales by Product Category
SELECT 
    p.Product_Category,
    SUM(CASE WHEN s.Discount = 0 THEN s.Sales_Amount ELSE 0 END) AS sales_no_discount,
    SUM(CASE WHEN s.Discount BETWEEN 0.01 AND 0.10 THEN s.Sales_Amount ELSE 0 END) AS sales_1_10_discount,
    SUM(CASE WHEN s.Discount > 0.10 THEN s.Sales_Amount ELSE 0 END) AS sales_above_10_discount
FROM sales_table s
JOIN product_table p
    ON s.Product_Name = p.Product_Name
GROUP BY p.Product_Category
ORDER BY p.Product_Category;


--Average Delivery Time by Shipping Mode
SELECT 
    Ship_Mode,
    AVG(Ship_Date - Order_Date) AS avg_delivery_days,
    MIN(Ship_Date - Order_Date) AS fastest_delivery,
    MAX(Ship_Date - Order_Date) AS slowest_delivery
FROM sales_table
GROUP BY Ship_Mode
ORDER BY avg_delivery_days;


--Loss Orders by State
SELECT 
    State,
    COUNT(CASE WHEN Profit < 0 THEN 1 END) AS loss_orders,
    COUNT(*) AS total_orders
FROM sales_table
GROUP BY State
ORDER BY loss_orders DESC;


--Top 3 Products by Profit
SELECT *
FROM (
    SELECT 
        Product_Name,
        SUM(Profit) AS total_profit,
        RANK() OVER (ORDER BY SUM(Profit) DESC) AS rank_product
    FROM sales_table
    GROUP BY Product_Name
)
WHERE rank_product <= 3
ORDER BY total_profit DESC;


--Monthly Sales by Customer Segment
WITH sales_summary AS (
    SELECT 
        Customer_Segment,
        EXTRACT(MONTH FROM Order_Date) AS month,
        SUM(Sales_Amount) AS total_sales
    FROM sales_table
    GROUP BY GROUPING SETS ((Customer_Segment, EXTRACT(MONTH FROM Order_Date)), (Customer_Segment), ())
)
SELECT *
FROM sales_summary
ORDER BY Customer_Segment, month;


--Profit Ratio by State
SELECT 
    State,
    SUM(Sales_Amount) AS total_sales,
    SUM(Profit) AS total_profit,
    SUM(Profit)/SUM(Sales_Amount) AS profit_ratio
FROM sales_table
GROUP BY ROLLUP(State)
ORDER BY profit_ratio DESC NULLS LAST;


--Total Sales and Profit Summary
SELECT 
    SUM(Sales_Amount) AS total_sales,
    SUM(Profit) AS total_profit,
    AVG(Sales_Amount) AS avg_sales,
    AVG(Profit) AS avg_profit
FROM sales_table;
















