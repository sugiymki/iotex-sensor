#!/usr/bin/env ruby
# coding: utf-8
#
# 表題: グラフ作成のためのスクリプト. CSV ファイル利用版.
#

require 'csv'
require 'date'
require 'fileutils'
require 'numo/gnuplot'

###
### デバイス毎の設定
###

# デバイス名
myid = "iot-05"

# 公開ディレクトリ
pubdir = "/home/j1661/public_html/table-csv_with-1month/"

# データ置き場
srcdir = "/home/j1661/public_html/data_csv_1day"


###
### 初期化
###

# 公開ディレクトリの作成
FileUtils.mkdir_p( pubdir ) until FileTest.exists?( pubdir )

# 欠損値
miss = 999.9

## csv ファイルに含まれる変数の一覧
#vars = [
#  "time","temp","temp2","temp3","humi","humi2","humi3",
#  "dp","dp2","dp3","pres","bmptemp","dietemp","objtemp","lux",
#  "didx","didx2","didx3"
#]


###
### データの取得とグラフの作成
### 

# 配列の初期化
ops = ["mean", "min", "max", "stddev", "median"]
time_list = Array.new
temp_list = Hash.new
humi_list = Hash.new
pres_list = Hash.new
didx_list = Hash.new

# csv ファイルの読み込み. 配列化. 統計量ごとにファイルが異なる.
ops.each do |op|
    
  # 初期化
  time_list     = Array.new
  temp_list[op] = Array.new
  humi_list[op] = Array.new
  pres_list[op] = Array.new
  didx_list[op] = Array.new
  
  CSV.foreach( "#{srcdir}/#{myid}_#{op}.csv" ) do |item|
    time_list.push( item[0] )           # 時刻
    temp_list[op].push( item[1].to_f )  # 温度
    humi_list[op].push( item[4].to_f )  #humidity
    pres_list[op].push( item[10].to_f )  #pressure 
    didx_list[op].push( item[15].to_f )  #discomfort index 
  end
end

###
### 1 日ごとの統計量. テーブル化
###

html = open( "#{pubdir}/table.html", "w" )
html.puts <<EOS
<html>
<head> </head>
<body>
<h1>#{myid} 温度情報</h1>
<table border="1" >
<tr>
  <th rownspan = 2>年月日</th>
  <th>気圧</th>
  <th colspan = 4>気温</th>
  <th colspan = 2>湿度</th>
  <th colspan = 3>不快指数</th>
</tr>
<tr>
  <th></th>
  <th>平均</th>
  <th>平均（２４時間）</th>
  <th>平均（日中）</th>
  <th>最低</th>
  <th>最高</th>
  <th>平均</th>
  <th>最小</th>
  <th>平均</th>
  <th>最高</th>
  <th>最低</th>
</tr>
EOS

time_list.size.times{|i|

  # 欠損値 (999.9) の部分は "-" に置き換える. 
  if temp_list["mean"][i] == miss 
    mean_24  = "-"
    mean_day = "-"
    max   = "-"
    min   = "-"
  elsif humi_list["mean"][i] == miss
    mean_humi = "-"
    min_humi = "-"
  elsif pres_list["mean"][i] == miss
    mean_pres = "-"
  elsif didx_list["mean"][i] == miss
    mean_didx = "-"
    max_didx = "-"
    min_didx = "-"
  else
    mean_24  = sprintf('%.2f',temp_list["mean"][i])
    mean_day  = sprintf('%.2f',temp_list["mean"][i])
    max   = sprintf('%.2f',temp_list["max"][i])
    min   = sprintf('%.2f',temp_list["min"][i])
    mean_humi   = sprintf('%.2f',humi_list["mean"][i])
    min_humi   = sprintf('%.2f',humi_list["min"][i])
    mean_pres   = sprintf('%.2f',pres_list["mean"][i])
    mean_didx   = sprintf('%.2f',didx_list["mean"][i])
    max_didx   = sprintf('%.2f',didx_list["max"][i])
    min_didx   = sprintf('%.2f',didx_list["min"][i])
  end
  
  html.puts <<EOS
  <tr>
    <td>#{time_list[i]}</td>
    <td>#{mean_pres}</td>
    <td>#{mean_24}</td>
    <td>#{mean_day}</td>
    <td>#{min}</td>
    <td>#{max}</td>
    <td>#{mean_humi}</td>
    <td>#{min_humi}</td>
    <td>#{mean_didx}</td>
    <td>#{max_didx}</td>
    <td>#{min_didx}</td>
  </tr>
EOS
}

# フッタ  
html.puts <<EOS
<hr>
</table>
Jovian, #{DateTime.now}
</body>
</html>

EOS

html.close
