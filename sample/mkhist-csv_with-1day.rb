#!/usr/bin/env ruby
# coding: utf-8
#
# 表題: ヒストグラム作成のためのスクリプト. 
#

require 'csv'
require 'date'
require 'fileutils'
require 'numo/gnuplot'

###
### デバイス毎の設定
###

# 描画対象の日時. 区切りは "-" にしておくこと. 
date = "2017-12-21"  

# デバイス名
myid = "iot-01"

# 公開ディレクトリ
pubdir = "/home/sugiyama/public_html/histgram-csv_with-1day" 

# データ置き場
srcdir = "/iotex/data_csv_10min/#{myid}/"

###
### 初期化
###

# 公開ディレクトリの作成
#FileUtils.rm_rf(   pubdir ) if    FileTest.exists?( pubdir )
FileUtils.mkdir_p( pubdir ) until FileTest.exists?( pubdir )

# 欠損値
miss = 999.9

## csv ファイルに含まれる変数の一覧
#vars = [
#  "time","temp","temp2","temp3","humi","humi2","humi3",
#  "dp","dp2","dp3","pres","bmptemp","dietemp","objtemp","lux",
#  "didx","didx2","didx3"
#]

# 日時
time_from = DateTime.parse( "#{date} 00:00:00 JST" )
time_to   = DateTime.parse( "#{date} 23:59:59 JST" )
p "plot from #{time_from} to #{time_to.to_s}"


###
### CSV ファイルからデータ読み込み
###
  
# 配列の初期化
time_list = Array.new
temp_list = Array.new
csvfile = "#{srcdir}/#{time_from.year}-#{sprintf('%02d',time_from.month)}.csv"
  
# csv ファイルの読み込み. 配列化
CSV.foreach( csvfile ) do |item|
  # 時刻
  time = DateTime.parse( "#{item[0]} JST" ) # 添字 0
  
  # 指定期間のデータのみ配列化 (1 時間毎の値)
  if time >= time_from && time <= time_to && time.min == 0
    temp_list.push( item[1].to_f )  # 添字 1
  end
end
  

###
### 1 日の頻度分布. グラフ化. 
###

bins = [0,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,40]
hist = Array.new( bins.size, 0 )

temp_list.size.times do |i|
  (bins.size-1).times do |j|
    if bins[j] <= temp_list[i] && bins[j+1] > temp_list[i]
      hist[j] += 1
      break
    end
  end
end

# 確認
bins.size.times{|i|
  p "#{bins[i]} => #{hist[i]}"
}

# ヒストグラム. 自分で書く.
# ヒストグラムの場合は plot ..., with:"boxes", ....  というように,
# with:"boxes" をオプションで与える. 

