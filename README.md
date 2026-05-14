# Retail_Sales_and_Customer_Insights_Analysis_SQL

This SQL script covers some fantastic ground. The way you utilized window functions like `LAG()` and Common Table Expressions (CTEs) for purchase patterns is exactly the kind of advanced query logic that stands out to hiring teams.

Here is a clean, structured README you can drop directly into your GitHub repository to showcase the business value of this code.

---

# Retail Operations & Customer Analytics

## 📌 Project Overview

This project is an end-to-end SQL database simulation designed to extract actionable business insights from retail data. The script establishes a relational database from scratch, handles data cleaning (such as removing orphaned foreign key records), and executes a series of complex analytical queries divided into specific business modules.

The primary objective is to analyze sales performance, segment customer behavior, optimize inventory management, and uncover high-frequency purchase patterns using advanced SQL techniques.

## 🗄️ Database Schema

The project operates on a custom database named `Portfolio_Assignment` consisting of four primary tables linked via foreign key constraints:

* **`customers_data`**: Demographics, registration, and purchase dates.
* **`products_data`**: Product categories, pricing, and current stock levels.
* **`sales_data`**: Transactional records including units sold, discounts applied, and total revenue.
* **`inventory_data`**: Log of daily stock movements (IN/OUT).

## 📊 Key Analytical Modules

### 1. Sales Performance Analysis

* Calculated monthly revenue and total units sold.
* Analyzed the impact of discounting strategies by calculating net revenue after average monthly discounts.

### 2. Customer Behavior & Segmentation

* Identified the top 10 high-value customers by lifetime spending.
* Conducted generational cohort analysis (filtering for customers born in the 1990s) to aggregate their order histories using `GROUP_CONCAT`.
* Built a dynamic customer segmentation model using `CASE` statements to categorize users into 'Low Spender', 'Medium Spender', and 'High Spender' tiers.

### 3. Inventory & Product Management

* Designed a dynamic restocking alert system that identifies products with fewer than 10 units in stock and calculates a recommended restock quantity based on a 1.5x multiplier of average monthly sales.
* Generated net daily inventory movement reports by tracking restocking ('IN') versus sales ('OUT').
* Ranked products within their respective categories based on price.

### 4. Advanced Analytics & Modeling

* **Dynamic Pricing Simulation:** Tracked how average price fluctuations impact sales volume and total revenue over time.
* **Time-Series Purchase Patterns:** Utilized Common Table Expressions (CTEs) and the `LAG()` window function to calculate the average, minimum, and maximum days between purchases for individual customers to identify high-frequency buying behavior.

## 🛠️ Technical Skills Demonstrated

* **Database Design:** `CREATE DATABASE`, `ALTER TABLE`, Primary/Foreign Key constraints.
* **Data Cleaning:** Identifying and deleting orphaned records.
* **Aggregations & Grouping:** `SUM`, `AVG`, `COUNT`, `GROUP_CONCAT`, `COALESCE`.
* **Advanced SQL:** Window Functions (`LAG`, `DENSE_RANK`), Common Table Expressions (CTEs), Subqueries, `CASE` statement logic.
* **Date Manipulation:** `DATE_FORMAT`, `YEAR()`, `MONTH()`, time-series calculations.

## 🚀 How to Use

1. Execute the `-- Creating Database` and `Designating Primary/Foreign Keys` blocks to establish the schema.
2. Import your mock CSV data into the respective tables.
3. Run the analytical queries module by module to generate the business reports.
