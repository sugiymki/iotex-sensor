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

###
### 初期化
###

# 欠損値
miss = 999.9

###
### データの取得とグラフの作成
### 

(DateTime.parse("#{ARGV[0]}")..DateTime.now).select{|d| d.wday==0}.each do |time_from|
  
  time_list = Hash.new
  temp_list = Hash.new
  humi_list = Hash.new
  didx_list = Hash.new

  # 公開ディレクトリ
  pubdir = "/iotex/compare_1week/iot-28_iot-27_iot-31_iot-30_iot-29"
    
  pubdir_temp = "#{pubdir}/temp/#{time_from.strftime("%Y")}"
  FileUtils.mkdir_p( pubdir_temp ) until FileTest.exists?( pubdir_temp )
  pubdir_humi = "#{pubdir}/humi/#{time_from.strftime("%Y")}"
  FileUtils.mkdir_p( pubdir_humi ) until FileTest.exists?( pubdir_humi )
  pubdir_didx = "#{pubdir}/didx/#{time_from.strftime("%Y")}"
  FileUtils.mkdir_p( pubdir_didx ) until FileTest.exists?( pubdir_didx )
  
  #csvファイルから指定された時刻を読み込み,配列化
  ["iot-28","iot-27","iot-31","iot-30","iot-29"].each do |myid|
    
    
    # データ置き場
    srcdir = "/iotex/data_csv_10min/#{myid}/"
    
    #配列の初期化
    time_list[myid] = Array.new
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
          time_list[myid].push( time )  # 温度
          temp_list[myid].push( item[1].to_f )  # 温度
          humi_list[myid].push( item[4].to_f )  # 湿度
          didx_list[myid].push( item[15].to_f ) # 不快係数
        end
      end
    end
  end

#  p "plot from #{time_list[myid][0] .. #{time_list[myid][-1]}"
  
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
    set output:   "#{pubdir_temp}/iot-28_iot-27_iot-31_iot-30_iot-29_temp_#{time_from.strftime("%Y")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    #set :nokey # 凡例なし
     set key: "box" #凡例あり
    
    plot [time_list["iot-28"], temp_list["iot-28"], using:'1:($2)', with:"lines", lc_rgb:"red", lw:2, title:"512教室" ],
         [time_list["iot-27"], temp_list["iot-27"], using:'1:($2)', with:"lines", lc_rgb:"blue", lw:2, title:"511教室"],
         [time_list["iot-31"], temp_list["iot-31"], using:'1:($2)', with:"lines", lc_rgb:"green", lw:2, title:"541教室"],
         [time_list["iot-30"], temp_list["iot-30"], using:'1:($2)', with:"lines", lc_rgb:"yellow", lw:2, title:"522教室"],
         [time_list["iot-29"], temp_list["iot-29"], using:'1:($2)', with:"lines", lc_rgb:"black", lw:2, title:"521教室"]
  end

  # 湿度グラフ作成.
  Numo.gnuplot do
    #    debug_on
    set ylabel:   "humidity (%)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir_humi}/iot-28_iot-27_iot-31_iot-30_iot-29_humi_#{time_from.strftime("%Y")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    #set :nokey # 凡例なし
     set key: "box" #凡例あり
    
    plot [time_list["iot-28"], humi_list["iot-28"], using:'1:($2)', with:"lines", lc_rgb:"red", lw:2, title:"512教室" ],
         [time_list["iot-27"], humi_list["iot-27"], using:'1:($2)', with:"lines", lc_rgb:"blue", lw:2, title:"511教室"],
         [time_list["iot-31"], humi_list["iot-31"], using:'1:($2)', with:"lines", lc_rgb:"green", lw:2, title:"541教室"],
         [time_list["iot-30"], humi_list["iot-30"], using:'1:($2)', with:"lines", lc_rgb:"yellow", lw:2, title:"522教室"],
         [time_list["iot-29"], humi_list["iot-29"], using:'1:($2)', with:"lines", lc_rgb:"black", lw:2, title:"521教室"]
  end

  # 不快指数グラフ作成.
  Numo.gnuplot do
    #    debug_on
    set ylabel:   "discomfort index"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir_didx}/iot-28_iot-27_iot-31_iot-30_iot-29_didx_#{time_from.strftime("%Y")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    #set :nokey # 凡例なし
     set key: "box" #凡例あり
    
    plot [time_list["iot-28"], didx_list["iot-28"], using:'1:($2)', with:"lines", lc_rgb:"red", lw:2, title:"512教室" ],
         [time_list["iot-27"], didx_list["iot-27"], using:'1:($2)', with:"lines", lc_rgb:"blue", lw:2, title:"511教室"],
         [time_list["iot-31"], didx_list["iot-31"], using:'1:($2)', with:"lines", lc_rgb:"green", lw:2, title:"541教室"],
         [time_list["iot-30"], didx_list["iot-30"], using:'1:($2)', with:"lines", lc_rgb:"yellow", lw:2, title:"522教室"],
         [time_list["iot-29"], didx_list["iot-29"], using:'1:($2)', with:"lines", lc_rgb:"black", lw:2, title:"521教室"]
  end
end

