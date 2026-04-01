-- =========================================
-- Quality Checks – Gold Views (Minimal)
-- =========================================

-- 🔹 1. Check NULL keys (critical)
SELECT * 
FROM gold.fact_sales
WHERE product_key IS NULL 
   OR customer_key IS NULL;


-- 🔹 2. Check duplicate records
SELECT order_number, COUNT(*) 
FROM gold.fact_sales
GROUP BY order_number
HAVING COUNT(*) > 1;


-- 🔹 3. Check negative / invalid values
SELECT * 
FROM gold.fact_sales
WHERE sales_amount <= 0 
   OR quantity <= 0 
   OR price <= 0;


-- 🔹 4. Validate date logic
SELECT * 
FROM gold.fact_sales
WHERE order_date > shipping_date 
   OR shipping_date > due_date;
