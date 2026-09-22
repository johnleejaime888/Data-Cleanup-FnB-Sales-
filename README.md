
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
	SELECT product, category FROM sales_staging2 where category <> '' or category IS NULL
) t2 ON t1.product = t2.product SET t1.category = t2.category WHERE t1.category = '' OR t1.category IS NULL;

SELECT DISTINCT(payment_method) FROM sales_staging2 ORDER BY payment_method;

SELECT payment_method, TRIM(payment_method) FROM sales_staging2;

UPDATE sales_staging2 SET payment_method = TRIM(payment_method);

SELECT * FROM sales_staging2 WHERE payment_method LIKE 'G%';

UPDATE sales_staging2 SET payment_method = 'GCash' WHERE payment_method LIKE 'G%';
