#!/usr/bin/env ruby
# coding: utf-8
#
# 表題: データ解析スクリプト. 10 分平均から 1 日平均を作る.
#

require 'csv'
require 'narray'
require 'date'
require 'fileutils'

###
### デバイス毎の設定
###

# デバイス名
myid = ARGV[0] 

# 公開ディレクトリ
pubdir = "/iotex/graph_1week/#{myid}"


###
### 初期化
###

# データ置き場
srcdir = "/iotex/data_csv_10min/#{myid}/"

# 公開ディレクトリの作成
pubdir_temp = "#{pubdir}/temp/#{time_from.strftime("%Y-%m")}"
pubdir_humi = "#{pubdir}/humi/#{time_from.strftime("%Y-%m")}"
pubdir_didx = "#{pubdir}/didx/#{time_from.strftime("%Y-%m")}"
FileUtils.mkdir_p( pubdir_temp ) until FileTest.exists?( pubdir_temp )
FileUtils.mkdir_p( pubdir_humi ) until FileTest.exists?( pubdir_humi )
FileUtils.mkdir_p( pubdir_didx ) until FileTest.exists?( pubdir_didx )

# 欠損値
miss = 999.9


###
### データの取得とグラフの作成
### 
  
# 配列の初期化
time_list = Array.new
temp_list = Array.new #温度
humi_list = Array.new #湿度
didx_list = Array.new #不快係数
vars_list = Array.new
num = vars.size - 1 # 時刻分を除く
num.times do |i|
  vars_list[i] = Array.new
end

(DateTime.parse('#{ARGV[2]')..DateTime.now).each do |time_from|
 # csv ファイルの読み込み. 配列化
 Dir.glob("#{srcdir}/*csv").sort.each do |csvfile|
   CSV.foreach( csvfile ) do |item|
 #    p item
    
    # 時刻. DateTime オブジェクト化.
    time = DateTime.parse( "#{item[0]} JST" )
    
     # 7日分の毎正時のデータを取得.
     if time >= time_from && time <= time_from + 1 && time.min == 0
       time_list.push( time )  # 時刻
       num.times do |i|
         vars_list[i].push( item[i+1].to_f ) #各データ
       end
     end
   end
 end

 next if temp_list.min == temp_list.max

 # NArray オブジェクトへ変換. 解析が容易になる. 
 Numo.gnuplot do
   set title:    "#{ARCV[1]} (温度)
   set ylabel:   "temperature (C)"
   set xlabel:   "time"
   set xdata:    "time"
   set timefmt_x:"%Y-%m-%dT%H:%M:%S+09:00"
   set format_x: "%Y/%m/%d"
   set xtics:    "rotate by -60"
   set terminal: "png"
   set output:   "#{pubdir}/temp/#{myid}_temp_#{time_from.strftime("%Y%m%d")}.png"
   set :datafile, :missing, "#{miss}" # 欠損値
   set key: "box" #凡例あり
   set key: "below" #凡例あり
   plot time_list, temp_list, using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2
 end

 # 湿度グラフ作成
  Numo.gnuplot do
    #    debug_on
    set title:    "#{ARGV[1]} (湿度)"
    set ylabel:   "humidity (%)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir_humi}/#{myid}_humi_#{time_from.strftime("%Y%m%d")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set :nokey # 凡例なし

    plot time_list, humi_list, using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2
  end

  # 不快指数グラフ作成
  Numo.gnuplot do
    #    debug_on
    set title:    "#{ARGV[1]} (不快指数)"
    set ylabel:   "discomfort index"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir_didx}/#{myid}_didx_#{time_from.strftime("%Y%m%d")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set :nokey # 凡例なし

    plot time_list, didx_list, using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:2
  end
end

