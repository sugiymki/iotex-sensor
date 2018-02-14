#!/usr/bin/env ruby
# coding: utf-8
#
# 表題: チームメンバーのセンサーデータを重ね書きした部屋同士のデータの比較図
#       10分平均値のcsvファイルからを1週間毎のグラフを作成する. 
#

require 'csv'
require 'date'
require 'fileutils'
require 'numo/gnuplot'

###
### デバイス毎の設定
###

# デバイス名
#myid = ARGV[0]
ourids = ["iot-45","iot-14","iot-34","iot-44"]
room_names = { ourids[0]=>"235講義室", ourids[1]=>"杉山Lab",\
               ourids[2]=>"421講義室", ourids[3]=>"231講義室後ろ"}
# デバイスに対応した線の色
colors = {ourids[0]=>"red",ourids[1]=>"blue",ourids[2]=>"green",ourids[3]=>"yellow"}

# 公開ディレクトリ
#pubdir = "/iotex/compare_1week/"     # 本番
pubdir = "/iotex/compare_1week/test/"  # テスト用

i=0
id_dir = ""
for id in ourids
   if i != 0 then
	  id_dir += "_"
   end
   id_dir += id
   i = 1
end
pubdir += id_dir

###
### 初期化
###

# データ置き場
srcdirs = Hash.new
for id in ourids
   srcdirs[id] = "/iotex/data_csv_10min/#{id}"
end

# 欠損値
miss = 999.9


###
### データの取得とグラフの作成
###

