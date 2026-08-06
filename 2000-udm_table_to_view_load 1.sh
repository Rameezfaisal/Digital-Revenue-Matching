#!/bin/ksh

. /home/informatica/bin/standard_env*



bteq << EOF
.session transaction BTET
.logon $TDENV/infaapp,$INFAPWD;

.set errorout stdout;

---------------------UPDATE UDM_VIEW_LOAD TABLE WHICH STORE MAX DATE LOAD FROM TABLE

update dss_marts.udm_view_load  from (
SELECT datasource_num_id,max(date_invoice) as max_date_loaded from dss_marts.digital_dashboard_control
group by datasource_num_id ) uvl
                              
                              set max_date_loaded = uvl.max_date_loaded 
                              where udm_view_load.datasource_num_id = uvl.datasource_num_id 
                              and UPPER(view_name) = 'DIGITAL_DASHBOARD_CONTROL';

----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR WESNET------------------------

insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
  uof.flex_1 ent_type,
(select distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where doc.ent_type= uof.flex_1
and doc.datasource_num_id = uof.datasource_num_id
) rollup_category,
sf.date_invoice, 
count(*) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_description from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.wesnet_order_no order_number,
(case 
when sf.currency = 'USD' then 
1
ELSE
(select conversion_rate
from datamart.ora_conv_rates_mthly curr_conv
where curr_conv.from_currency = sf.currency
and to_currency = 'USD'
and year(sf.date_invoice) = curr_conv.cnv_year
and month(sf.date_invoice) = curr_conv.cnv_month) 
end )currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
left outer join (select distinct sales_order_no,branch_id,datasource_num_id,order_integration_id,flex_1 from dss_marts.udm_order_fact) uof
on (uof.sales_order_no = sf.wesnet_order_no
and uof.datasource_num_id = sf.datasource_num_id
and uof.branch_id = sf.branch_id
and uof.order_integration_id=sf.order_integration_id)
Left Outer Join dss_marts.udm_customer_dim as cus
On sf.customer_dim_key = cus.customer_dim_key
where sf.datasource_num_id  = 3000 
and sf.date_invoice > (select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=3000 ) 
and  sf.date_invoice < To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
AND sf.accounting_include_flag = 'Y'
           AND nvl(sf.sales_transfer_flag,'N' )<> 'Y'
                AND nvl(sf.kit_component_flag,'N') <> 'C'
                                                         and left(cus.customer_no,1) <> 'X'
                                                                           AND sf.sim_description <>'Datacom Redaction'
AND Coalesce(sf.inventory_org_code, '') <> 'SCS'
AND (sf.sales_amount <> 0 OR sf.cost_amount <> 0 OR sf.quantity <> 0 OR sf.market_cost <> 0)
AND sf.transaction_type <> 'X99'
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
	group by  sf.datasource_num_id,ent_type, 
	sbu,rollup_category,
	  sf.date_invoice,sf.currency,
	  cus.customer_name,
cus.customer_no,
sf.invoice_no,
               sf.wesnet_order_no,
data_source_name,currency_conversion
having sum(sf.sales_amount) <> 0 ;

----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR LIBERTY------------------------

insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
uof.ent_type ent_type,
(select distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where doc.ent_type= uof.ent_type
and doc.datasource_num_id = sf.datasource_num_id
) rollup_category,
sf.date_invoice, 
count(distinct sf.order_number) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_description from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.order_number,
(case 
when sf.currency = 'USD' then 
1
ELSE
(select conversion_rate
from datamart.ora_conv_rates_mthly curr_conv
where curr_conv.from_currency = sf.currency
and to_currency = 'USD'
--and curr_conv.rate_type = 'MTEND'
and year(sf.date_invoice) = curr_conv.cnv_year
and month(sf.date_invoice) = curr_conv.cnv_month) 
end )currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
Left Outer Join  
    (select distinct ent_type, sales_order_no,branch_id    
     from dss_marts.udm_order_fact    
	where datasource_num_id = '5000' ) as uof                     
	                 On (uof.sales_order_no = sf.order_number and sf.branch_id = uof.branch_id)		
