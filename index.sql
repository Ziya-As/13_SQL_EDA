-- Create tables for customers, products, and sales
CREATE TABLE
  dim_customers (
    customer_key int,
    customer_id int,
    customer_number varchar(50),
    first_name varchar(50),
    last_name varchar(50),
    country varchar(50),
    marital_status varchar(50),
    gender varchar(50),
    birthdate date,
    create_date date
  );

CREATE TABLE
  dim_products (
    product_key int,
    product_id int,
    product_number varchar(50),
    product_name varchar(50),
    category_id varchar(50),
    category varchar(50),
    subcategory varchar(50),
    maintenance varchar(50),
    cost int,
    product_line varchar(50),
    start_date date
  );

CREATE TABLE
  fact_sales (
    order_number varchar(50),
    product_key int,
    customer_key int,
    order_date date,
    shipping_date date,
    due_date date,
    sales_amount int,
    quantity int,
    price int
  );

-- Copy the data from csv files to the tables
COPY dim_customers (
  customer_key,
  customer_id,
  customer_number,
  first_name,
  last_name,
  country,
  marital_status,
  gender,
  birthdate,
  create_date
)
FROM
  'C:\gold.dim_customers.csv' DELIMITER ',' CSV HEADER;

COPY dim_products (
  product_key,
  product_id,
  product_number,
  product_name,
  category_id,
  category,
  subcategory,
  maintenance,
  cost,
  product_line,
  start_date
)
FROM
  'C:\gold.dim_products.csv' DELIMITER ',' CSV HEADER;

COPY fact_sales (
  order_number,
  product_key,
  customer_key,
  order_date,
  shipping_date,
  due_date,
  sales_amount,
  quantity,
  price
)
FROM
  'C:\gold.fact_sales.csv' DELIMITER ',' CSV HEADER;

-- Review the tables
SELECT
  *
FROM
  dim_customers;

SELECT
  *
FROM
  dim_products;

SELECT
  *
FROM
  fact_sales;

-- Database Exploration
-- 
-- Explore all tables in the database
SELECT
  *
FROM
  INFORMATION_SCHEMA.TABLES;

-- Explore all the user-created tables in the database
SELECT
  *
FROM
  INFORMATION_SCHEMA.TABLES
WHERE
  table_schema = 'public';

-- Explore all columns in the database
SELECT
  *
FROM
  INFORMATION_SCHEMA.COLUMNS;

-- Explore all columns in specific tables
SELECT
  *
FROM
  INFORMATION_SCHEMA.COLUMNS
WHERE
  table_schema = 'public'
ORDER BY
  table_name,
  column_name;

-- Dimension Exploration
-- 
-- Explore all countries our customers come from
SELECT DISTINCT
  country
FROM
  dim_customers;

-- Explore all categories of our products
SELECT DISTINCT
  category
FROM
  dim_products
ORDER BY
  1;

SELECT DISTINCT
  category,
  subcategory
FROM
  dim_products
ORDER BY
  1,
  2;

SELECT DISTINCT
  category,
  subcategory,
  product_name
FROM
  dim_products
ORDER BY
  1,
  2,
  3;

-- Date Exploration
-- Identify the earliest and latest dates (boundaries)
-- Understand the scope of data and the timespan
-- 
-- Find the date of the first and last order
SELECT
  MIN(ORDER_DATE) FIRST_ORDER_DATE,
  MAX(ORDER_DATE) LAST_ORDER_DATE,
  EXTRACT(
    YEAR
    FROM
      AGE (MAX(ORDER_DATE), MIN(ORDER_DATE))
  ) * 12 + EXTRACT(
    MONTH
    FROM
      JUSTIFY_DAYS (AGE (MAX(ORDER_DATE), MIN(ORDER_DATE)))
  ) ORDER_RANGE_MONTH
FROM
  FACT_SALES;

-- Find the youngest and oldest customer
SELECT
  MIN(birthdate) oldest_birthdate,
  EXTRACT(
    YEAR
    FROM
      AGE (MIN(birthdate))
  ) oldest_age,
  MAX(birthdate) youngest_birthdate,
  EXTRACT(
    YEAR
    FROM
      AGE (MAX(birthdate))
  ) youngest_age
FROM
  dim_customers;

-- Measures Exploration
-- 
-- Find the total sales
SELECT
  SUM(sales_amount) total_sales
FROM
  fact_sales;

-- Find how many items are sold
SELECT
  SUM(quantity) total_quantity
FROM
  fact_sales;

-- Find the average selling price
SELECT
  ROUND(AVG(price), 0) avg_price
FROM
  fact_sales;

-- Find the total number of orders
SELECT
  count(order_number) total_orders
FROM
  fact_sales;

SELECT
  count(DISTINCT order_number) total_orders
FROM
  fact_sales;

-- Find the total number of products
SELECT
  COUNT(product_key) total_products
FROM
  dim_products;

SELECT
  COUNT(DISTINCT product_key) total_products
FROM
  dim_products;

-- Find the total number of customers
SELECT
  COUNT(customer_key) total_customers
FROM
  dim_customers;

-- Find the total number of customers that have placed an order
SELECT
  COUNT(DISTINCT customer_key) total_customers
FROM
  fact_sales;

