#!/bin/bash
log_filename='/var/log/nginx/access.log'
if test -f 'tmp_strings'; then echo 'Sctipt is already running' && exit 1; fi
###Test_Lab###
#current_date='14/Aug/2019:07'
#last_date='14/Aug/2019:06'
current_date=$(date +"%d/%b/%Y:%H")
last_date=$(date --date '-1 hour' +"%d/%b/%Y:%H")
current_point=`grep -n $current_date $log_filename | awk '{print $1}' | sort -r| grep -Eo "^[[:alnum:]]{1,}" -m 1`
last_point=`grep -n $last_date $log_filename |awk '{print $1}' | grep -Eo "^[[:alnum:]]{1,}" -m 1`

sed -n ${last_point},${current_point}p ./${log_filename} > tmp_strings
ip_list=`awk '{print $1}' tmp_strings | uniq -c| sort -n | tail -n 5`
echo "Список IP адресов" > mail_file
awk '{print $1}' tmp_strings | uniq -c| sort -n | tail -n 5 >> mail_file
echo "Список запрашиваемых URL" >> mail_file
grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" tmp_strings | sort | uniq -c >> mail_file
echo "Список всех кодов HTTP ответа" >> mail_file
grep -Eo 'HTTP/1.1"[[:space:]]\w{3}' tmp_strings | awk '{print $2}' | sort | uniq -c >> mail_file

echo -e "\nВременной диапазон: с ${last_date} по ${current_date}" >> mail_file

cat mail_file
cat mail_file |  mail -s "Изменения в логах" $1
rm -f tmp_strings mail_file
