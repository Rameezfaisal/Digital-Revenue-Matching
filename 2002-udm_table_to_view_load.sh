#!/bin/ksh

. /home/informatica/bin/standard_env*


file_path="/etl/prod/work/etl/dss_marts/dss_marts.digital_dashboard_control_summary/Digital_dashboard_records_mismatch.csv"
if [ ! -s "$file_path" ]; then
echo "There is no mismatch between Digital Dashboard and Source Record"|mailx -s "Digital Dashboard and Source records comparision Daily" BI_Wesco_Integration_Support_L2@wescodist.com,vgolla@wescodist.com,srilatha.mahankali@wescodist.com,srichard@wescodist.com
else
echo "Please find attached the records summary having difference in source and digital dashboard control summary table."|mailx -s "Digital Dashboard and Source records comparision Daily" -a $file_path  BI_Wesco_Integration_Support_L2@wescodist.com,srichard@wescodist.com,vgolla@wescodist.com,srilatha.mahankali@wescodist.com
fi


ERROR=$?
if [ $ERROR -ne 0 ]
then
       echo "The email task for Digital Dashboard and Source records comparision Daily failed "|sendmail assistme@service-now.com,bmoodey@wescodist.com,mboyle@wescodist.com,BI_ETL_Support@wescodist.com

exit $ERROR
fi


