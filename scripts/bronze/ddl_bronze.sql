/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================

Project      : Data Warehouse Project
Layer        : Bronze (Raw Data Layer)
Author       : Aditya Chauhan
Credits      : Barra (Data Engineering Tutorial)
Created On   : 28-03-2026
Last Updated : 28-03-2026

-------------------------------------------------------------------------------
Description:
This script creates tables in the 'bronze' schema. 
If the tables already exist, they are dropped and recreated.

The Bronze layer stores raw data ingested from source systems 
(e.g., CRM, ERP) without transformations.

-------------------------------------------------------------------------------
Usage:
- Execute this script to (re)create Bronze layer tables.
- Ensure proper permissions before running DROP and CREATE commands.

-------------------------------------------------------------------------------
Notes:
- This script is part of the ETL pipeline (Bronze → Silver → Gold).
- Intended for development/testing environments.
- Avoid running in production without validation.

===============================================================================
*/




IF OBJECT_ID ('bronze.crm_cust_info','U') is not null
drop table bronze.crm_cust_info;


CREATE TABLE bronze.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_material_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);

IF OBJECT_ID('bronze.crm_prd_info','U') IS NOT NULL
DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
prd_id INT,
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt DATETIME,
prd_end_dt DATETIME
);

IF OBJECT_ID('bronze.crm_sales_details','U') IS NOT NULL
DROP TABLE bronze.crm_sales_details;
CREATE  TABLE bronze.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_qunatity INT,
sls_price INT
);
IF OBJECT_ID('bronze.erp_loc_a101','U') IS NOT NULL
DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
cid NVARCHAR(50),
cntry NVARCHAR(50)
);

IF OBJECT_ID('bronze.erp_cust_az12','U') IS NOT NULL
DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
cid NVARCHAR(50),
bdate DATE,
gen NVARCHAR(50)
);
IF OBJECT_ID('bronze.erp_px_cat_g1v2','U') IS NOT NULL
DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
id   NVARCHAR(50),
cat  NVARCHAR(50),
subcat NVARCHAR(50),
maintenence NVARCHAR(50)
);

