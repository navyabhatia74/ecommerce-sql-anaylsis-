Create database ecomerce_analysis;
use ecomerce_analysis;
select count(*)
from products;
select count(*)
from items;
select count(*)
from payments;
SELECT SUM(payment_value)
FROM payments;

SELECT payment_type,
       COUNT(*) AS total_orders
FROM payments
GROUP BY payment_type
ORDER BY total_orders DESC;

SELECT order_id,
       SUM(payment_value) AS total_spent
FROM payments
GROUP BY order_id
ORDER BY total_spent DESC
LIMIT 10;

-- =========================================
-- CUSTOMER ANALYSIS
-- =========================================
SELECT customer_city,
       COUNT(customer_id) AS total_customers
FROM customers
GROUP BY customer_city
ORDER BY total_customers DESC
LIMIT 10;

SELECT o.customer_id,
       SUM(p.payment_value) AS total_spent
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- =========================================
-- PAYMENT ANALYSIS
-- =========================================

SELECT payment_type,
       COUNT(*) AS total_orders
FROM payments
GROUP BY payment_type
ORDER BY total_orders DESC;

SELECT AVG(payment_value)
FROM payments;

-- =========================================
-- ORDER ANALYSIS
-- =========================================

SELECT order_status,
       COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

SELECT YEAR(order_purchase_timestamp) AS year,
       MONTH(order_purchase_timestamp) AS month,
       COUNT(*) AS total_orders
FROM orders
GROUP BY year, month
ORDER BY year, month;

-- =========================================
-- PRODUCT ANALYSIS
-- =========================================

SELECT p.product_category_name,
       COUNT(i.product_id) AS total_sales
FROM items i
JOIN products p
ON i.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sales DESC
LIMIT 10;

-- =========================================
-- ORDER STATUS ANALYSIS
-- =========================================

SELECT order_status,
COUNT(*) AS total_orders,
ROUND(COUNT(*) * 100.0 /
(SELECT COUNT(*) FROM orders),2) AS percentage_share
FROM orders
GROUP BY order_status
ORDER BY percentage_share DESC;

-- =========================================
-- INNER JOIN ANALYSIS
-- =========================================

SELECT c.customer_state,
       COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;

SELECT c.customer_state,
       ROUND(AVG(p.payment_value),2) AS avg_order_value
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN payments p
ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY avg_order_value DESC;

-- =========================================
-- LEFT JOIN ANALYSIS
-- =========================================

SELECT pr.product_id,
       pr.product_category_name
FROM products pr
LEFT JOIN items i
ON pr.product_id = i.product_id
WHERE i.product_id IS NULL;

-- =========================================
-- CASE WHEN ANALYSIS
-- =========================================
SELECT o.customer_id,
       ROUND(SUM(p.payment_value),2) AS total_spent,

       CASE
            WHEN SUM(p.payment_value) > 1000 THEN 'High Value'
            WHEN SUM(p.payment_value) BETWEEN 500 AND 1000 THEN 'Medium Value'
            ELSE 'Low Value'
       END AS customer_segment
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC;


SELECT order_id,
       order_purchase_timestamp,
       order_delivered_customer_date,
       CASE
            WHEN order_delivered_customer_date <= order_estimated_delivery_date
            THEN 'On Time'
            ELSE 'Delayed'
       END AS delivery_status
FROM orders;



-- =========================================
-- ADVANCED AGGREGATIONS
-- =========================================

SELECT payment_type,
       ROUND(SUM(payment_value),2) AS total_revenue,
       ROUND(
       SUM(payment_value) * 100 /
       (SELECT SUM(payment_value) FROM payments)
       ,2) AS revenue_percentage
FROM payments
GROUP BY payment_type
ORDER BY revenue_percentage DESC;


SELECT pr.product_category_name,
       ROUND(AVG(i.freight_value),2) AS avg_freight_cost
FROM items i
JOIN products pr
ON i.product_id = pr.product_id
GROUP BY pr.product_category_name
ORDER BY avg_freight_cost DESC
LIMIT 10;

SELECT c.customer_state,
       COUNT(DISTINCT o.order_id) AS total_orders,

       ROUND(SUM(p.payment_value),2) AS total_revenue,

       ROUND(AVG(p.payment_value),2) AS avg_order_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payments p
ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


SELECT pr.product_category_name,
       ROUND(SUM(i.price),2) AS total_revenue
FROM items i
JOIN products pr
ON i.product_id = pr.product_id
GROUP BY pr.product_category_name
HAVING total_revenue >
(
    SELECT AVG(price)
    FROM items
)
ORDER BY total_revenue DESC;


SELECT YEAR(o.order_purchase_timestamp) AS year,
       MONTH(o.order_purchase_timestamp) AS month,
       ROUND(SUM(p.payment_value),2) AS monthly_revenue
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY year, month
ORDER BY year, month;


-- =========================================
-- WINDOW FUNCTIONS
-- =========================================

SELECT o.customer_id,
ROUND(SUM(p.payment_value),2) AS total_spent,
   RANK() OVER (
        ORDER BY SUM(p.payment_value) DESC
   ) AS spending_rank
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY o.customer_id;

SELECT pr.product_category_name,
   ROUND(SUM(i.price),2) AS total_revenue,
   DENSE_RANK() OVER (
        ORDER BY SUM(i.price) DESC
   ) AS revenue_rank
FROM items i
JOIN products pr
ON i.product_id = pr.product_id
GROUP BY pr.product_category_name;


SELECT order_id,
order_purchase_timestamp,
   ROW_NUMBER() OVER (
        ORDER BY order_purchase_timestamp
   ) AS row_num
FROM orders;
-- =========================================
-- CTEs (COMMON TABLE EXPRESSIONS)
-- =========================================

WITH customer_spending AS
(
SELECT o.customer_id,
ROUND(SUM(p.payment_value),2) AS total_spent
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY o.customer_id
)
SELECT *
FROM customer_spending
ORDER BY total_spent DESC
LIMIT 10;

WITH state_revenue AS
(
SELECT c.customer_state,
ROUND(SUM(p.payment_value),2) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payments p
ON o.order_id = p.order_id
GROUP BY c.customer_state
)
SELECT *
FROM state_revenue
ORDER BY total_revenue DESC;
-- =========================================
-- BUSINESS KPI ANALYSIS
-- =========================================

SELECT
ROUND(
(
COUNT(DISTINCT customer_id) -
COUNT(DISTINCT order_id)
) * 100.0 /
COUNT(DISTINCT customer_id)
,2) AS repeat_customer_rate
FROM orders;

SELECT
ROUND(
SUM(payment_value) /
COUNT(DISTINCT o.customer_id)
,2) AS avg_revenue_per_customer
FROM orders o
JOIN payments p
ON o.order_id = p.order_id;

SELECT YEAR(o.order_purchase_timestamp) AS year,
MONTH(o.order_purchase_timestamp) AS month,
   ROUND(SUM(p.payment_value),2) AS monthly_revenue
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY year, month
ORDER BY monthly_revenue DESC
LIMIT 10;

SELECT o.customer_id,
   COUNT(o.order_id) AS total_orders,
   ROUND(SUM(p.payment_value),2) AS lifetime_value
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY o.customer_id
ORDER BY lifetime_value DESC
LIMIT 10;

SELECT YEAR(order_purchase_timestamp) AS year,
MONTH(order_purchase_timestamp) AS month,
   COUNT(DISTINCT customer_id) AS new_customers
FROM orders
GROUP BY year, month
ORDER BY year, month;
