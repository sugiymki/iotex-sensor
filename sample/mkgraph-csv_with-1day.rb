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
myid =ARGV[0] 

# 公開ディレクトリ
pubdir="/iotex/graph_1month/#{myid}"
# データ置き場
#srcdir="/iotex/graph_1month/#{myid}/"
srcdir="/home/j1428/public_html/data_csv_1day"


###
### 初期化
###
# 公開ディレクトリの作成
#FileUtils.rm_rf(   pubdir ) if    FileTest.exists?( pubdir )
#FileUtils.mkdir_p(pubdir) until FileTest.exists?(pubdir)
pubdir_temp="#{pubdir}/temp/#{time_from.strftime("%Y-%m")}"
FileUtils.mkdir_p( pubdir_temp ) until FileTest.exists?( pubdir_temp )
pubdir_humi="#{pubdir}/humi/#{time_from.strftime("%Y-%m")}"
FileUtils.mkdir_p( pubdir_humi ) until FileTest.exists?( pubdir_humi )
pubdir_didx="#{pubdir}/didx/#{time_from.strftime("%Y-%m")}"
FileUtils.mkdir_p( pubdir_didx ) until FileTest.exists?( pubdir_didx )


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

# 7, 30, 90, 120, 240, 360 日の幅で描画  
#[7, 30, 90, 120, 240, 360].each do |range|
#  p "#{range} days"
(DateTime.parse("#ARGV[2]}")..DateTime.now).select{|d| d.day==1}.each do 
|time_from|
  # 描画範囲
#  time_from = DateTime.now - range
  
  # 配列の初期化
  ops = ["mean", "min", "max"]
  time_list = Array.new
  temp_list = Hash.new
  humi_list =Hash.new
didx_lish=Hash.new

temp_list["mean"]=Array.new
humi_lish["mean"]=Array.new
didx_list["mean"]=Array.new
  
temp_list["mean2"]=Array.new
humi_list["mean2"]=Array.new
didx_list["mean2"]=Array.new

temp_list["max"]=Array.new
humi_list["max"]=Array.new
didx_list["max"]=Array.new

temp_list["min"]=Array.new
humi_list["min"]=Array.new
didx_list["min"]=Array.new
  # csv ファイルの読み込み. 配列化. 統計量ごとにファイルが異なる.
  ops.each do |op|
    
    # 初期化
    time_list     = Array.new
    temp_list[op] = Array.new

    CSV.foreach( "#{srcdir}/#{myid}_#{op}.csv" ) do |item|

      time = DateTime.parse( "#{item[0]} 00:00:00 JST" ) # 時刻
        
      # 指定期間のデータのみ配列化 (7日毎の値)
      if time>=time_from&&time<=time_from+1&&time.min==0

        time_list.push( time )              # 時刻
        temp_list[op].push( item[1].to_f )  # 温度
      end
    end
  end
  p "plot from #{time_list[0]} to #{time_list[-1]}"
  
  ###
  ### 1 日ごとの統計量. グラフ化. 
  ###

  # 平均値, 最小値, 最大値の比較のグラフ
  Numo.gnuplot do
    set title: "#{ARGV[1]}"
    set ylabel:   "temperature (C)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+09:00"
    set format_x: "%Y/%m/%d"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir}/#{myid}_#{op}_#{time_from.strftime("%Y%m%d")}.png"
    set key: "box"
    set :datafile, :missing, "999.9"
    
    plot [time_list, temp_list["mean"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:3, title:"mean"],
         [time_list, temp_list["min"],  using:'1:($2)', with:"linespoints", lc_rgb:"blue",  lw:3, title:"min "],
         [time_list, temp_list["max"],  using:'1:($2)', with:"linespoints", lc_rgb:"red",   lw:3, title:"max "]
         [time_list, temp_list["mean2"],  using:'1:($2)', with:"linespoints", lc_rgb:"black",   lw:3, title:"mean2 "]

  end   


  # 平均値と中央値の比較のグラフ
  # ... 自分で書く ...


  # 平均値 + 標準偏差のグラフ作成
#  Numo.gnuplot do
#    set ylabel:   "temperature (C)"
#    set xlabel:   "time"
#    set xdata:    "time"
#    set timefmt_x:"%Y-%m-%dT%H:%M:%S+09:00"
#    set format_x: "%Y/%m/%d"
#    set xtics:    "rotate by -60"
#    set terminal: "png"
#    set :nokey
#    set :datafile, :missing, "999.9"
    
#    plot time_list,temp_list["mean"],temp_list["stddev"], using:'1:2:3', with:"yerrorbars", lc_rgb:"green", lw:3
#  end  
end 
