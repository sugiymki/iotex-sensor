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
pubdir = "/iotex/graph_1month/#{myid}" 


###
### 初期化
###


# データ置き場
  srcdir = "/iotex/graph_1month/#{myid}/csv" 

# 公開ディレクトリの作成
#  FileUtils.rm_rf(   pubdir ) if    FileTest.exists?( pubdir )
  FileUtils.mkdir_p( pubdir ) until FileTest.exists?( pubdir )

# 欠損値
  miss = 999.9


###
### データの取得とグラフの作成
### 

(DateTime.parse("#{ARGV[2]}")..DateTime.now).select{|d| d.day==1}.each do |time_from|

  pubdir_temp = "#{pubdir}/temp/#{time_from.strftime("%Y")}"
  pubdir_humi = "#{pubdir}/humi/#{time_from.strftime("%Y")}"
  pubdir_didx = "#{pubdir}/didx/#{time_from.strftime("%Y")}"
  
  FileUtils.mkdir_p( pubdir_temp ) until FileTest.exists?(pubdir_temp )
  FileUtils.mkdir_p( pubdir_humi ) until FileTest.exists?(pubdir_humi )
  FileUtils.mkdir_p( pubdir_didx ) until FileTest.exists?(pubdir_didx )

  # ハッシュと配列の初期化
  ops = ["mean", "mean2", "min", "max"]
  time_list = Array.new #時刻
  temp_list = Hash.new #温度
  humi_list = Hash.new #湿度
  didx_list = Hash.new #不快係数
    
  # csv ファイルから指定された時刻を読み込み. 配列化
  ops.each do |op|
    time_list = Array.new #時刻
    temp_list[op] = Array.new #温度
    humi_list[op] = Array.new #湿度
    didx_list[op] = Array.new #不快係数

    CSV.foreach( "#{srcdir}/#{myid}_#{op}_kadai4.csv" ) do |item|

      # 時刻. DateTime オブジェクト化.
      time = DateTime.parse( "#{item[0]} JST" )

      # 指定された時刻より後のデータを取得.
      if time >= time_from && time.month == time_from.month
        time_list.push( time )          # 時刻        
        temp_list[op].push( item[1].to_f )  # 温度
        humi_list[op].push( item[4].to_f )  # 湿度
        didx_list[op].push( item[15].to_f ) # 不快係数
      end
    end
  end
  p "plot from #{time_list[0]} to #{time_list[-1]}"

  next if temp_list.min == temp_list.max
  
  # 温度グラフ作成.
  Numo.gnuplot do
    set title:	  "#{ARGV[1]} (温度)"
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


    plot [time_list, temp_list["mean"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:3, title:"mean"],
         [time_list, temp_list["mean2"], using:'1:($2)', with:"linespoints", lc_rgb:"yellow", lw:3, title:"mean2"],
         [time_list, temp_list["min"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:3, title:"min"],
         [time_list, temp_list["max"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:3, title:"max"]
  end

  # 湿度グラフ作成.
  Numo.gnuplot do
    set title:	  "#{ARGV[1]} (湿度)"
    set ylabel:   "humidity (%)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir_humi}/#{myid}_humi_#{time_from.strftime("%Y%m%d")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set key: "box" #凡例あり

    plot [time_list, humi_list["mean"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:3, title:"mean"],
         [time_list, humi_list["mean2"], using:'1:($2)', with:"linespoints", lc_rgb:"yellow", lw:3, title:"mean2"],
         [time_list, humi_list["min"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:3, title:"min"],
         [time_list, humi_list["max"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:3, title:"max"]
  end


  # 不快指数グラフ作成 (各自で書くこと).
  Numo.gnuplot do
    set title:	  "#{ARGV[1]} (不快指数)"
    set ylabel:   "discomfort index"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%m/%d %H:%M"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir_didx}/#{myid}_didx_#{time_from.strftime("%Y%m%d")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set key: "box" #凡例あり

    plot [time_list, didx_list["mean"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:3, title:"mean"],
         [time_list, didx_list["mean2"], using:'1:($2)', with:"linespoints", lc_rgb:"yellow", lw:3, title:"mean2"],
         [time_list, didx_list["min"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:3, title:"min"],
         [time_list, didx_list["max"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:3, title:"max"]
  end
end