# 日曜 (wday=0) の日付を選ぶ
(DateTime.parse("#{ARGV[0]}")..DateTime.now).select{|d| d.wday==0}.each do |time_from|  
  
  # 公開ディレクトリの作成
  pubdir_temp = "#{pubdir}/temp/#{time_from.strftime("%Y-%m")}"
  pubdir_humi = "#{pubdir}/humi/#{time_from.strftime("%Y-%m")}"
  pubdir_didx = "#{pubdir}/didx/#{time_from.strftime("%Y-%m")}"
  FileUtils.mkdir_p( pubdir_temp ) until FileTest.exists?( pubdir_temp )
  FileUtils.mkdir_p( pubdir_humi ) until FileTest.exists?( pubdir_humi )
  FileUtils.mkdir_p( pubdir_didx ) until FileTest.exists?( pubdir_didx )

  # ハッシュの初期化 list={}
  time_list = Hash.new
  temp_list = Hash.new
  humi_list = Hash.new
  didx_list = Hash.new

  for id in ourids
 	 # 配列の初期化 list={0:[],1:[],...,i:[]}
 	 time_list[id] = Array.new #時刻
 	 temp_list[id] = Array.new #温度
 	 humi_list[id] = Array.new #湿度
 	 didx_list[id] = Array.new #不快係数
 	 
 	 # csv ファイルから指定された時刻を読み込み. 配列化
 	 Dir.glob("#{srcdirs[id]}/*csv").sort.each do |csvfile|
 	   CSV.foreach( csvfile ) do |item|

 	     # 時刻. DateTime オブジェクト化.
 	     time = DateTime.parse( "#{item[0]} JST" )

 	     # 指定された時刻より後のデータを取得. 7 日分取り出す. 毎正時のみ. 
 	     if time >= time_from && time <= time_from + 7 && time.min == 0
 	       time_list[id].push( time )          # 時刻        
 	       temp_list[id].push( item[1].to_f )  # 温度
 	       #temp2_list[id].push( item[2].to_f )  # 温度
 	       humi_list[id].push( item[4].to_f )  # 湿度
 	       didx_list[id].push( item[15].to_f ) # 不快係数
 	     end
 	   end
 	 end
 	 p "plot from #{time_list[id][0]} to #{time_list[id][-1]}"
  end
  next if temp_list[ourids[0]].min == temp_list[ourids[0]].max
    
  # 温度グラフ作成.
  Numo.gnuplot do
    #    debug_on
    set title:     "#{id_dir}比較 (温度)"
    set ylabel:    "temperature (C)"
    set xlabel:    "time"
    set xdata:     "time"
    set timefmt_x: "%Y-%m-%dT%H:%M:%S+00:00"
    set format_x:  "%m/%d %H:%M"
    set xtics:     "rotate by -60"
    set terminal:  "png"
    set output:    "#{pubdir_temp}/#{id_dir}_temp_#{time_from.strftime("%Y%m%d")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set key: "box"  #凡例あり
    set key: "right" #凡例あり
    
    p "start gnuplot-temp"
    p colors[ourids[0]]
    #(0..ourids.length).each do |i|
    #    plot [time_list[id], temp_list[id], using:'1:($2)', with:"linespoints", lc_rgb:colors[id], lw:2, title:room_names[ourids[i]]]
    #end
    plot [time_list[ourids[0]], temp_list[ourids[0]], using:'1:($2)', with:"linespoints", lc_rgb:colors[ourids[0]], lw:2, title:room_names[ourids[0]]],
         [time_list[ourids[1]], temp_list[ourids[1]], using:'1:($2)', with:"linespoints", lc_rgb:colors[ourids[1]], lw:2, title:room_names[ourids[1]]],
         [time_list[ourids[2]], temp_list[ourids[2]], using:'1:($2)', with:"linespoints", lc_rgb:colors[ourids[2]], lw:2, title:room_names[ourids[2]]],
         [time_list[ourids[3]], temp_list[ourids[3]], using:'1:($2)', with:"linespoints", lc_rgb:colors[ourids[3]], lw:2, title:room_names[ourids[3]]]
    p "finish gnuplot-temp"
  end

  # 湿度グラフ作成
  Numo.gnuplot do
    #    debug_on
    set title:     "#{id_dir}比較 (湿度)"
    set ylabel:    "humidity (%)"
    set xlabel:    "time"
    set xdata:     "time"
    set timefmt_x: "%Y-%m-%dT%H:%M:%S+00:00"
    set format_x:  "%m/%d %H:%M"
    set xtics:     "rotate by -60"
    set terminal:  "png"
    set output:    "#{pubdir_humi}/#{id_dir}_humi_#{time_from.strftime("%Y%m%d")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set key: "box"  #凡例あり
    set key: "right"  #凡例あり

    #(0..ourids.length).each do |i|
    #    plot time_list[i], humi_list[i], using:'1:($2)', with:"linespoints", lc_rgb:colors[i], lw:2, title:room_names[ourids[i]]
    #end

    p "start gnuplot-humi"
    plot [time_list[ourids[0]], humi_list[ourids[0]], using:'1:($2)', with:"linespoints", lc_rgb:colors[ourids[0]], lw:2, title:room_names[ourids[0]]],
         [time_list[ourids[1]], humi_list[ourids[1]], using:'1:($2)', with:"linespoints", lc_rgb:colors[ourids[1]], lw:2, title:room_names[ourids[1]]],
         [time_list[ourids[2]], humi_list[ourids[2]], using:'1:($2)', with:"linespoints", lc_rgb:colors[ourids[2]], lw:2, title:room_names[ourids[2]]],
         [time_list[ourids[3]], humi_list[ourids[3]], using:'1:($2)', with:"linespoints", lc_rgb:colors[ourids[3]], lw:2, title:room_names[ourids[3]]]
    p "finish gnuplot-humi"

  end

  # 不快指数グラフ作成
  Numo.gnuplot do
    #    debug_on
    set title:     "#{id_dir}比較 (不快指数)"
    set ylabel:    "discomfort index"
    set xlabel:    "time"
    set xdata:     "time"
    set timefmt_x: "%Y-%m-%dT%H:%M:%S+00:00"
    set format_x:  "%m/%d %H:%M"
    set xtics:     "rotate by -60"
    set terminal:  "png"
    set output:    "#{pubdir_didx}/#{id_dir}_didx_#{time_from.strftime("%Y%m%d")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set key: "box"  #凡例あり
    set key: "right"  #凡例あり

    p "start gnuplot-didx"
    #(0..ourids.length).each do |i|
    #    plot time_list[i], didx_list[i], using:'1:($2)', with:"linespoints", lc_rgb:colors[i], lw:2, title:room_names[ourids[i]]
    #end
    plot [time_list[ourids[0]], didx_list[ourids[0]], using:'1:($2)', with:"linespoints", lc_rgb:colors[ourids[0]], lw:2, title:room_names[ourids[0]]],
         [time_list[ourids[1]], didx_list[ourids[1]], using:'1:($2)', with:"linespoints", lc_rgb:colors[ourids[1]], lw:2, title:room_names[ourids[1]]],
         [time_list[ourids[2]], didx_list[ourids[2]], using:'1:($2)', with:"linespoints", lc_rgb:colors[ourids[2]], lw:2, title:room_names[ourids[2]]],
         [time_list[ourids[3]], didx_list[ourids[3]], using:'1:($2)', with:"linespoints", lc_rgb:colors[ourids[3]], lw:2, title:room_names[ourids[3]]]
    p "finish gnuplot-didx"
  end
  
end
