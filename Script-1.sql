--Checking the data
Select * from TRANSACTION_TAKEHOME

Select * from PRODUCTS_TAKEHOME


Select * from USER_TAKEHOME

--Combining the total sales
with result AS (
SELECT *, row_number() over(partition by TRANSACTION_TAKEHOME.RECEIPT_ID, TRANSACTION_TAKEHOME.BARCODE order by TRANSACTION_TAKEHOME.RECEIPT_ID  ) as res
FROM TRANSACTION_TAKEHOME
)

Select *, MAX(res) from result
group by RECEIPT_ID



--1. Top 5 brands by receipts scanned among users 21 and over
WITH UserAge AS (
    SELECT ID, 
           (STRFTIME('%Y', tt.SCAN_DATE) - STRFTIME('%Y', ut.BIRTH_DATE)) AS AGE
    FROM USER_TAKEHOME ut
    JOIN TRANSACTION_TAKEHOME tt ON ut.ID = tt.USER_ID
    WHERE (STRFTIME('%Y', tt.SCAN_DATE) - STRFTIME('%Y', ut.BIRTH_DATE)) >= 21
)
SELECT pt.BRAND, COUNT(tt.RECEIPT_ID) AS RECEIPT_COUNT
FROM TRANSACTION_TAKEHOME tt
JOIN UserAge ua ON tt.USER_ID = ua.ID
JOIN PRODUCTS_TAKEHOME pt ON tt.BARCODE = pt.BARCODE
WHERE pt.BRAND IS NOT NULL AND pt.BRAND <> ''
GROUP BY pt.BRAND
ORDER BY RECEIPT_COUNT DESC
LIMIT 5;


--2. Top 5 brands by sales among users with accounts for at least 6 months
WITH ActiveUsers AS (
    SELECT ID 
    FROM USER_TAKEHOME 
    WHERE CREATED_DATE <= DATE('now', '-6 months')
)
SELECT pt.BRAND, SUM(tt.FINAL_SALE) AS TOTAL_SALES
FROM TRANSACTION_TAKEHOME tt
JOIN ActiveUsers au ON tt.USER_ID = au.ID
JOIN PRODUCTS_TAKEHOME pt ON tt.BARCODE = pt.BARCODE
WHERE pt.BRAND IS NOT NULL AND pt.BRAND <> ''
GROUP BY pt.BRAND
ORDER BY TOTAL_SALES DESC
LIMIT 5;


------------------------------------------------------------------------------------

-- Which is the leading brand in the Dips & Salsa category?
SELECT pt.BRAND, SUM(tt.FINAL_SALE) AS TOTAL_SALES
FROM TRANSACTION_TAKEHOME AS tt
JOIN PRODUCTS_TAKEHOME AS pt ON tt.BARCODE = pt.BARCODE
WHERE pt.CATEGORY_2 LIKE 'Dips & Salsa' and pt.BRAND IS NOT NULL AND pt.BRAND <> ''
GROUP BY pt.BRAND
ORDER BY total_sales DESC
Limit 1;