-- Generate a report that shows all key metrics of the business
SELECT
  'Total Sales' measure_name,
  SUM(sales_amount) measure_value
FROM
  fact_sales
UNION ALL
SELECT
  'Total Quantity' measure_name,
  SUM(quantity) measure_value
FROM
  fact_sales
UNION ALL
SELECT
  'Average Price' measure_name,
  ROUND(AVG(price), 0) measure_value
FROM
  fact_sales
UNION ALL
SELECT
  'Total Nr. Orders' measure_name,
  count(DISTINCT order_number) measure_value
FROM
  fact_sales
UNION ALL
SELECT
  'Total Nr. Products' measure_name,
  COUNT(product_key) measure_value
FROM
  dim_products
UNION ALL
SELECT
  'Total Nr. Customers' measure_name,
  COUNT(customer_key) measure_value
FROM
  dim_customers;

-- Magnitude Analysis 
-- compare the measure values of different dimensions of the data
-- helps to understand the importance of different dimensions
-- 
-- Find total customers by countries
SELECT
  country,
  COUNT(customer_key) total_customers
FROM
  dim_customers
GROUP BY
  country
ORDER BY
  2 DESC;

-- Find total customers by gender
SELECT
  gender,
  COUNT(customer_key) total_customers
FROM
  dim_customers
GROUP BY
  gender
ORDER BY
  2 DESC;

-- Find total products by category
SELECT
  category,
  COUNT(product_key) total_products
FROM
  dim_products
GROUP BY
  category
ORDER BY
  2 DESC;

-- What is the average costs in each category?
SELECT
  category,
  ROUND(AVG(cost), 0) avg_cost
FROM
  dim_products
GROUP BY
  category
ORDER BY
  2 DESC;

-- What is the total revenue generated for each category?
SELECT
  p.category,
  SUM(f.sales_amount) total_revenue
FROM
  fact_sales f
  LEFT JOIN dim_products p ON p.product_key = f.product_key
GROUP BY
  p.category
ORDER BY
  2 DESC;

-- Find total revenue generated by each customer
SELECT
  c.customer_key,
  c.first_name,
  c.last_name,
  SUM(f.sales_amount) total_revenue
FROM
  fact_sales f
  LEFT JOIN dim_customers c ON c.customer_key = f.customer_key
GROUP BY
  c.customer_key,
  c.first_name,
  c.last_name
ORDER BY
  4 DESC;

-- What is the distribution of sold items across countries?
SELECT
  c.country,
  SUM(f.quantity) total_sold_items
FROM
  fact_sales f
  LEFT JOIN dim_customers c ON c.customer_key = f.customer_key
GROUP BY
  c.country
ORDER BY
  2 DESC;

-- Ranking Analysis
-- 
-- Which 5 products generate the highest revenue?
SELECT
  p.product_name,
  SUM(f.sales_amount) total_revenue
FROM
  fact_sales f
  LEFT JOIN dim_products p ON p.product_key = f.product_key
GROUP BY
  p.product_name
ORDER BY
  2 DESC
FETCH FIRST
  5 ROWS ONLY;

-- Using a Window function and a subquery to answer the same question
SELECT
  *
FROM
  (
    SELECT
      p.product_name,
      SUM(f.sales_amount) total_revenue,
      ROW_NUMBER() OVER (
        ORDER BY
          SUM(f.sales_amount) DESC
      ) product_rank
    FROM
      fact_sales f
      LEFT JOIN dim_products p ON p.product_key = f.product_key
    GROUP BY
      p.product_name
  ) t
WHERE
  t.product_rank <= 5;

-- Which 5 products generate the lowest revenue?
SELECT
  p.product_name,
  SUM(f.sales_amount) total_revenue
FROM
  fact_sales f
  LEFT JOIN dim_products p ON p.product_key = f.product_key
GROUP BY
  p.product_name
ORDER BY
  2 ASC
FETCH FIRST
  5 ROWS ONLY;

-- Which 5 subcategories generate the highest revenue?
SELECT
  p.subcategory,
  SUM(f.sales_amount) total_revenue
FROM
  fact_sales f
  LEFT JOIN dim_products p ON p.product_key = f.product_key
GROUP BY
  p.subcategory
ORDER BY
  2 DESC
FETCH FIRST
  5 ROWS ONLY;

-- Find the top 10 customers who have generated the highest revenue
SELECT
  c.customer_key,
  c.first_name,
  c.last_name,
  SUM(f.sales_amount) total_revenue
FROM
  fact_sales f
  LEFT JOIN dim_customers c ON c.customer_key = f.customer_key
GROUP BY
  c.customer_key,
  c.first_name,
  c.last_name
ORDER BY
  4 DESC
FETCH FIRST
  10 ROWS ONLY;

-- The 3 customers with the fewest orders placed
SELECT
  c.customer_key,
  c.first_name,
  c.last_name,
  COUNT(DISTINCT f.order_number) total_orders
FROM
  fact_sales f
  LEFT JOIN dim_customers c ON c.customer_key = f.customer_key
GROUP BY
  c.customer_key,
  c.first_name,
  c.last_name
ORDER BY
  4 ASC
FETCH FIRST
  3 ROWS ONLY;