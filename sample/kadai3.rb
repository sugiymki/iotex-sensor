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
ourids = ["iot-xx","iot-yy","iot-zz","iot-ww"]

# 公開ディレクトリ
#pubdir = "/iotex/compare_1week/"     # 本番
pubdir = "/iotex/compare_1week/test/"  # テスト用

i=0
for id in ourids
   if i != 0 then
	  pubdir += "_"
   end
   pubdir += id
   i = 1
end

###
### 初期化
###

# データ置き場
srcdirs = []
for id in ourids
   srcdirs.push("/iotex/data_csv_10min/#{id}")
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
  
  # ハッシュと配列の初期化
  time_list = Array.new #時刻
  temp_list = Array.new #温度
  humi_list = Array.new #湿度
  didx_list = Array.new #不快係数
  temp2_list = Array.new #温度
  
  # csv ファイルから指定された時刻を読み込み. 配列化
  Dir.glob("#{srcdirs[0]}/*csv").sort.each do |csvfile|
    CSV.foreach( csvfile ) do |item|

      # 時刻. DateTime オブジェクト化.
      time = DateTime.parse( "#{item[0]} JST" )

      # 指定された時刻より後のデータを取得. 1 日分取り出す. 毎正時のみ. 
      if time >= time_from && time <= time_from + 1 && time.min == 0
        time_list.push( time )          # 時刻        
        temp_list.push( item[1].to_f )  # 温度
        temp2_list.push( item[2].to_f )  # 温度
        humi_list.push( item[4].to_f )  # 湿度
        didx_list.push( item[15].to_f ) # 不快係数
      end
    end
  end
  p "plot from #{time_list[0]} to #{time_list[-1]}"

  next if temp_list.min == temp_list.max
    
  # 温度グラフ作成.
  Numo.gnuplot do
    #    debug_on
    set title:    "#{ARGV[1]} (温度)"
    set ylabel:   "temperature (C)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir_temp}/#{myid}_temp_#{time_from.strftime("%Y%m%d")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set key: "box" #凡例あり
    set key: "below" #凡例あり
    
    plot time_list, temp_list, using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"hogehoge"
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
