# In this stage, I checked the dataset for duplicate records, identified and removed unnecessary duplicates, and standardized inconsistent data formats and values. 
# I also validated the data to improve its accuracy, consistency, and reliability before proceeding with data analysis and visualization.

# Formula used: CTE Function, Windows Function, JOINs, DISTINCT, SELECT, WHERE, UPDATE and DELETE

# Checking Dulicates


WITH duplicateT1 AS(
SELECT *,
ROW_NUMBER () OVER(PARTITION BY transaction_id) AS row_num
FROM staging1
)
SELECT * FROM duplicateT1 WHERE row_num > 1;

CREATE TABLE staging2
LIKE staging1;

ALTER TABLE staging2
ADD COLUMN row_num INT;

INSERT INTO staging2
SELECT *,
ROW_NUMBER () OVER(PARTITION BY transaction_id) AS row_num
FROM staging1;

SELECT * FROM staging2 WHERE row_num > 1;

DELETE FROM staging2 WHERE row_num > 1;

SELECT * FROM staging2;


# Standardizing Data

#

SELECT DISTINCT (branch) FROM staging2;

SELECT DISTINCT (branch), TRIM(branch) FROM staging2;

UPDATE staging2 SET branch = TRIM(branch);

SELECT * FROM staging2;

SELECT distinct (category) FROM staging2;

SELECT * FROM staging2 where category = 'nan';

UPDATE staging2 SET category = 'Beverage' WHERE category = 'nan';

SELECT * FROM staging2 WHERE product_name = 'Soft Drink';

SELECT * FROM staging2 where category='';

SELECT DISTINCT product_name, category FROM staging2 WHERE category <> '';

UPDATE staging2 t1
JOIN (
	SELECT DISTINCT product_name, category FROM staging2 WHERE category <> ''
) t2 ON t1.product_name = t2.product_name SET t1.category = t2.category;

SELECT DISTINCT(product_name) FROM staging2;

SELECT DISTINCT (payment_method) FROM staging2;

SELECT * FROM staging2 where payment_method = '';

UPDATE staging2 SET payment_method = 'Other' where payment_method = '';

SELECT DISTINCT (customer_type) FROM staging2;

SELECT * FROM staging2 where customer_type = '';

UPDATE staging2 SET customer_type = 'Other' where customer_type = '';

SELECT * FROM staging2;


# Validate Quantity, Total Discount Amount and Total Amount


SELECT * FROM staging2 WHERE quantity < 1;

DELETE FROM staging2 WHERE quantity < 1;

SELECT DISTINCT product_name, unit_price FROM staging2 order by product_name ASC;

WITH CDA AS(
SELECT DISTINCT discount_amount,
round(unit_price * quantity * discount_pct, 2) AS correct_discount_amount
FROM staging2
)
SELECT * FROM cda WHERE discount_amount <> correct_discount_amount;

WITH CTA AS(
SELECT *,
round(unit_price * quantity - discount_amount, 2) AS correct_total_amount
FROM staging2
)
SELECT total_amount, correct_total_amount FROM CTA WHERE total_amount <> correct_total_amount;








