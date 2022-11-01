#/bin/bash

# 送信先サーバ
url=iot-50.epi.it.matsue-ct.jp/~hogehoge/php/monitoring.php

# 計測用コマンド
bin=$HOME/iotex-sensor/bin/si7021

# ホスト名
hostname=`hostname`

# sensor.sh が他に起動していないか確認
pid=`pgrep sensor.sh -fc`
echo $pid
if [ $pid = "2" ]; then
   pkill -fo sensor.sh
fi

# pigpiod が起動しているかの確認
pid=`pgrep pigpiod -fc`
echo $pid
if [ $pid = "0" ]; then
   sudo pigpiod
fi

# 計測とデータ送信
while :
do
  sec=`date +"%S"`
  if [ $sec = "00" ] ; then
    time=`date +%Y%m%d%H%M%S`
    temp=`$bin -t`
    humi=`$bin -r`
    echo $time $temp $humi
    curl -u herohero:hogehero "https://$url?hostname=$hostname&time=$time&temp=$temp&humi=$humi"
  fi
  sleep 1
done
