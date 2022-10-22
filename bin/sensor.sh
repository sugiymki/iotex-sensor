#/bin/bash
url=iot-XX.epi.it.matsue-ct.jp/~hogehoge/php/monitoring.php
bin=$HOME/iotex-sensor/bin/si7021
hostname=`hostname`
sudo pigpiod
while :
do 
  sec=`date +"%S"`
  if [ $sec = "00" ] ; then
    time=`date +%Y%m%d%H%M%S` 
    temp=`$bin -t`
    humi=`$bin -r`
    echo $time $temp $humi
    curl -u user:passwd "https://$url?hostname=$hostname&time=$time&temp=$temp&humi=$humi" 
  fi
  sleep 1
  done
