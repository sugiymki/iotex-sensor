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
t=DateTime.now
# デバイス名
#myid = "iot-16"
md="iot-15_iot-16_iot-17_iot-18"
(DateTime.parse("#{ARGV[0]}")..DateTime.now).select{|d| d.wday==0}.each do |time_from|
# 公開ディレクトリ
pubdir = "/iotex/compare_1week/iot-15_iot-16_iot-17_iot-18/" 
pubdir1 = "#{pubdir}/temp/#{time_from.year}/" 
pubdir2 = "#{pubdir}/humi/#{time_from.year}/" 
pubdir3 = "#{pubdir}/didx/#{time_from.year}/" 


###
### 初期化
###

# データ置き場
#srcdir = "/iotex/data_csv_10min/#{myid}/"

# 公開ディレクトリの作成
#FileUtils.rm_rf(   pubdir1 ) if    FileTest.exists?( pubdir1 )
FileUtils.mkdir_p( pubdir1 ) until FileTest.exists?( pubdir1 )

#FileUtils.rm_rf(   pubdir2 ) if    FileTest.exists?( pubdir2 )
FileUtils.mkdir_p( pubdir2 ) until FileTest.exists?( pubdir2 )
#FileUtils.rm_rf(   pubdir3 ) if    FileTest.exists?( pubdir3 )
FileUtils.mkdir_p( pubdir3 ) until FileTest.exists?( pubdir3 )
# 欠損値
miss = 999.9


time_list=Hash.new
temp_list=Hash.new
humi_list=Hash.new
didx_list=Hash.new


###
### データの取得とグラフの作成


["iot-15","iot-16","iot-17","iot-18"].each do |myid|
 scrdir="/iotex/data_csv_10min/#{myid}/" 
  
  # ハッシュと配列の初期化
#  time_list[#{myid}] = Array.new #時刻
#  temp_list[#{myid}] = Array.new
#  humi_list[#{myid}] = Array.new #湿度
#  didx_list[#{myid}] = Array.new #不快係数
  time_list[myid] = Array.new #時刻
  temp_list[myid] = Array.new
  humi_list[myid] = Array.new #湿度
  didx_list[myid] = Array.new #不快係数
    
  # csv ファイルから指定された時刻を読み込み. 配列化
  Dir.glob("#{scrdir}/*csv").sort.each do |csvfile|
    CSV.foreach( csvfile ) do |item|

      # 時刻. DateTime オブジェクト化.
      time = DateTime.parse( "#{item[0]} JST" )

      # 指定された時刻より後のデータを取得.
      if time >= time_from && time <=time_from + 7 && time.min==0
 #       time_list[#{myid}].push( time )          # 時刻        
 #       temp_list[#{myid}].push( item[1].to_f )  # 温度
 #       humi_list[#{myid}].push( item[4].to_f )  # 湿度
 #       didx_list[#{myid}].push( item[15].to_f ) # 不快係数
        time_list[myid].push( time )          # 時刻        
        temp_list[myid].push( item[1].to_f )  # 温度
        humi_list[myid].push( item[4].to_f )  # 湿度
        didx_list[myid].push( item[15].to_f ) # 不快係数
      end
      end
    end
end
#  p "plot from #{time_list[myid][0]} to #{time_list[myid][-1]}"
  
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
    set output:   "#{pubdir1}/#{md}_temp_#{time_from.mon}-#{time_from.day}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set :nokey # 凡例なし
    # set key: "box" #凡例あり

    plot [time_list["iot-15"], temp_list["iot-15"], using:'1:($2)', with:"lines", lc_rgb:"green", lw:3,title:"234講義室(4組)"],
     [time_list["iot-16"], temp_list["iot-16"], using:'1:($2)', with:"lines", lc_rgb:"red", lw:3,title:"235講義室(5組)前"],
     [time_list["iot-17"], temp_list["iot-17"], using:'1:($2)', with:"lines", lc_rgb:"blue", lw:3,title:"220講義室"],
     [time_list["iot-18"], temp_list["iot-18"], using:'1:($2)', with:"lines", lc_rgb:"orange", lw:3,title:"マルチメディア演習室"]
end


  Numo.gnuplot do
    #    debug_on
    set ylabel:   "humidity (%)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir2}/#{md}_humi_#{time_from.mon}-#{time_from.day}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set :nokey # 凡例なし
    # set key: "box" #凡例あり

    plot [time_list["iot-15"], humi_list["iot-15"], using:'1:($2)', with:"lines", lc_rgb:"green", lw:3,title:"234講義室(4組)"],
     [time_list["iot-16"], humi_list["iot-16"], using:'1:($2)', with:"lines", lc_rgb:"red", lw:3,title:"235講義室(5組)前"],
     [time_list["iot-17"], humi_list["iot-17"], using:'1:($2)', with:"lines", lc_rgb:"blue", lw:3,title:"220講義室"],
     [time_list["iot-18"], humi_list["iot-18"], using:'1:($2)', with:"lines", lc_rgb:"orange", lw:3,title:"マルチメディア演習室"]
end



  Numo.gnuplot do
    #    debug_on
    set ylabel:   "discomfort index (C)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir3}/#{md}_didx_#{time_from.mon}-#{time_from.mday}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set :nokey # 凡例なし
    # set key: "box" #凡例あり

    plot [time_list["iot-15"], didx_list["iot-15"], using:'1:($2)', with:"lines", lc_rgb:"green", lw:3,title:"234講義室(4組)"],
     [time_list["iot-16"], didx_list["iot-16"], using:'1:($2)', with:"lines", lc_rgb:"red", lw:3,title:"235講義室(5組)前"],
     [time_list["iot-17"], didx_list["iot-17"], using:'1:($2)', with:"lines", lc_rgb:"blue", lw:3,title:"220講義室"],
     [time_list["iot-18"], didx_list["iot-18"], using:'1:($2)', with:"lines", lc_rgb:"orange", lw:3,title:"マルチメディア演習室"]
end
end
