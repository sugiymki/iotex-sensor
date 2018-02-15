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
myid = ARGV[0] 

# 公開ディレクトリ
pubdir = "/home/j1417/public_html/table-csv_with-1month/"

# データ置き場
srcdir = "/home/j1406/public_html/data_csv_1day"

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
ops = ["mean", "min", "max", "meanday"]
time_list = Array.new
atom_list = Hash.new  #気圧の平均
temp_list = Hash.new  #温度
humi_list = Hash.new  #湿度
didx_list = Hash.new  #不快指数

# csv ファイルの読み込み. 配列化. 統計量ごとにファイルが異なる.
ops.each do |op|
    
  # 初期化
  time_list     = Array.new
  atom_list[op] = Array.new
  temp_list[op] = Array.new
  humi_list[op] = Array.new
  didx_list[op] = Array.new
   
  CSV.foreach( "#{srcdir}/#{myid}_#{op}.csv" ) do |item|
    time_list.push( item[0] )           # 時刻
    atom_list[op].push( item[10].to_f )	# 気圧の平均
    temp_list[op].push( item[1].to_f )  # 温度
    humi_list[op].push( item[4].to_f )  # 湿度
    didx_list[op].push( item[15].to_f ) # 不快指数
  end
end

###
### 1 日ごとの統計量. テーブル化
###

html = open( "#{pubdir}/table.html", "w" )
html.puts <<EOS
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>
<h1>#{myid} 温度情報</h1>
<table border="1" >
<tr>
  <th rowspan="2">年月日</th>
  <th>気圧</th>
  <th colspan="4">気温</th>
  <th colspan="2">湿度</th>
  <th colspan="3">不快指数</th>
</tr>
<tr>
  <th>平均</th>
  <th>平均(24時間)</th>
  <th>平均(日中)</th>
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
    tmean  = "-"
    tmax   = "-"
    tmin   = "-"
    tmday  = "-"
  else
    tmean  = sprintf('%.2f',temp_list["mean"][i])
    tmax   = sprintf('%.2f',temp_list["max"][i])
    tmin   = sprintf('%.2f',temp_list["min"][i])
    tmday  = sprintf('%.2f',temp_list["meanday"][i])
  end
  
  if humi_list["mean"][i] == miss
    hmean  = "-"
    hmin   = "-"
  else
    hmean  = sprintf('%.2f',humi_list["mean"][i])
    hmin   = sprintf('%.2f',humi_list["min"][i])
  end

  if atom_list["mean"][i] == miss
    amean  = "-"
  else
    amean  = sprintf('%.2f',atom_list["mean"][i])
  end

  if didx_list["mean"][i] == miss
    dmean  = "-"
    dmax   = "-"
    dmin   = "-"
  else
    dmean  = sprintf('%.2f',didx_list["mean"][i])
    dmax   = sprintf('%.2f',didx_list["max"][i])
    dmin   = sprintf('%.2f',didx_list["min"][i])
  end

  html.puts <<EOS
  <tr>
    <td>#{time_list[i]}</td>
    <td>#{amean}</td>
    <td>#{tmday}</td>
    <td>#{tmean}</td>
    <td>#{tmin}</td>
    <td>#{tmax}</td>
    <td>#{hmean}</td>
    <td>#{hmin}</td>
    <td>#{dmean}</td>
    <td>#{dmax}</td>
    <td>#{dmin}</td>
  </tr>
EOS
}

# フッタ  
html.puts <<EOS
<hr>
</table>
YOUR NAME, #{DateTime.now}
</body>
</html>

EOS

html.close