Left Outer Join dss_marts.udm_customer_dim as cus
On sf.customer_dim_key = cus.customer_dim_key
where   
--and sf.orig_line_no = uof.linenum
sf.datasource_num_id =5000--in (14000,13000,5000)
and sf.date_invoice > (select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=5000 ) 
and  sf.date_invoice < To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
/*and cus.intercompany_customer  Is Null
--and digital_order_channel is Not null
AND sf.accounting_include_flag = 'Y'
           AND nvl(sf.sales_transfer_flag,'N' )<> 'Y'
                AND nvl(sf.kit_component_flag,'N') <> 'C'*/
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)

                                                            group by  sf.datasource_num_id,ent_type,sbu,rollup_category,sf.date_invoice,sf.currency,
															cus.customer_name,
cus.customer_no,
sf.invoice_no,
sf.order_number,
data_source_name,
currency_conversion
having sum(sf.sales_amount) <> 0;

----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR ERP------------------------

insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
uof.ent_type ent_type,
(select distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where doc.ent_type= uof.ent_type
and doc.datasource_num_id = uof.datasource_num_id
) rollup_category,
sf.date_invoice, 
count(*) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_description from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.order_number,
(case 
when sf.currency = 'USD' then 
1
ELSE
(select conversion_rate
from datamart.ora_conv_rates_mthly curr_conv
where curr_conv.from_currency = sf.currency
and to_currency = 'USD'
and year(sf.date_invoice) = curr_conv.cnv_year
and month(sf.date_invoice) = curr_conv.cnv_month) 
end )currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
left outer join (select distinct sales_order_no,datasource_num_id,branch_id,ent_type from  dss_marts.udm_order_fact ) uof
on (uof.sales_order_no = sf.order_number
and uof.datasource_num_id = sf.datasource_num_id
--and uof.branch_id = sf.branch_id
)
Left Outer Join dss_marts.udm_customer_dim as cus
On sf.customer_dim_key = cus.customer_dim_key
where 
sf.datasource_num_id  = 9000
and sf.date_invoice > (select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=9000 ) 
and  sf.date_invoice < To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
--AND sf.accounting_include_flag = 'Y'
           AND nvl(sf.sales_transfer_flag,'N' )<> 'Y'
                AND nvl(sf.kit_component_flag,'N') <> 'C'
                                                            and left(cus.customer_no,1) <> 'X'    
                                                            AND sf.sim_description <>'Datacom Redaction'
--AND Coalesce(sf.inventory_org_code, '') <> 'SCS'
AND (sf.sales_amount <> 0 OR sf.cost_amount <> 0 OR sf.quantity <> 0 OR sf
.market_cost <> 0)
AND sf.transaction_type <> 'X99'
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
group by  sf.datasource_num_id,ent_type,
sbu,rollup_category
,sf.date_invoice,sf.currency,
cus.customer_name,
cus.customer_no,
sf.invoice_no,
sf.order_number,
data_source_name,currency_conversion
having sum(sf.sales_amount) <> 0;

----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR Conney------------------------

insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
 uof.ent_type ent_type,
(select distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where doc.ent_type= uof.ent_type
and doc.datasource_num_id = sf.datasource_num_id
) rollup_category,
sf.date_invoice, 
count(distinct sf.order_number) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_description from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.order_number,
(case 
when sf.currency = 'USD' then 
1
ELSE
(select conversion_rate
from datamart.ora_conv_rates_mthly curr_conv
where curr_conv.from_currency = sf.currency
and to_currency = 'USD'
--and curr_conv.rate_type = 'MTEND'
and year(sf.date_invoice) = curr_conv.cnv_year
and month(sf.date_invoice) = curr_conv.cnv_month) 
end )currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
Left Outer Join  
    (select distinct ent_type, sales_order_no,branch_id    
     from dss_marts.udm_order_fact    
	where datasource_num_id = '13000' 
	and ent_type in (select doc.ent_type
from dss_marts.udm_digital_channel_code_dim doc
where doc.datasource_num_id = 13000
and rollup_category in ('Websites','Materials Management','Integrations'))) as uof                     
	                 On (uof.sales_order_no = sf.order_number and sf.branch_id = uof.branch_id)		
