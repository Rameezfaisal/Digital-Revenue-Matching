#!/bin/ksh

. /home/informatica/bin/standard_env*



bteq << EOF
.session transaction BTET
.logon $TDENV/infaapp,$INFAPWD;

.set errorout stdout;

----Incremental Summary WESNET---------

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=3000 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=3000 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

----Incremental Summary Liberty---------

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=5000 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=5000 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

---Incremental Summary TVC

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=4000 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=4000 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;


---Incremental Summary HC

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=6000 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=6000 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

---Incremental Summary AED

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=7000 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=7000 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

---Incremental Summary NEEDHAM

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=8000 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=8000 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

---Incremental Summary erp

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=9000 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=9000 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

---Incremental Summary WIS

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=10000 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=10000 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

---Incremental Summary EECOL

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=11000 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=11000 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

---Incremental Summary CONNEY

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=13000 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=13000 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

---Incremental Summary HAZMASTERS

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=14000 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=14000 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

----Incremental Summary Anixter 12001---------

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=12001 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=12001 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

----Incremental Summary Anixter 12002---------

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=12002 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=12002 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

----Incremental Summary Anixter 12003---------

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=12003 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=12003 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

----Incremental Summary Anixter 12004---------

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=12004 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=12004 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

----Incremental Summary Anixter 12005---------

insert into dss_marts.digital_dashboard_control_summary
select a.DATASOURCE_NUM_ID,a.ROLLUP_CATEGORY,a.MONTH_OF_YEAR,a.TOTAL_NO_OF_SALES,a.SALES_AMOUNT,a.SALES_AMOUNT_USD,rec_date.create_date from 
(SELECT DATASOURCE_NUM_ID,
ROLLUP_CATEGORY,
TO_CHAR(DATE_INVOICE, 'YYYY-MM') AS MONTH_OF_YEAR,
SUM(TOTAL_NO_OF_SALES) AS TOTAL_NO_OF_SALES,SUM(SALES_AMOUNT) AS SALES_AMOUNT,SUM(SALES_AMOUNT_USD) AS SALES_AMOUNT_USD
FROM DSS_MARTS.DIGITAL_DASHBOARD_CONTROL 
where  DATASOURCE_NUM_ID=12005 AND DATE_INVOICE > 
(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=12005 ) 
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
GROUP BY
    DATASOURCE_NUM_ID,ROLLUP_CATEGORY,TO_CHAR(DATE_INVOICE, 'YYYY-MM')) a cross join 
	(select date create_date) rec_date;

-----COLLECT STATS --

COLLECT  STATS ON DSS_MARTS.DIGITAL_DASHBOARD_CONTROL_SUMMARY;


if errorcode <> 0 then .exit errorcode
.quit

EOF

ERROR=$?
if [ $ERROR -ne 0 ]
then
       echo "Table DIGITAL_DASHBOARD_CONTROL_SUMMARY load failed from view"|sendmail assistme@service-now.com,bmoodey@wescodist.com,mboyle@wescodist.com,BI_ETL_Support@wescodist.com

exit $ERROR
fi


