/*==============================================================
 DATA VALIDATION - ALL SILVER TABLES

🧾 PURPOSE:
Validate data quality after ETL load from BRONZE → SILVER

 EXPECTATION:
All queries should return ZERO rows
==============================================================*/


/*==============================================================
 1. crm_cust_info
==============================================================*/

-- NULL Customer ID
SELECT * 
FROM silver.crm_cust_info
WHERE cst_id IS NULL;

-- Duplicate Customer ID
SELECT cst_id, COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- Untrimmed First Name
SELECT cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Untrimmed Last Name
SELECT cst_lastname 
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Invalid Gender
SELECT cst_gndr 
FROM silver.crm_cust_info
WHERE cst_gndr NOT IN ('Male','Female','N/A');


/*==============================================================
 2. crm_prd_info
==============================================================*/

-- NULL Product ID
SELECT *
FROM silver.crm_prd_info
WHERE prd_id IS NULL;

-- Duplicate Product ID
SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

-- Negative Cost
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0;

-- Invalid Product Line
SELECT prd_line
FROM silver.crm_prd_info
WHERE prd_line NOT IN ('Mountain','Road','Touring','Other_sales','N/A');


/*==============================================================
 3. crm_sales_details
==============================================================*/

-- NULL Customer ID
SELECT *
FROM silver.crm_sales_details
WHERE sls_cust_id IS NULL;

-- NULL Product Key
SELECT *
FROM silver.crm_sales_details
WHERE sls_prd_key IS NULL;

-- Negative or Zero Sales
SELECT *
FROM silver.crm_sales_details
WHERE sls_sales <= 0;

-- Invalid Quantity
SELECT *
FROM silver.crm_sales_details
WHERE sls_quantity <= 0;

-- Price Issues
SELECT *
FROM silver.crm_sales_details
WHERE sls_price <= 0;

-- Invalid Dates
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL;


/*==============================================================
 4. erp_cust_az12
==============================================================*/

-- NULL Customer ID
SELECT *
FROM silver.erp_cust_az12
WHERE cid IS NULL;

-- Invalid Gender
SELECT gen
FROM silver.erp_cust_az12
WHERE gen NOT IN ('Male','Female','N/A');

-- Future Birth Date
SELECT *
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();


/*==============================================================
 5. erp_loc_a101
==============================================================*/

-- NULL Customer ID
SELECT *
FROM silver.erp_loc_a101
WHERE cid IS NULL;

-- NULL Country
SELECT *
FROM silver.erp_loc_a101
WHERE cntry IS NULL;

-- Unclean Country (spaces)
SELECT cntry
FROM silver.erp_loc_a101
WHERE cntry != TRIM(cntry);


/*==============================================================
 6. erp_px_cat_g1v2
==============================================================*/

-- NULL ID
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE id IS NULL;

-- Duplicate ID
SELECT id, COUNT(*)
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1;

-- NULL Category
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat IS NULL;
