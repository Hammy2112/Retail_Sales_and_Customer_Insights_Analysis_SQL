-- Creating Database:
CREATE DATABASE Portfolio_Assignment;

USE PortfolIo_Assignment;

-- Retriving data from Tables
SELECT * FROM
    customers_data;
SELECT * FROM
    inventory_data;
    
SELECT * FROM products_data;

SELECT * FROM sales_data;

-- Designating Primary Keys
ALTER TABLE customers_data
ADD PRIMARY KEY (customer_id);

ALTER TABLE inventory_data
ADD PRIMARY KEY(movement_id);

ALTER TABLE products_data
ADD PRIMARY KEY (product_id);

ALTER TABLE sales_data
ADD PRIMARY KEY (sale_id);

-- Designating Foreign Keys

ALTER TABLE sales_data
ADD CONSTRAINT fk_sales_customer
FOREIGN KEY (customer_id)
REFERENCES customers_data(customer_id);

ALTER TABLE sales_data
ADD CONSTRAINT fk_sales_product
FOREIGN KEY (product_id)
REFERENCES products_data(product_id);

ALTER TABLE inventory_data
ADD CONSTRAINT fk_inventory_product
FOREIGN KEY (product_id)
REFERENCES products_data(product_id);

-- Checking and removing orphaned values
SELECT DISTINCT customer_id 
FROM sales_data
WHERE customer_id NOT IN (SELECT customer_id FROM customers_data);

DELETE FROM sales_data
WHERE customer_id NOT IN (SELECT customer_id FROM customers_data);

ALTER TABLE sales_data
ADD CONSTRAINT fk_sales_customer
FOREIGN KEY (customer_id)
REFERENCES customers_data(customer_id);

-- Tasks

-- Module 1: Sales Performance Analysis 
-- 1) Total Sales per Month: 
-- Calculate the total sales amount per month, including the number of units sold and the total revenue generated. 

SELECT 
    DATE_FORMAT(sale_date, '%Y''-''%m') AS per_month,
    ROUND(SUM(total_amount), 2) AS Total_sales,
    SUM(quantity_sold) AS Number_of_unit_sold,
    ROUND(SUM(total_amount * (1 - discount_applied / 100)),
            2) AS Total_revenue_generated
FROM
    sales_data
GROUP BY per_month
ORDER BY per_month;

-- 2. Average Discount per Month: 
-- Calculate the average discount applied to sales in each month and assess how discounting strategies impact total sales. 

SELECT
    YEAR(sale_date) AS year,
    MONTH(sale_date) AS month,
    AVG(discount_applied) AS average_discount,
    SUM(total_amount) AS total_sales_revenue, 
    SUM(total_amount * (discount_applied / 100)) AS total_discount_amount, 
    SUM(total_amount) - SUM(total_amount * (discount_applied / 100)) AS net_sales_revenue  -- Net revenue after discount
FROM
    sales_data
GROUP BY
    YEAR(sale_date),
    MONTH(sale_date)
ORDER BY
    year DESC, month DESC;
    

-- Module 2: Customer Behavior and Insights 

-- 3. Identify high-value customers: 
-- Which customers have spent the most on their purchases? Show their details 

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.gender,
    c.date_of_birth,
    c.registration_date,
    c.last_purchase_date,
    SUM(s.total_amount) AS total_spent  -- Total amount spent by the customer
FROM
    customers_data c
JOIN
    sales_data s ON c.customer_id = s.customer_id  
GROUP BY
    c.customer_id
ORDER BY
    total_spent DESC  
LIMIT 10;  

-- 4. Identify the oldest Customer: 
-- Find the details of customers born in the 1990s, including their total spending and specific order details. 
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.gender,
    c.date_of_birth,
    c.registration_date,
    c.last_purchase_date,
    SUM(s.total_amount) AS total_spent,  -- Total spending by the customer
    COUNT(s.sale_id) AS total_orders,  
    GROUP_CONCAT(DISTINCT s.sale_id ORDER BY s.sale_date) AS order_ids  
FROM
    customers_data c
JOIN
    sales_data s ON c.customer_id = s.customer_id  
WHERE
    c.date_of_birth BETWEEN '1990-01-01' AND '1999-12-31'  
GROUP BY
    c.customer_id
ORDER BY
    total_spent DESC;
    
-- 5. Customer Segmentation: 
-- Use SQL to create customer segments based on their total spending (e.g., Low Spenders, High Spenders). 
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.gender,
    c.date_of_birth,
    c.registration_date,
    c.last_purchase_date,
    SUM(s.total_amount) AS total_spent,  
    CASE
        WHEN SUM(s.total_amount) < 1000 THEN 'Low Spender'  -- Customers who spent less than $1000
        WHEN SUM(s.total_amount) BETWEEN 1000 AND 3999 THEN 'Medium Spender'  -- Customers who spent between $1000 and $3999
        WHEN SUM(s.total_amount) >= 4000 THEN 'High Spender'  -- Customers who spent $4000 or more
        ELSE 'Unknown'  -- In case there's no spending recorded
    END AS spending_segment  -- Categorizing customers into segments
