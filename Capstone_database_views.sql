CREATE OR REPLACE VIEW sales_analysis AS
SELECT
  CAST(DATE_FORMAT(o.created_at, '%Y-%m-01') AS DATE) AS month_start,
  SUM(oi.sale_price)                     AS total_sales,
  COUNT(DISTINCT o.order_id)             AS total_orders,
  COUNT(DISTINCT o.user_id)              AS customer_count
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month_start
ORDER BY month_start;


--------
CREATE OR REPLACE VIEW sales_by_country AS
SELECT
  COALESCE(u.country, 'Unknown') AS country,
  SUM(oi.sale_price) AS total_sales
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY u.country
ORDER BY total_sales DESC;

--------
CREATE OR REPLACE VIEW gender_analysis AS
SELECT
  COALESCE(u.gender,'Unknown') AS gender,
  SUM(oi.sale_price) AS total_revenue,
  COUNT(oi.id) AS total_items_purchased,
  COUNT(DISTINCT o.order_id) AS total_orders
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY gender
ORDER BY total_revenue DESC;

--------
CREATE OR REPLACE VIEW age_distribution AS
SELECT
  CASE
    WHEN u.age IS NULL              THEN 'Unknown'
    WHEN u.age <= 12                THEN 'Kids'
    WHEN u.age BETWEEN 13 AND 19    THEN 'Teenager'
    WHEN u.age BETWEEN 20 AND 55    THEN 'Adult'
    ELSE 'Senior'
  END AS age_group,
  COUNT(DISTINCT u.id) AS customer_count,
  SUM(CASE WHEN o.order_id IS NOT NULL THEN 1 ELSE 0 END) AS order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY age_group
ORDER BY FIELD(age_group,'Kids','Teenager','Adult','Senior','Unknown');

--------
CREATE OR REPLACE VIEW top_brands AS
SELECT
  COALESCE(p.brand,'Unknown') AS brand,
  SUM(oi.sale_price) AS total_sales,
  COUNT(oi.id) AS quantity_sold
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.brand
ORDER BY total_sales DESC
LIMIT 10;

--------
CREATE OR REPLACE VIEW top_products AS
SELECT
  p.id AS product_id,
  p.name AS product_name,
  SUM(oi.sale_price) AS total_sales,
  COUNT(oi.id) AS quantity_sold
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.id, p.name
ORDER BY total_sales DESC
LIMIT 10;

--------
CREATE OR REPLACE VIEW loyalty_top5_germany_female AS
SELECT
  u.id AS customer_id,
  CONCAT(u.first_name,' ',u.last_name) AS customer_name,
  u.email,
  SUM(oi.sale_price) AS total_revenue,
  COUNT(oi.id) AS total_items
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE (u.country LIKE '%Ger%' OR u.country = 'Germany')
  AND (u.gender LIKE 'F%' OR u.gender = 'Female')
  AND p.brand LIKE '%Calvin%'
GROUP BY u.id, customer_name, u.email
ORDER BY total_revenue DESC
LIMIT 5;

--------
SELECT DATE(MAX(created_at)) AS max_order_date FROM orders;

DESCRIBE sales_analysis;







