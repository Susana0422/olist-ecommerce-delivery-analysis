-- Review the rows
SELECT 'orders' AS table_name, COUNT(*) AS total_rows
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'order_reviews', COUNT(*)
FROM order_reviews

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers

UNION ALL

SELECT 'customers', COUNT(*)
FROM customers;

-- Review orders table
select *
from orders
limit 5;

-- Group by order_status
select order_status, count(*) as total_orders
from orders
group by order_status
order by total_orders desc;

-- Review the date range
SELECT
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order,
    MIN(order_delivered_customer_date) AS first_delivery,
    MAX(order_delivered_customer_date) AS last_delivery
FROM orders;

-- Review score
SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

-- Missing values order delivered
SELECT
    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS missing_delivery_date,

    COUNT(*) FILTER (
        WHERE order_estimated_delivery_date IS NULL
    ) AS missing_estimated_date,

    COUNT(*) FILTER (
        WHERE order_purchase_timestamp IS NULL
    ) AS missing_purchase_date

FROM orders;

-- Missing value with order_status
SELECT
    order_status,
    COUNT(*) AS missing_delivery_dates
FROM orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY missing_delivery_dates DESC;

SELECT
    order_id,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    order_purchase_timestamp
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

/* Only use delivered order status where is not null*/

-- Review inconsistent dates
SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date
      < order_purchase_timestamp;
	  
-- check if there are estimated dates prior to the purchase
SELECT
    COUNT(*) AS invalid_delivery_dates
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date < order_purchase_timestamp;

--
SELECT
    COUNT(*) AS invalid_estimated_dates
FROM orders
WHERE order_estimated_delivery_date < order_purchase_timestamp;

-- Duplicate review

SELECT
    review_id,
    COUNT(*) AS occurrences
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

--
SELECT
    review_id,
    COUNT(*) AS occurrences,
    COUNT(DISTINCT order_id) AS different_orders,
    COUNT(DISTINCT review_score) AS different_scores
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- 
SELECT 
	order_id,
    COUNT(*) AS total_reviews
FROM order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY total_reviews DESC;

-- Invalid score
SELECT
    COUNT(*) AS invalid_reviews
FROM order_reviews
WHERE review_score NOT BETWEEN 1 AND 5
   OR review_score IS NULL;
--

SELECT COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

/*It is important to verify that the values of seller_id in the order_items 
table exist in the sellers table.*/

SELECT COUNT(*) AS orphan_sellers
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

--
SELECT COUNT(*) AS orphan_reviews
FROM order_reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

--
SELECT
    COUNT(*) AS total_review_records,
    COUNT(DISTINCT order_id) AS orders_with_reviews,
    COUNT(DISTINCT review_id) AS unique_review_ids
FROM order_reviews;


--
WITH review_by_order AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score,
        COUNT(*) AS review_count
    FROM order_reviews
    WHERE review_score BETWEEN 1 AND 5
    GROUP BY order_id
)
SELECT *
FROM review_by_order
LIMIT 10;

--

WITH review_by_order AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score,
        COUNT(*) AS review_count
    FROM order_reviews
    WHERE review_score BETWEEN 1 AND 5
    GROUP BY order_id
)
SELECT
    COUNT(*) AS total_orders_with_reviews,
    COUNT(*) FILTER (WHERE review_count > 1) AS orders_with_multiple_reviews,
    MAX(review_count) AS max_reviews_per_order
FROM review_by_order;


-- identify whether each order arrived late or on time
WITH delivery_status AS (
    SELECT
        order_id,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 'Late'
            ELSE 'On-time'
        END AS delivery_status
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)
SELECT
    delivery_status,
    COUNT(*) AS total_orders
FROM delivery_status
GROUP BY delivery_status
ORDER BY total_orders DESC;

-- 
WITH review_by_order AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score,
        COUNT(*) AS review_count
    FROM order_reviews
    WHERE review_score BETWEEN 1 AND 5
    GROUP BY order_id
),
delivery_status AS (
    SELECT
        order_id,
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 'Late'
            ELSE 'On-time'
        END AS delivery_status
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)
SELECT
    d.delivery_status,
    COUNT(*) AS total_orders,
    ROUND(AVG(r.avg_review_score), 2) AS avg_review_score
FROM delivery_status d
INNER JOIN review_by_order r
    ON d.order_id = r.order_id
GROUP BY d.delivery_status
ORDER BY avg_review_score DESC;

-- 
SELECT
    COUNT(*) AS total_single_seller_orders
FROM (
    SELECT
        order_id
    FROM order_items
    GROUP BY order_id
    HAVING COUNT(DISTINCT seller_id) = 1
) AS single_seller;

-- satisfaction with seller status

WITH review_by_order AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM order_reviews
    WHERE review_score BETWEEN 1 AND 5
    GROUP BY order_id
),

single_seller_orders AS (
    SELECT
        order_id,
        MIN(seller_id) AS seller_id
    FROM order_items
    GROUP BY order_id
    HAVING COUNT(DISTINCT seller_id) = 1
),

delivery_status AS (
    SELECT
        order_id,
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 'Late'
            ELSE 'On-time'
        END AS delivery_status
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)

SELECT
    s.seller_state,
    COUNT(*) AS total_orders,
    ROUND(AVG(r.avg_review_score), 2) AS avg_review_score
FROM delivery_status d
INNER JOIN review_by_order r
    ON d.order_id = r.order_id
INNER JOIN single_seller_orders so
    ON d.order_id = so.order_id
INNER JOIN sellers s
    ON so.seller_id = s.seller_id
WHERE d.delivery_status = 'Late'
GROUP BY s.seller_state
ORDER BY avg_review_score ASC;

--
WITH single_seller_orders AS (
    SELECT
        order_id,
        MIN(seller_id) AS seller_id
    FROM order_items
    GROUP BY order_id
    HAVING COUNT(DISTINCT seller_id) = 1
),

delivery_status AS (
    SELECT
        order_id,
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 'Late'
            ELSE 'On-time'
        END AS delivery_status
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)

SELECT
    s.seller_state,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE d.delivery_status = 'Late'
    ) AS late_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE d.delivery_status = 'Late'
        ) / COUNT(*),
        2
    ) AS late_delivery_rate
FROM delivery_status d
INNER JOIN single_seller_orders so
    ON d.order_id = so.order_id
INNER JOIN sellers s
    ON so.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY late_delivery_rate DESC;