FROM
    customers_data c
JOIN
    sales_data s ON c.customer_id = s.customer_id 
GROUP BY
    c.customer_id
ORDER BY
    total_spent DESC; 

-- Module 3: Inventory and Product Management 

-- 6. Stock Management: 
-- Write a query to find products that are running low in stock (below a threshold like 10 units) and recommend restocking amounts based on past sales performance.
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.stock_quantity,
    COALESCE(ROUND(SUM(s.quantity_sold) / COUNT(DISTINCT DATE_FORMAT(s.sale_date, '%Y-%m'))), 0) AS avg_monthly_sales, 
    CASE
        WHEN p.stock_quantity < 10 THEN ROUND((SUM(s.quantity_sold) / COUNT(DISTINCT DATE_FORMAT(s.sale_date, '%Y-%m'))) * 1.5) -- Used 1.5x avg monthly sales
        ELSE 0
    END AS recommended_restock_quantity
FROM
    products_data p
LEFT JOIN
    sales_data s ON p.product_id = s.product_id
WHERE
    p.stock_quantity < 10 
GROUP BY
    p.product_id
ORDER BY
    avg_monthly_sales DESC;

-- 7. Inventory Movements Overview: 
-- Create a report showing the daily inventory movements (restock vs. sales) for each product over a given period. 
SELECT
    p.product_id,
    p.product_name,
    i.movement_date,
    SUM(CASE WHEN i.movement_type = 'IN' THEN i.quantity_moved ELSE 0 END) AS total_restocked,  -- Total restocked on a given day
    SUM(CASE WHEN i.movement_type = 'OUT' THEN i.quantity_moved ELSE 0 END) AS total_sold,      -- Total sold on a given day
    (SUM(CASE WHEN i.movement_type = 'IN' THEN i.quantity_moved ELSE 0 END) - 
     SUM(CASE WHEN i.movement_type = 'OUT' THEN i.quantity_moved ELSE 0 END)) AS net_movement   -- Net inventory movement
FROM
    inventory_data i
JOIN
    products_data p ON i.product_id = p.product_id  
WHERE
    i.movement_date BETWEEN '2024-01-01' AND '2024-01-31'  
GROUP BY
    p.product_id, i.movement_date
ORDER BY
    i.movement_date, p.product_id;


-- 8. Rank Products:
-- Rank products in each category by their prices.
SELECT
    product_id,
    product_name,
    category,
    price,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY price DESC) AS price_rank  
FROM
    products_data
ORDER BY
    category,
    price_rank;
    
-- Module 4: Advanced Analytics 

-- 9. Average order size: 
-- What is the average order size in terms of quantity sold for each product? 
SELECT
    p.product_id,
    p.product_name,
    ROUND(AVG(s.quantity_sold), 2) AS avg_order_size  
FROM
    products_data p
JOIN
    sales_data s ON p.product_id = s.product_id  
GROUP BY
    p.product_id, p.product_name
ORDER BY
    avg_order_size DESC;  
    
-- 10. Recent Restock Product: 
-- Which products have seen the most recent restocks 
SELECT
    p.product_id,
    p.product_name,
    MAX(i.movement_date) AS last_restock_date  
FROM
    products_data p
JOIN
    inventory_data i ON p.product_id = i.product_id
WHERE
    i.movement_type = 'IN'  
GROUP BY
    p.product_id, p.product_name
ORDER BY
    last_restock_date DESC;  

-- Advanced Features:

-- Dynamic Pricing Simulation: Challenge students to analyze how price changes for products impact sales volume, revenue, and customer behavior.
SELECT 
    p.product_id,
    p.product_name,
    s.sale_date,
    AVG(p.price) AS avg_price,
    SUM(s.quantity_sold) AS total_units_sold,
    SUM(s.total_amount) AS total_revenue
FROM sales_data s
JOIN products_data p ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name, s.sale_date
ORDER BY p.product_id, s.sale_date;

-- Customer Purchase Patterns: Analyze purchase patterns using time-series data and window functions to find high-frequency buying behavior. 
WITH purchase_patterns AS (
    SELECT 
        customer_id,
        sale_date,
        LAG(sale_date) OVER (PARTITION BY customer_id ORDER BY sale_date) AS prev_purchase_date,
        sale_date - LAG(sale_date) OVER (PARTITION BY customer_id ORDER BY sale_date) AS days_between_purchases
    FROM sales_data
)
SELECT 
    customer_id,
    COUNT(*) AS total_purchases,
    AVG(days_between_purchases) AS avg_days_between_purchases,
    MIN(days_between_purchases) AS min_days_between_purchases,
    MAX(days_between_purchases) AS max_days_between_purchases
FROM purchase_patterns
GROUP BY customer_id
ORDER BY total_purchases DESC;
