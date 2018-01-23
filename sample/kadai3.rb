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
pubdir = "/home/sugiyama/public_html/graph-csv_with-10min" 

###
### 初期化
###

(DataTime.parse("#{ARGV[0]}")..DateTime.now).select{|d| d.wday==0}.each do |time_from|

# 公開ディレクトリの作成(年を付与)
pubdir_temp = "#{pubdir}/temp/#{time_from_strftime("%Y")}"
FileUtils.mkdir_p( pubdir_temp ) until FileTest.exits?( pubdir_temp )
pubdir_humi = "#{pubdir}/humi/#{time_from_strftime("%Y")}"
FileUtils.mkdir_p( pubdir_humi ) until FileTest.exits?( pubdir_humi )
pubdir_didx = "#{pubdir}/didx/#{time_from_strftime("%Y")}"
FileUtils.mkdir_p( pubdir_didx ) until FileTest.exits?( pubdir_didx )

temp2_list = Hash.new

# 欠損値
miss = 999.9


###
### データの取得とグラフの作成
### 

# 7, 30, 90, 120, 360 日の幅で描画
[7,30,90,120,240,360].each do |range|
  p "#{range} days"
  
  # 描画範囲
  time_from = DateTime.now - range

#csvファイルから指定された時刻を読み込み,配列化
["iot-28","iot-27","iot-31","iot-30","iot-29"].each do |myid|

  # データ置き場
  srcdir = "/iotex/data_csv_10min/#{myid}/"
  
  #配列の初期化
  temp_list[myid] = Array.new #温度
  humi_list[myid] = Array.new #湿度
  didx_list[myid] = Array.new #不快係数
    
  # csv ファイルから指定された時刻を読み込み. 配列化
  Dir.glob("#{srcdir}/*csv").sort.each do |csvfile|
    CSV.foreach( csvfile ) do |item|

      # 時刻. DateTime オブジェクト化.
      time = DateTime.parse( "#{item[0]} JST" )

      # 指定された時刻より後のデータを取得.
      if time >= time_from && time <= time_from + 7 && time.min ==0
        temp_list[myid].push( item[1].to_f )  # 温度
        humi_list[myid].push( item[4].to_f )  # 湿度
        didx_list[myid].push( item[15].to_f ) # 不快係数
      end
    end
  end
end

  p "plot from #{time_list[0]} to #{time_list[-1]}"
  
  # 温度グラフ作成.
  Numo.gnuplot do
    #    debug_on
    set ylabel:   "temperature (C)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir}/#{myid}_temp_#{range}days.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set :nokey # 凡例なし
    # set key: "box" #凡例あり

    plot [time_list["iot-28"], temp_list, using:'1:($2)', with:"lines", lc_rgb:"red", lw2, title:""],
    plot [time_list["iot-27"], temp_list, using:'1:($2)', with:"lines", lc_rgb:"blue", lw2, title:""],
    plot [time_list["iot-31"], temp_list, using:'1:($2)', with:"lines", lc_rgb:"green", lw2, title:""],
    plot [time_list["iot-30"], temp_list, using:'1:($2)', with:"lines", lc_rgb:"yellow", lw2, title:""],
    plot [time_list["iot-29"], temp_list, using:'1:($2)', with:"lines", lc_rgb:"black", lw2, title:""],
  end

  # 湿度グラフ作成 (各自で書くこと).


  # 不快指数グラフ作成 (各自で書くこと).

  
end
