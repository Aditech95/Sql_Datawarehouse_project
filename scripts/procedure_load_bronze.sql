/*
===============================================================================
Stored Procedure: bronze.load_bronze
===============================================================================

Project      : Data Warehouse Project
Layer        : Bronze (Raw Data Layer)
Author       : Aditya Chauhan
Credits      : Barra (Data Engineering Tutorial)
Created On   : <YYYY-MM-DD>
Last Updated : <YYYY-MM-DD>

-------------------------------------------------------------------------------
Description:
This stored procedure loads data into Bronze layer tables from source files.

It performs:
- Truncation of existing Bronze tables
- Bulk loading of raw data from source CSV files
- Basic execution tracking using timestamps

-------------------------------------------------------------------------------
Execution Flow:
1. Start batch execution
2. Load CRM tables
3. Load other source tables (if any)
4. End batch execution

-------------------------------------------------------------------------------
Parameters:
None

-------------------------------------------------------------------------------
Usage:
EXEC bronze.load_bronze;

-------------------------------------------------------------------------------
Notes:
- Designed for initial/raw data ingestion (no transformations applied)
- Part of ETL pipeline: Bronze → Silver → Gold
- Ensure file paths and permissions are correctly configured

===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze as 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY
		set @batch_start_time=GETDATE();
		PRINT '====================================';
		PRINT 'LOADING BRONZE LAYER';
		PRINT '====================================';


		PRINT'---------------------------';
		PRINT 'LOADING CRM TABLES';
		PRINT '---------------------------';

		SET @start_time =GETDATE();
		TRUNCATE TABLE bronze.crm_cust_info

		BULK INSERT bronze.crm_cust_info
		from 'C:\sql_warehouseproject\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK

		);
		SET @end_time=GETDATE();
		PRINT '>>LOAD DURATION :'+ CAST(DATEDIFF(SECOND,@start_time,@end_time) as NVARCHAR)+'SECONDS';
		



		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.crm_prd_info

		BULK INSERT bronze.crm_prd_info
		from 'C:\sql_warehouseproject\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK

		);
		SET @end_time=GETDATE();
		PRINT '>>LOAD DURATION :'+ CAST(DATEDIFF(SECOND,@start_time,@end_time) as NVARCHAR)+'SECONDS';


		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.crm_sales_details

		BULK INSERT bronze.crm_sales_details
		from 'C:\sql_warehouseproject\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK

		);
		SET @end_time=GETDATE();
		PRINT '>>LOAD_DURATION: '+CAST(DATEDIFF(SECOND,@start_time,@end_time) as NVARCHAR)+'SECONDS';
		

		PRINT '----------------------------------';
		PRINT 'LOADING ERP TABLES';
		PRINT '----------------------------------';

		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.erp_cust_az12
		BULK INSERT bronze.erp_cust_az12
		from 'C:\sql_warehouseproject\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK

		);
		SET @end_time=GETDATE();
		PRINT '>>LOAD_DURATION: '+CAST(DATEDIFF(SECOND,@start_time,@end_time) as NVARCHAR)+'SECONDS';


		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.erp_loc_a101
		BULK INSERT bronze.erp_loc_a101
		from 'C:\sql_warehouseproject\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK

		);
		SET @end_time=GETDATE();
		PRINT '>>LOAD_DURATION: '+CAST(DATEDIFF(SECOND,@start_time,@end_time) as NVARCHAR)+'SECONDS';


		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		BULK INSERT bronze.erp_px_cat_g1v2
		from 'C:\sql_warehouseproject\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR =',',
			TABLOCK

		);
		SET @end_time=GETDATE();
		PRINT '>>LOAD_DURATION: '+CAST(DATEDIFF(SECOND,@start_time,@end_time) as NVARCHAR)+'SECONDS';

		SET @batch_end_time=GETDATE();
		PRINT '>> BRONZE_LAYER_LOAD_DURATION: '+CAST(DATEDIFF(SECOND,@start_time,@end_time) as NVARCHAR)+'SECONDS';

		END TRY
		BEGIN CATCH
			PRINT '=================================';
			PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
			PRINT '=================================';
		END CATCH
END



