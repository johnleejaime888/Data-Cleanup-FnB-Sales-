
# Checking Duplicate records

WITH duplicateCTE AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY transaction_id) as row_num
FROM sales_staging
)
SELECT * FROM duplicateCTE where row_num > 1;

**Note**: The UPDATE and DELETE operations are not available within a CTE. Therefore, I created a new staging table with an additional column called row_num.

CREATE TABLE sales_staging2
like sales_staging;

ALTER TABLE sales_staging2
ADD COLUMN row_num int;

INSERT INTO sales_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY transaction_id) as row_num
FROM sales_staging;

SELECT * FROM sales_staging2 where row_num > 1;

DELETE FROM sales_staging2 where row_num > 1;


# Standardizing Data

SELECT DISTINCT(transaction_date) FROM sales_staging2 ORDER BY transaction_date;

SELECT DISTINCT(branch) FROM sales_staging2 ORDER BY branch;

SELECT branch, TRIM(branch) FROM sales_staging2;

UPDATE sales_staging2 SET branch = TRIM(branch);

SELECT DISTINCT(product) FROM sales_staging2 ORDER BY product; 

SELECT DISTINCT(category) FROM sales_staging2 ORDER BY category;

SELECT DISTINCT product, category FROM sales_staging2 ORDER BY product;

SELECT product, MAX(category) AS category FROM sales_staging2 WHERE category <> '' AND category IS NOT NULL GROUP BY product;

UPDATE sales_staging2 t1
JOIN (
	SELECT product, category FROM sales_staging2 WHERE category <> '' OR category IS NULL
) t2 ON t1.product = t2.product SET t1.category = t2.category WHERE t1.category = '' OR t1.category IS NULL;

SELECT DISTINCT(payment_method) FROM sales_staging2 ORDER BY payment_method;

SELECT payment_method, TRIM(payment_method) FROM sales_staging2;

UPDATE sales_staging2 SET payment_method = TRIM(payment_method);

SELECT * FROM sales_staging2 WHERE payment_method LIKE 'G%';

UPDATE sales_staging2 SET payment_method = 'GCash' WHERE payment_method LIKE 'G%';

# Below are examples of data inconsistencies that need to be cleaned and standardized.
- Typos
- Extra Space
- Missing Value
- Incorrect Data Format

<img width="184" height="212" alt="image" src="https://github.com/user-attachments/assets/6f210cb3-29cf-4137-a06c-a894dbc6ba06" />
<img width="141" height="180" alt="image" src="https://github.com/user-attachments/assets/14a03cf1-443b-4caa-8351-b80279efd8b8" />
<img width="295" height="187" alt="image" src="https://github.com/user-attachments/assets/810aa43c-01fe-4cd5-8fed-12e6e1f01163" />

# Validate Quantity, Unit Price, Total Amount

SELECT * FROM sales_staging2 where quantity < 1;

WITH correct_qty AS (
SELECT *,
ROUND(total_amount / (unit_price * (1 - discount))) AS correct_quantity
FROM sales_staging2
)
SELECT * FROM correct_qty where quantity < 1;

SELECT * FROM sales_staging3;

SELECT * FROM sales_staging3 WHERE quantity < 1;

UPDATE sales_staging3 SET quantity = correct_quantity where quantity < 1;

SELECT DISTINCT product, unit_price FROM sales_staging3 ORDER BY product;

SELECT product, MAX(unit_price) AS max_unit_price FROM sales_staging3 GROUP BY product ORDER BY product ASC;

SELECT * FROM sales_staging3 where unit_price <= 0 ;

UPDATE sales_staging3 t1
JOIN (
SELECT product, MAX(unit_price)AS max_unit_price FROM sales_staging3 WHERE unit_price > 0 GROUP BY product
) t2 ON t1.product = t2.product SET t1.unit_price = t2.max_unit_price where t1.unit_price <= 0 ;


SELECT *,
ROUND(quantity * (unit_price * (1 - discount)), 2) AS correct_total_amount
FROM sales_staging3;

WITH remarks AS (
SELECT *,
	CASE
		WHEN total_amount = correct_total_amount THEN 'MATCHED'
		ELSE 'NOT MATCHED'
	END AS match_status
FROM sales_staging4
)
SELECT * FROM remarks where match_status = 'NOT MATCHED';

SELECT * FROM CLEANED WHERE match_status = 'NOT MATCHED';

UPDATE cleaned SET total_amount = correct_total_amount, match_status = 'MATCHED' where match_status = 'NOT MATCHED';

SELECT * FROM cleaned;

**AFTER UPDATE**

<img width="321" height="151" alt="image" src="https://github.com/user-attachments/assets/3248c061-e383-4a01-bfec-61daf27d427c" />



**MySQL Formula:**
SELECT, WHERE, GROUP BY, ORDER BY,
CASE, NULLIF, TRIM,
ALTER TABLE, UPDATE, DELETE, CTEs, JOINs,
ROW_NUMBER(), Aggregate functions, Window Function.
