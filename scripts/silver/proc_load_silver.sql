/*==============================================================
 PROCEDURE: silver.load_silver

 DESCRIPTION:
This stored procedure loads data from the BRONZE layer into the 
SILVER layer by applying data cleaning, transformation, and 
standardization rules.

 PROCESS FLOW:
1. Start batch execution timer
2. Truncate target SILVER tables (full refresh)
3. Load and transform data from BRONZE:
   - crm_cust_info → deduplication + cleaning
   - crm_prd_info → category extraction + SCD logic
   - crm_sales_details → date + sales corrections
   - erp_cust_az12 → ID + gender cleanup
   - erp_loc_a101 → country standardization
   - erp_px_cat_g1v2 → direct load
4. Track execution time for each table
5. Track total batch execution time
6. Handle errors using TRY-CATCH

 WARNING:
- This procedure uses TRUNCATE → ALL DATA WILL BE DELETED before load
- This is a FULL LOAD (not incremental)
- Do NOT run in production without backup or validation
- Ensure BRONZE tables are populated before execution

 LAYER: SILVER

==============================================================*/

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN

    ---------------------------------------------------------
    -- DECLARE VARIABLES
    ---------------------------------------------------------
    DECLARE 
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME,
        @error_message NVARCHAR(4000);

    BEGIN TRY

        ---------------------------------------------------------
        -- BATCH START
        ---------------------------------------------------------
        SET @batch_start_time = GETDATE();
        PRINT '===== SILVER LOAD START =====';

        ---------------------------------------------------------
        -- crm_cust_info
        ---------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '------crm_cust_info------';

        TRUNCATE TABLE silver.crm_cust_info;

        INSERT INTO silver.crm_cust_info(
            cst_id, cst_key, cst_firstname, cst_lastname,
            cst_marital_status, cst_gndr, cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),

            CASE 
                WHEN cst_marital_status='S' THEN 'Single'
                WHEN cst_marital_status='M' THEN 'Married'
                ELSE 'N/A'
            END,

            CASE 
                WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
                ELSE 'N/A'
            END,

            cst_create_date
        FROM (
            SELECT *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) rn
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT 'Time: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR);

        ---------------------------------------------------------
        -- crm_prd_info
        ---------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '------crm_prd_info------';

        TRUNCATE TABLE silver.crm_prd_info;

        INSERT INTO silver.crm_prd_info(
            prd_id, cat_id, prd_key, prd_nm,
            prd_cost, prd_line, prd_start_dt, prd_end_dt
        )
        SELECT 
            prd_id,
            REPLACE(SUBSTRING(prd_key,1,5),'-','_'),
            SUBSTRING(prd_key,7,LEN(prd_key)),
            prd_nm,
            ISNULL(prd_cost,0),

            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other_sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'N/A'
            END,

            CAST(prd_start_dt AS DATE),

            DATEADD(DAY,-1,
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key ORDER BY prd_start_dt
                )
            )
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();
        PRINT 'Time: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR);

        ---------------------------------------------------------
        -- crm_sales_details
        ---------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '------crm_sales_details------';

        TRUNCATE TABLE silver.crm_sales_details;

        INSERT INTO silver.crm_sales_details(
            sls_ord_num, sls_prd_key, sls_cust_id,
            sls_order_dt, sls_ship_dt, sls_due_dt,
            sls_sales, sls_quantity, sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            CASE 
                WHEN sls_order_dt = 0 OR LEN(CAST(sls_order_dt AS VARCHAR)) != 8 THEN NULL
                ELSE CAST(CONVERT(VARCHAR,sls_order_dt) AS DATE)
            END,

            CASE 
                WHEN sls_ship_dt = 0 OR LEN(CAST(sls_ship_dt AS VARCHAR)) != 8 THEN NULL
                ELSE CAST(CONVERT(VARCHAR,sls_ship_dt) AS DATE)
            END,

            CASE 
                WHEN sls_due_dt = 0 OR LEN(CAST(sls_due_dt AS VARCHAR)) != 8 THEN NULL
                ELSE CAST(CONVERT(VARCHAR,sls_due_dt) AS DATE)
            END,

            CASE 
                WHEN sls_sales IS NULL OR sls_sales <= 0 
                     OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END,

            sls_quantity,

            CASE 
                WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity,0)
                ELSE sls_price
            END
        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();
        PRINT 'Time: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR);

        ---------------------------------------------------------
        -- erp_cust_az12
        ---------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '------erp_cust_az12------';

        TRUNCATE TABLE silver.erp_cust_az12;

        INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
        SELECT 
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid)) ELSE cid END,
            CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END,
            CASE 
                WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
                ELSE 'N/A'
            END
        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        PRINT 'Time: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR);

        ---------------------------------------------------------
        -- erp_loc_a101
        ---------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '------erp_loc_a101------';

        TRUNCATE TABLE silver.erp_loc_a101;

        INSERT INTO silver.erp_loc_a101(cid,cntry)
        SELECT 
            REPLACE(cid,'-',''),
            CASE 
                WHEN TRIM(cntry)='DE' THEN 'GERMANY'
                WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
                WHEN TRIM(cntry)='' OR cntry IS NULL THEN 'N/A'
                ELSE TRIM(cntry)
            END
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT 'Time: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR);

        ---------------------------------------------------------
        -- erp_px_cat_g1v2
        ---------------------------------------------------------
        SET @start_time = GETDATE();

        PRINT '------erp_px_cat_g1v2------';

        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        INSERT INTO silver.erp_px_cat_g1v2(id,cat,subcat,maintenence)
        SELECT id,cat,subcat,maintenence
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT 'Time: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR);

        ---------------------------------------------------------
        -- BATCH END
        ---------------------------------------------------------
        SET @batch_end_time = GETDATE();

        PRINT '===== TOTAL TIME: ' + 
              CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS VARCHAR) + ' sec =====';

    END TRY

    BEGIN CATCH
        SET @error_message = ERROR_MESSAGE();
        PRINT 'ERROR: ' + @error_message;
    END CATCH

END;


/*==============================================================
▶️ EXECUTION
==============================================================*/
EXEC silver.load_silver;

