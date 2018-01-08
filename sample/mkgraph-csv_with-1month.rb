#!/usr/bin/env ruby
# coding: utf-8
#
# 表題: グラフ作成のためのスクリプト. CSV ファイル利用版.
#

require 'csv'
require 'date'
require "numo/gnuplot"

# 全てのデバイスについて実行
Dir.glob("/iotex/data_csv_1month/iot-*").sort.each do |dir|

  device = File.basename( dir )
  p device
  next if device == 'iot-46' || device == 'iot-47'
  
  ###
  ### 設定
  ###
    
  # ホスト名, 公開ディレクトリの設定
  myid   = device
  pubdir = "/home/sugiyama/public_html/iotex/timeline4/"
  srcdir = "/iotex/data_csv_1month/#{myid}/"

  # csv ファイルに含まれる変数の一覧
  vars = [
    "time", "temp", "temp2", "temp3", "humi", "humi2", "humi3",
    "dp", "dp2", "dp3", "pres", "bmptemp", "dietemp", "objtemp","lux",
    "didx", "didx2", "didx3"
  ]

  ops = ["mean_mean", "min_mean", "max_mean", "min_min", "max_max"]
  
  ###
  ### CSV ファイルからデータ読み込み
  ###
    
  # 配列の初期化
  temp_list = Hash.new
  time_list = Array.new
  
  # csv ファイルの読み込み. 配列化
  ops.each do |op|
    time_list = Array.new
    temp_list[op] = Array.new

    Dir.glob("#{srcdir}/#{myid}_#{op}.csv").sort.each do |csvfile|
      CSV.foreach( csvfile ) do |item|
        time_list.push( item[0] )          # 時刻の添字は 0
        temp_list[op].push( item[1].to_f ) # 温度の添字は 1
      end
    end
  end
  p time_list
  
  ###
  ### グラフ化. 
  ###
  
  Numo.gnuplot do
    #      debug_on
    set ylabel:   "temperature (C)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y/%m"
    set format_x: "%Y/%m"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir}/#{myid}_temp1_all.png"
    set key: "box"
    set :datafile, :missing, "999.9"
    
    plot [time_list,temp_list["mean_mean"],using:'1:($2)',with:"linespoints",lc_rgb:"green", lw:3, title:"mean"],
         [time_list,temp_list["min_mean"], using:'1:($2)',with:"linespoints",lc_rgb:"blue",  lw:3, title:"min "],
         [time_list,temp_list["max_mean"], using:'1:($2)',with:"linespoints",lc_rgb:"red",   lw:3, title:"max "]
  end   

  Numo.gnuplot do
    #      debug_on
    set ylabel:   "temperature (C)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y/%m"
    set format_x: "%Y/%m"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir}/#{myid}_temp2_all.png"
    set key: "box"
    set :datafile, :missing, "999.9"
    
    plot [time_list,temp_list["mean_mean"],using:'1:($2)',with:"linespoints",lc_rgb:"green", lw:3, title:"mean"],
         [time_list,temp_list["min_mean"], using:'1:($2)',with:"linespoints",lc_rgb:"blue",  lw:3, title:"min "],
         [time_list,temp_list["max_mean"], using:'1:($2)',with:"linespoints",lc_rgb:"red",   lw:3, title:"max "],
         [time_list,temp_list["min_min"],  using:'1:($2)',with:"linespoints",lc_rgb:"navy",  lw:3, title:"min(min) "],
         [time_list,temp_list["max_max"],  using:'1:($2)',with:"linespoints",lc_rgb:"purple",lw:3, title:"max(max) "]
  end   
end

