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
myid = ARGV[0]

# 公開ディレクトリ
pubdir = "/iotex/graph_1month/#{myid}/" 


###
### 初期化
###

# データ置き場
srcdir = "/iotex/graph_1month/#{myid}/"

# 公開ディレクトリの作成
FileUtils.rm_rf(   pubdir ) if    FileTest.exists?( pubdir )
FileUtils.mkdir_p( pubdir ) until FileTest.exists?( pubdir )

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
  
  # ハッシュと配列の初期化
  time_list = Array.new #時刻
  temp_list = Array.new #温度
  humi_list = Array.new #湿度
  didx_list = Array.new #不快係数
    
  # csv ファイルから指定された時刻を読み込み. 配列化
  Dir.glob("#{srcdir}/*csv").sort.each do |csvfile|
    CSV.foreach( csvfile ) do |item|

      # 時刻. DateTime オブジェクト化.
      time = DateTime.parse( "#{item[0]} JST" )

      # 指定された時刻より後のデータを取得.
      if time >= time_from
        time_list.push( time )          # 時刻        
        temp_list.push( item[1].to_f )  # 温度
        humi_list.push( item[4].to_f )  # 湿度
        didx_list.push( item[15].to_f ) # 不快係数
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

    plot time_list, temp_list, using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:3
  end

  # 湿度グラフ作成 (各自で書くこと).
  Numo.gnuplot do
    #    debug_on
    set ylabel:   "humidity (%)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir}/#{myid}_humi_#{range}days.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set :nokey # 凡例なし
    # set key: "box" #凡例あり

    plot time_list, humi_list, using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:3
  end


  # 不快指数グラフ作成 (各自で書くこと).
  Numo.gnuplot do
    #    debug_on
    set ylabel:   "didx"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir}/#{myid}_didx_#{range}days.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set :nokey # 凡例なし
    # set key: "box" #凡例あり

    plot time_list, didx_list, using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:3
  end

  
end