Left Outer Join dss_marts.udm_customer_dim as cus
On sf.customer_dim_key = cus.customer_dim_key
where   
--and sf.orig_line_no = uof.linenum
sf.datasource_num_id =13000--in (14000,13000,5000)
and sf.date_invoice > (select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=13000 ) 
and  sf.date_invoice < To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
--and digital_order_channel is Not null
and nvl(cus.intercompany_customer, 'N')  = 'N'
AND sf.accounting_include_flag = 'Y'
           AND nvl(sf.sales_transfer_flag,'N' )<> 'Y'
                AND nvl(sf.kit_component_flag,'N') <> 'C'
			AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)

                                                            group by  sf.datasource_num_id,ent_type,sbu,rollup_category,sf.date_invoice,sf.currency,
															cus.customer_name,
cus.customer_no,
sf.invoice_no,
sf.order_number,
data_source_name,currency_conversion
having sum(sf.sales_amount) <> 0;

----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR EECOL------------------------

insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
 uof.ent_type ent_type,
(select distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where REGEXP_REPLACE(doc.ent_type,'       ', '')= uof.ent_type
and doc.datasource_num_id = sf.datasource_num_id
) rollup_category,
sf.date_invoice, 
count(distinct sf.order_number) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_description from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.order_number,
(case 
when sf.currency = 'USD' then 
1
ELSE
(select conversion_rate
from datamart.ora_conv_rates_mthly curr_conv
where curr_conv.from_currency = sf.currency
and to_currency = 'USD'
--and curr_conv.rate_type = 'MTEND'
and year(sf.date_invoice) = curr_conv.cnv_year
and month(sf.date_invoice) = curr_conv.cnv_month) 
end )currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
Left Outer Join  
    (select distinct ent_type, sales_order_no,branch_id,WesnetLine    
     from dss_marts.udm_order_fact    
	where datasource_num_id = '11000' ) as uof                     
	                 On (to_number(uof.sales_order_no) = sf.order_number and sf.branch_id = uof.branch_id
and uof.WesnetLine=sf.invoice_line_no)		
Left Outer Join dss_marts.udm_customer_dim as cus
On sf.customer_dim_key = cus.customer_dim_key
where   
--and sf.orig_line_no = uof.linenum
sf.datasource_num_id  = 11000
and sf.date_invoice>(select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=11000 ) 
and sf.date_invoice < To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
and nvl(cus.intercompany_customer, 'N') = 'N'
--and digital_order_channel is Not null
--AND sf.accounting_include_flag = 'Y'
          -- AND nvl(sf.sales_transfer_flag,'N' )<> 'Y'
               -- AND nvl(sf.kit_component_flag,'N') <> 'C'
			AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)

                                                            group by  sf.datasource_num_id,ent_type,sbu,rollup_category,sf.date_invoice,sf.currency,
															cus.customer_name,
cus.customer_no,
sf.invoice_no,
sf.order_number,
data_source_name,currency_conversion
having sum(sf.sales_amount) <> 0;


----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR Hazmasters------------------------

insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
uof.ent_type ent_type,
(select distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where doc.ent_type= uof.ent_type
and doc.datasource_num_id = sf.datasource_num_id) rollup_category,
sf.date_invoice, 
count(distinct sf.order_number) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_description from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.order_number,
(case 
when sf.currency = 'USD' then 
1
ELSE
(select conversion_rate
from datamart.ora_conv_rates_mthly curr_conv
where curr_conv.from_currency = sf.currency
and to_currency = 'USD'
--and curr_conv.rate_type = 'MTEND'
and year(sf.date_invoice) = curr_conv.cnv_year
and month(sf.date_invoice) = curr_conv.cnv_month) 
end )currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
Left Outer Join  
    (select distinct ent_type, sales_order_no,branch_id    
     from dss_marts.udm_order_fact    
	where datasource_num_id = '14000' ) as uof                     
	                 On (uof.sales_order_no = sf.order_number and sf.branch_id = uof.branch_id)	
					 Left Outer Join dss_marts.udm_customer_dim as cus
On sf.customer_dim_key = cus.customer_dim_key
where   
--and sf.orig_line_no = uof.linenum
sf.datasource_num_id  = 14000--in (14000,13000,5000)
and sf.date_invoice > (select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=14000 ) 
and sf.date_invoice < To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
--and digital_order_channel is Not null
AND sf.accounting_include_flag = 'Y'
           AND nvl(sf.sales_transfer_flag,'N' )<> 'Y'
                AND nvl(sf.kit_component_flag,'N') <> 'C'
			AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)

                                                            group by  sf.datasource_num_id,ent_type,sbu,rollup_category,sf.date_invoice,sf.currency,
															cus.customer_name,
