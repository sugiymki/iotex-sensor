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

# 公開ディレクトリ

pubdir = "/iotex/compare_1week/iot-22_iot-35_iot26_iot43_iot32/"
pubdir1 = "#{pubdir}temp/2018/" 
pubdir2 = "#{pubdir}humi/2018/" 
pubdir3 = "#{pubdir}didx/2018/" 

###
### 初期化
###

# 公開ディレクトリの作成
  
FileUtils.rm_rf(   pubdir ) if    FileTest.exists?( pubdir )
FileUtils.rm_rf(   pubdir1 ) if    FileTest.exists?( pubdir1 )
FileUtils.rm_rf(   pubdir2 ) if    FileTest.exists?( pubdir2 )
FileUtils.rm_rf(   pubdir3 ) if    FileTest.exists?( pubdir3 )

FileUtils.mkdir_p( pubdir ) until FileTest.exists?( pubdir )
FileUtils.mkdir_p( pubdir1 ) until FileTest.exists?( pubdir1 )
FileUtils.mkdir_p( pubdir2 ) until FileTest.exists?( pubdir2 )
FileUtils.mkdir_p( pubdir3 ) until FileTest.exists?( pubdir3 )

time_list = Hash.new 
temp_list = Hash.new
humi_list = Hash.new
didx_list = Hash.new

# 欠損値
miss = 999.9

(DateTime.parse("#{ARGV[0]}")..DateTime.now).select{|d| d.wday==0}.each do |time_from|
  
  ["iot-22","iot-35","iot-26","iot-43","iot-32"].each do |myid|
    # ハッシュと配列の初期化
    time_list[myid] = Array.new #時刻
    temp_list[myid] = Array.new #温度
    didx_list[myid] = Array.new #不快係数
    humi_list[myid] = Array.new #湿度
    
    # データ置き場
    srcdir = "/iotex/data_csv_10min/#{myid}/"
    
    # csv ファイルから指定された時刻を読み込み. 配列化
    Dir.glob("#{srcdir}/*csv").sort.each do |csvfile|
      CSV.foreach( csvfile ) do |item|
        
        # 時刻. DateTime オブジェクト化.
        time = DateTime.parse( "#{item[0]} JST" )
        
        # 指定された時刻より後のデータを取得.
        if time >= time_from && time <= time_from + 7 && time.min ==0
          time_list[myid].push( time )          # 時刻        
          temp_list[myid].push( item[1].to_f )  # 温度
          humi_list[myid].push( item[4].to_f )  # 湿度
          didx_list[myid].push( item[15].to_f ) # 不快係数
        end
      end
    end
  end
  p "plot from #{time_list["iot-22"][0]} to #{time_list["iot-22"][-1]}"
  
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
    set output:   "#{pubdir1}iot-22_iot-26_iot_32_iot_35_iot43_temp_#{time_from}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set :nokey # 凡例なし
    # set key: "box" #凡例あり

    plot [time_list["iot-22"], temp_list["iot-22"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:2, title:"236講義室"],
         [time_list["iot-26"], temp_list["iot-26"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"442講義室"],
         [time_list["iot-32"], temp_list["iot-32"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:2, title:"情報処理演習室"],
         [time_list["iot-35"], temp_list["iot-35"], using:'1:($2)', with:"linespoints", lc_rgb:"cyan", lw:2, title:"652ゼミナール室"],
         [time_list["iot-43"], temp_list["iot-43"], using:'1:($2)', with:"linespoints", lc_rgb:"perple", lw:2, title:"共通CAD実験室"]
  end

  # 湿度グラフ作成 (各自で書くこと).
  Numo.gnuplot do
   set ylabel:   "humidity (%)"
   set xlabel:   "time"
   set xdata:    "time"
   set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
   set format_x: "%m/%d %H:%M"
   set xtics:    "rotate by -60"
   set terminal: "png"
   set output:   "#{pubdir2}iot-22_iot-26_iot_32_iot_35_iot43_humi_#{time_from}.png"
   set :datafile, :missing, "#{miss}" # 欠損値
   set :nokey # 凡例なし
   plot [time_list["iot-22"], humi_list["iot-22"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:2, title:"236講義室"],
        [time_list["iot-26"], humi_list["iot-26"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"442講義室"],
        [time_list["iot-32"], humi_list["iot-32"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:2, title:"情報処理演習室"],
        [time_list["iot-35"], humi_list["iot-35"], using:'1:($2)', with:"linespoints", lc_rgb:"cyan", lw:2, title:"652ゼミナール室"],
        [time_list["iot-43"], humi_list["iot-43"], using:'1:($2)', with:"linespoints", lc_rgb:"perple", lw:2, title:"共通CAD実験室"]
end

  # 不快指数グラフ作成 (各自で書くこと).
  Numo.gnuplot do
  set ylabel:   "didx"
  set xlabel:   "time"
  set xdata:    "time"
  set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
  set format_x: "%m/%d %H:%M"
  set xtics:    "rotate by -60"
  set terminal: "png"
  set output:   "#{pubdir3}iot-22_iot-26_iot_32_iot_35_iot43_didx_#{time_from}.png"
  set :datafile, :missing, "#{miss}" # 欠損値
  set :nokey # 凡例なし
  plot  [time_list["iot-22"], humi_list["iot-22"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:2, title:"236講義室"],
        [time_list["iot-26"], humi_list["iot-26"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"442講義室"],
        [time_list["iot-32"], humi_list["iot-32"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:2, title:"情報処理演習室"],
        [time_list["iot-35"], humi_list["iot-35"], using:'1:($2)', with:"linespoints", lc_rgb:"cyan", lw:2, title:"652ゼミナール室"],
        [time_list["iot-43"], humi_list["iot-43"], using:'1:($2)', with:"linespoints", lc_rgb:"perple", lw:2, title:"共通CAD実験室"]
end

end
