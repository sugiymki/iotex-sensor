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
myid = "iot-01"

# 公開ディレクトリ
pubdir = "/home/sugiyama/public_html/table-csv_with-1day/"

# データ置き場
srcdir = "/home/sugiyama/public_html/data_csv_1day"


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

# csv ファイルの読み込み. 配列化. 統計量ごとにファイルが異なる.
ops.each do |op|
    
  # 初期化
  time_list     = Array.new
  temp_list[op] = Array.new
  
  CSV.foreach( "#{srcdir}/#{myid}_#{op}.csv" ) do |item|
    time_list.push( item[0] )           # 時刻
    temp_list[op].push( item[1].to_f )  # 温度
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
  <th>日時</th>
  <th>平均</th>
  <th>最小</th>
  <th>最大</th>
  <th>中央値</th>
  <th>標準偏差</th>
</tr>
EOS

time_list.size.times{|i|

  # 欠損値 (999.9) の部分は "-" に置き換える. 
  if temp_list["mean"][i] == miss 
    mean  = "-"
    max   = "-"
    min   = "-"
    median= "-"
    stddev= "-"
  else
    mean  = sprintf('%.2f',temp_list["mean"][i])
    max   = sprintf('%.2f',temp_list["max"][i])
    min   = sprintf('%.2f',temp_list["min"][i])
    median= sprintf('%.2f',temp_list["median"][i])
    stddev= sprintf('%.2f',temp_list["stddev"][i])
  end
  
  html.puts <<EOS
  <tr>
    <td>#{time_list[i]}</td>
    <td>#{mean}</td>
    <td>#{min}</td>
    <td>#{max}</td>
    <td>#{median}</td>
    <td>#{stddev}</td>
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
