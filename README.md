# iotex-sensor

本リポジトリには IoT 演習で raspberry pi で用いるスクリプトや設定ファイルが格納されています.

* bin

  * main : センサーからデータを取得し, それをサーバに送信するためのスクリプト

  * bmp180 : 気圧・温度センサー Adafruit BMP180

  * tmp007 : 非接触型温度計 (放射温度計) Adafruit TMP007

  * tsl2561 : 照度センサー Adafruit TSL2561

* conf

  * crontab : crontab の例

  * zabbix-agent.conf : zabbix の設定ファイルの例