cus.customer_no,
sf.invoice_no,
sf.order_number,
data_source_name,currency_conversion
having sum(sf.sales_amount) <> 0;


----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR WIS------------------------
insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(
select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
nvl( uof.ent_type,'e-Crib')  ent_type,
nvl ((select distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where doc.ent_type= uof.ent_type
and doc.datasource_num_id = sf.datasource_num_id) ,'Materials Management') rollup_category,
sf.date_invoice, 
count(distinct sf.order_number) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_description from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.order_number,
(case 
when sf.currency = 'USD' then 
1
ELSE
(select conversion_rate
from datamart.ora_conv_rates_mthly curr_conv
where curr_conv.from_currency = sf.currency
and to_currency = 'USD'
--and curr_conv.rate_type = 'MTEND'
and year(sf.date_invoice) = curr_conv.cnv_year
and month(sf.date_invoice) = curr_conv.cnv_month) 
end) currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
Left Outer Join  
    (select distinct ent_type, sales_order_no,branch_id    
     from dss_marts.udm_order_fact    
	where datasource_num_id = '10000' ) as uof                     
	                 On (sf.order_number = uof.sales_order_no and sf.branch_id = uof.branch_id)				
					 Left Outer Join dss_marts.udm_customer_dim as cus
On sf.customer_dim_key = cus.customer_dim_key
where   
--and sf.orig_line_no = uof.linenum
sf.datasource_num_id = 10000 
and sf.date_invoice > (select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=10000 ) 
and sf.date_invoice < To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
group by  sf.datasource_num_id,
ent_type,
sbu,rollup_category,
sf.date_invoice,
sf.currency,
cus.customer_name,
cus.customer_no,
sf.invoice_no,
sf.order_number,
data_source_name,currency_conversion
having sum(sf.sales_amount) <> 0;


----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR TVC------------------------

insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
 uof.ent_type ent_type,
(
select  distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where doc.ent_type= uof.ent_type
and doc.datasource_num_id = sf.datasource_num_id
) rollup_category,
sf.date_invoice, 
count(distinct sf.order_number) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_description from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.order_number,
(case 
when sf.currency = 'USD' then 
1
ELSE
(select conversion_rate
from datamart.ora_conv_rates_mthly curr_conv
where curr_conv.from_currency = sf.currency
and to_currency = 'USD'
and year(sf.date_invoice) = curr_conv.cnv_year
and month(sf.date_invoice) = curr_conv.cnv_month) 
end )currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
Left Outer Join  
    (select distinct ent_type, sales_order_no,flex_1    
     from dss_marts.udm_order_fact    
	where datasource_num_id = '4000' ) as uof                     
	                 On (sf.order_number = uof.sales_order_no and sf.flex_1 = uof.flex_1)			
					  Left Outer Join (select customer_name,customer_no,customer_dim_key, CASE WHEN (UPPER(national_acct_no) IN ('ICO','ANIX','INTE','WESC','WDB','LIB') OR 
UPPER(customer_name) LIKE '%WESCO%' OR UPPER(customer_name) LIKE '%ANIXTER%')
THEN 'Y' ELSE 'N' END AS INTERBRANCH_FLAG  
 from dss_marts.udm_customer_dim) as cus
On sf.customer_dim_key = cus.customer_dim_key
where
sf.datasource_num_id  = 4000
and sf.date_invoice > (select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=4000 ) 
and sf.date_invoice < To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
AND sf.accounting_include_flag = 'Y'
and cus.INTERBRANCH_FLAG <> 'Y' 
           AND nvl(sf.sales_transfer_flag,'N' )<> 'Y'
                AND nvl(sf.kit_component_flag,'N') <> 'C'
                                                            and left(cus.customer_no,1) <> 'X'    
                                                            AND sf.sim_description <>'Datacom Redaction'
AND Coalesce(sf.inventory_org_code, '') <> 'SCS'
AND (sf.sales_amount <> 0 OR sf.cost_amount <> 0 OR sf.quantity <> 0 OR sf.market_cost <> 0)
AND sf.transaction_type <> 'X99'
                                                            group by  sf.datasource_num_id,ent_type,
                                                                      sbu,rollup_category
                                                                    ,sf.date_invoice,sf.currency,
																	cus.customer_name,
cus.customer_no,
sf.invoice_no,
sf.order_number,
data_source_name,currency_conversion
having sum(sf.sales_amount) <> 0;

----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR HC------------------------

insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
uof.ent_type ent_type,
(select distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where doc.ent_type= uof.ent_type
and doc.datasource_num_id = sf.datasource_num_id
) rollup_category,
sf.date_invoice, 
count(distinct sf.order_number) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_description from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.order_number,
(case 
when sf.currency = 'USD' then 
1
ELSE
(select conversion_rate
from datamart.ora_conv_rates_mthly curr_conv
where curr_conv.from_currency = sf.currency
and to_currency = 'USD'
--and curr_conv.rate_type = 'MTEND'
and year(sf.date_invoice) = curr_conv.cnv_year
and month(sf.date_invoice) = curr_conv.cnv_month) 
end )currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
Left Outer Join  
     (select distinct ent_type, sales_order_no,branch_id,datasource_num_id,invoice_no    
     from dss_marts.udm_order_fact    
	) as uof                     
	                 On (uof.sales_order_no = sf.wesnet_order_no 
and sf.branch_id = uof.branch_id
 and  uof.datasource_num_id = sf.datasource_num_id 
					 and ent_type in ('RDC','EDI','MBL','IX')
					 and (uof.sales_order_no || '.' || lpad(uof.invoice_no,3,'0')) = sf.invoice_no
					 )							
Left Outer Join dss_marts.udm_customer_dim as cus
On sf.customer_dim_key = cus.customer_dim_key
where   
--and sf.orig_line_no = uof.linenum
sf.datasource_num_id =6000
and sf.date_invoice > (select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=6000 ) 
and sf.date_invoice < To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
--and cus.intercompany_customer  Is Null
--and digital_order_channel is Not null
/*AND sf.accounting_include_flag = 'Y'
           AND nvl(sf.sales_transfer_flag,'N' )<> 'Y'
                AND nvl(sf.kit_component_flag,'N') <> 'C'*/

                                                            group by  sf.datasource_num_id,ent_type,sbu,rollup_category,sf.date_invoice,sf.currency,
															cus.customer_name,
cus.customer_no,
sf.invoice_no,
sf.order_number,
data_source_name,currency_conversion
having sum(sf.sales_amount) <> 0;

----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR AED------------------------
insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
uof.ent_type ent_type,
(select distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where doc.ent_type= uof.ent_type
and doc.datasource_num_id = sf.datasource_num_id
) rollup_category,
sf.date_invoice, 
count(distinct sf.order_number) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_description from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.order_number,
(case 
when sf.currency = 'USD' then 
1
ELSE
(select conversion_rate
from datamart.ora_conv_rates_mthly curr_conv
where curr_conv.from_currency = sf.currency
and to_currency = 'USD'
--and curr_conv.rate_type = 'MTEND'
and year(sf.date_invoice) = curr_conv.cnv_year
and month(sf.date_invoice) = curr_conv.cnv_month) 
end )currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
Left Outer Join  
     (select distinct ent_type, sales_order_no,branch_id,datasource_num_id,invoice_no    
     from dss_marts.udm_order_fact    
	) as uof                     
	                 On (uof.sales_order_no = sf.wesnet_order_no 
and sf.branch_id = uof.branch_id
 and  uof.datasource_num_id = sf.datasource_num_id 
					 and ent_type in ('RDC','EDI','MBL','IX')
					 and (uof.sales_order_no || '.' || lpad(uof.invoice_no,3,'0')) = sf.invoice_no
					 )							
Left Outer Join dss_marts.udm_customer_dim as cus
On sf.customer_dim_key = cus.customer_dim_key
where   
--and sf.orig_line_no = uof.linenum
sf.datasource_num_id =7000
and sf.date_invoice > (select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=7000 ) 
and sf.date_invoice < To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
--and cus.intercompany_customer  Is Null
--and digital_order_channel is Not null
/*AND sf.accounting_include_flag = 'Y'
           AND nvl(sf.sales_transfer_flag,'N' )<> 'Y'
                AND nvl(sf.kit_component_flag,'N') <> 'C'*/

                                                            group by  sf.datasource_num_id,ent_type,sbu,rollup_category,sf.date_invoice,sf.currency,
															cus.customer_name,
cus.customer_no,
sf.invoice_no,
sf.order_number,
data_source_name,currency_conversion
having sum(sf.sales_amount) <> 0;



----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR Needham------------------------


insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
uof.ent_type ent_type,
(select distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where doc.ent_type= uof.ent_type
and doc.datasource_num_id = sf.datasource_num_id
) rollup_category,
sf.date_invoice, 
count(distinct sf.order_number) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_description from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.order_number,
(case 
when sf.currency = 'USD' then 
1
ELSE
(select conversion_rate
from datamart.ora_conv_rates_mthly curr_conv
where curr_conv.from_currency = sf.currency
and to_currency = 'USD'
--and curr_conv.rate_type = 'MTEND'
and year(sf.date_invoice) = curr_conv.cnv_year
and month(sf.date_invoice) = curr_conv.cnv_month) 
end )currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
Left Outer Join  
     (select distinct ent_type, sales_order_no,branch_id,datasource_num_id,invoice_no    
     from dss_marts.udm_order_fact    
	) as uof                     
	                 On (uof.sales_order_no = sf.wesnet_order_no 
and sf.branch_id = uof.branch_id
 and  uof.datasource_num_id = sf.datasource_num_id 
					 and ent_type in ('RDC','EDI','MBL','IX')
					 and (uof.sales_order_no || '.' || lpad(uof.invoice_no,3,'0')) = sf.invoice_no
					 )							
Left Outer Join dss_marts.udm_customer_dim as cus
On sf.customer_dim_key = cus.customer_dim_key
where   
--and sf.orig_line_no = uof.linenum
sf.datasource_num_id =8000
and sf.date_invoice > (select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=8000 ) 
and sf.date_invoice < To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
--and cus.intercompany_customer  Is Null
--and digital_order_channel is Not null
/*AND sf.accounting_include_flag = 'Y'
           AND nvl(sf.sales_transfer_flag,'N' )<> 'Y'
                AND nvl(sf.kit_component_flag,'N') <> 'C'*/

                                                            group by  sf.datasource_num_id,ent_type,sbu,rollup_category,sf.date_invoice,sf.currency,
															cus.customer_name,
cus.customer_no,
sf.invoice_no,
sf.order_number,
data_source_name,currency_conversion
having sum(sf.sales_amount) <> 0;

----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR Anixter Eclipse ------------------------
insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
uof.ent_type1,
(select distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where doc.ent_type= uof.ent_type1
and doc.datasource_num_id = sf.datasource_num_id) rollup_category,
sf.date_invoice, 
count(distinct sf.order_number) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_name from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.order_number,
nvl((case 
when sf.currency = 'USD' then 
1
ELSE
nvl((select conversion_rate
from datamart.ora_conv_rates_mthly curr_conv
where curr_conv.from_currency = sf.currency
and to_currency = 'USD'
--and curr_conv.rate_type = 'MTEND'
and year(sf.date_invoice) = curr_conv.cnv_year
and month(sf.date_invoice) = curr_conv.cnv_month) , (select curr_conv_actual_f
from dss_marts.anixter_monthly_conversion_rate_tbl curr_conv
where curr_conv.from_curr_c = sf.currency
--and to_currency = 'USD'
and curr_conv.rate_type = 'MTEND'
and year(sf.date_invoice) = curr_conv.fiscal_YY_d
and month(sf.date_invoice) = curr_conv.fiscal_MM_D) )
end), sf.conversion_rate )currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
Left Outer Join  
     (select distinct ent_type,(case 
	 when trim(uo.ent_type) =  'EDI' 
	 then
	 'EDI Sales'
	 when uo.ent_type = 'WOE'
	 then
	 'Web Order Entry (WOE)'
	  when uo.ent_type = 'MBAS'
	 then
	 'Virtual Warehouse'
	  when uo.ent_type = 'CRM'
	 then
	 'Vending Machines'
	 when uo.ent_type = 'Manual' and customer_po_no = 'CRIBMASTER'
	 then
	 'Vending Machines'
	 else 
	 uo.ent_type
	 end)
	 ent_type1, sales_order_no,branch_id,datasource_num_id,invoice_no,date_invoice
     from dss_marts.udm_order_fact  uo  
	) as uof                     
	                 On ( uof.sales_order_no= sf.order_number
					and trim(concat(uof.sales_order_no,'.', uof.invoice_no)) = sf.invoice_no
					 )							
Left Outer Join dss_marts.udm_customer_dim as cus
On sf.customer_dim_key = cus.customer_dim_key
where   
sf.datasource_num_id  = '12001'
and sf.date_invoice > (select  max(max_date_loaded) from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=12001 ) 
AND sf.accounting_include_flag = 'Y'
          AND nvl(sf.sales_transfer_flag,'N' ) <> 'Y'
             AND nvl(sf.kit_component_flag,'N') <> 'C'
			and cus.intercompany_customer <> 'Y'
and  sf.date_invoice< To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
                                                            group by  sf.datasource_num_id,uof.ent_type1,sbu,
															rollup_category,
															sf.date_invoice,
															sf.currency,
														cus.customer_name,
cus.customer_no,
sf.invoice_no,
sf.order_number,
data_source_name,currency_conversion
having sum(sf.sales_amount) <> 0;
--and  (customer_name not like '%ANIXTER%' and customer_name not like '%WESCO%')



----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR Anixter SXE USA, SXE CAN,Mainframe------------------------
insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
uof.ent_type ent_type,
(select distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where doc.ent_type= uof.ent_type
and doc.datasource_num_id = sf.datasource_num_id
) rollup_category,
sf.date_invoice, 
count(distinct sf.order_number) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_description from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.order_number,
(case 
when sf.currency = 'USD' then 
1
ELSE
nvl((select CURR_CONV_ACTUAL_F
from dss_marts.anixter_monthly_conversion_rate_tbl curr_conv
where curr_conv.FROM_CURR_C = sf.currency
--and to_currency = 'USD'
and curr_conv.rate_type = 'MTEND'
and year(sf.date_invoice) = curr_conv.FISCAL_YY_D
and month(sf.date_invoice) = curr_conv.FISCAL_MM_D),sf.budget_conversion_rate)
end )currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
Left Outer Join  
     (select distinct ent_type, sales_order_no,branch_id,datasource_num_id,invoice_no,date_invoice    
     from dss_marts.udm_order_fact    
	) as uof                     
	                 On (sf.branch_id = uof.branch_id
 and 
 uof.datasource_num_id = sf.datasource_num_id 
 and uof.date_invoice = sf.date_invoice
 and uof.invoice_no = (case 
when instr(sf.invoice_no,'-') > 0 
then 
substr(sf.invoice_no,1,instr(sf.invoice_no,'-')-1)
else 
sf.invoice_no 
end )
					 and uof.sales_order_no= sf.order_number
					 )													
Left Outer Join dss_marts.udm_customer_dim as cus
On sf.customer_dim_key = cus.customer_dim_key
where   
--and sf.orig_line_no = uof.linenum
sf.datasource_num_id in (12002,12003,12004)
and sf.date_invoice > (select max(max_date_loaded) from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id in (12002,12003,12004)) 
and TO_CHAR(sf.DATE_INVOICE, 'YYYY-MM')<> TO_CHAR(DATE,'YYYY-MM')
--and year(sf.date_invoice) = '2023'
--and month(sf.date_invoice) = '1'
and nvl(cus.intercompany_customer,'N')  <> 'Y'
--and sf.order_number = 797962
--and digital_order_channel is Not null
/*AND sf.accounting_include_flag = 'Y'
           AND nvl(sf.sales_transfer_flag,'N' )<> 'Y'
                AND nvl(sf.kit_component_flag,'N') <> 'C'*/
and  sf.date_invoice< To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
                                                            group by  sf.datasource_num_id,ent_type,sbu,rollup_category,sf.date_invoice,sf.currency,
													cus.customer_name,
cus.customer_no,
sf.invoice_no,
sf.order_number,
data_source_name,currency_conversion
having sum(sf.sales_amount) <> 0;

----------------LOAD DATA to dss_marts.digital_dashboard_control table INSERT FOR Anixter Rubicon------------------------
insert into dss_marts.digital_dashboard_control
select sf.datasource_num_id,
(select sbu
from dss_marts.branch_dim bd
where sf.branch_id = bd.branch_id) sbu,
case
when ent_type = 'A'
then
'EDI Sales'
else 
uof.ent_type
end ent_type,
(case 
when ent_type = 'A'
then 
'Integrations'
else 
(select distinct doc.rollup_category
from dss_marts.udm_digital_channel_code_dim doc
where doc.ent_type= uof.ent_type
and doc.datasource_num_id = sf.datasource_num_id)
end 
) rollup_category,
sf.date_invoice, 
count(distinct sf.order_number) total_no_of_sales,
sum(sf.sales_amount) sales_amount,
sf.currency,
(Select dt.datasource_name from 
dss_marts.datasource_tbl  as dt
where dt.datasource_num_id= sf.datasource_num_id ) data_source_name,
cus.customer_no||'_'|| cus.customer_name cust_name,
sf.invoice_no,
sf.order_number,
nvl((case 
when sf.currency = 'USD' then 
1
ELSE
nvl((select conversion_rate
from datamart.ora_conv_rates_mthly curr_conv
where curr_conv.from_currency = sf.currency
and to_currency = 'USD'
--and curr_conv.rate_type = 'MTEND'
and year(sf.date_invoice) = curr_conv.cnv_year
and month(sf.date_invoice) = curr_conv.cnv_month) , (select curr_conv_actual_f
from dss_marts.anixter_monthly_conversion_rate_tbl curr_conv
where curr_conv.from_curr_c = sf.currency
--and to_currency = 'USD'
and curr_conv.rate_type = 'MTEND'
and year(sf.date_invoice) = curr_conv.fiscal_YY_d
and month(sf.date_invoice) = curr_conv.fiscal_MM_D) )
end), sf.conversion_rate )currency_conversion,
(cast (sum(sf.sales_amount) as DECIMAL(38,2)) * currency_conversion)  sales_amount_USD,
DATE CREATE_DATE
from dss_marts.udm_sales_fact sf
Left Outer Join  
     (select distinct ent_type, sales_order_no,branch_id,datasource_num_id,invoice_no,date_invoice
     from dss_marts.udm_order_fact    
	) as uof                     
	                 On (sf.branch_id = uof.branch_id
 and 
 uof.datasource_num_id = sf.datasource_num_id 
					 and uof.sales_order_no= to_number(sf.order_number)
					 )							
Left Outer Join dss_marts.udm_customer_dim as cus
On sf.customer_dim_key = cus.customer_dim_key
where   
sf.datasource_num_id  = '12005'
and sf.date_invoice > (select  max_date_loaded from dss_marts.udm_view_load where view_name='DIGITAL_DASHBOARD_CONTROL' and datasource_num_id=12005 ) 
AND sf.accounting_include_flag = 'Y'
          AND nvl(sf.sales_transfer_flag,'N' )<> 'Y'
             AND nvl(sf.kit_component_flag,'N') <> 'C'
and  sf.date_invoice< To_date(TO_CHAR(Current_date, 'YYYY-MM')||'-01','YYYY-MM-DD')
AND exists (select calendar_date from datamart.calendar_work_day where day_of_month=6 and calendar_date=current_date)
                                                            group by  sf.datasource_num_id,ent_type,sbu,rollup_category,sf.date_invoice,
															sf.currency,
														cus.customer_name,
cus.customer_no,
sf.invoice_no,
sf.order_number,
data_source_name,currency_conversion
having sum(sf.sales_amount) <> 0;
-----COLLECT STATS --

COLLECT  STATS ON DSS_MARTS.DIGITAL_DASHBOARD_CONTROL;


if errorcode <> 0 then .exit errorcode
.quit

EOF

ERROR=$?
if [ $ERROR -ne 0 ]
then
       echo "Table UDM_OUTSIDE_SALES_DIM data load failed from view"|sendmail assistme@service-now.com,bmoodey@wescodist.com,mboyle@wescodist.com,BI_ETL_Support@wescodist.com
exit $ERROR
fi


