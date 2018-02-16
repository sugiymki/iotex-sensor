#!/usr/bin/env ruby
# coding: utf-8
#
# 課題2 10分平均値のcsvファイルから,1週間毎(日曜~ 土曜) のグラフを作成.
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
pubdir = "/iotex/graph_1week/#{myid}"

###
### 初期化
###

# データ置き場
srcdir = "/iotex/data_csv_10min/#{myid}"

# 欠損値
miss = 999.9

###
### データの取得とグラフの作成
###

(DateTime.parse("#{ARGV[2]}")..DateTime.now).select{|d| d.wday==0}.each do |time_from|
  # 公開ディレクトリの作成
  pubdir_temp = "#{pubdir}/temp/#{time_from.year}"
  pubdir_humi = "#{pubdir}/humi/#{time_from.year}"
  pubdir_didx = "#{pubdir}/didx/#{time_from.year}"
  FileUtils.mkdir_p(pubdir_temp) until FileTest.exists?(pubdir_temp)
  FileUtils.mkdir_p(pubdir_humi) until FileTest.exists?(pubdir_humi)
  FileUtils.mkdir_p(pubdir_didx) until FileTest.exists?(pubdir_didx)

  # 配列の初期化
  time_list = Array.new #時刻
  temp_list = Array.new #温度
  humi_list = Array.new #湿度
  didx_list = Array.new #不快係数

  # csv ファイルの読み込み. 配列化
  Dir.glob("#{srcdir}/*csv").sort.each do |csvfile|
    CSV.foreach( csvfile ) do |item|

      # 時刻. DateTime オブジェクト化.
      time = DateTime.parse( "#{item[0]} JST" )

      # 7日分の毎正時のデータを取得.
      if time >= time_from && time <= time_from + 7 && time.min == 0
        time_list.push( time )          # 時刻
        temp_list.push( item[1].to_f )  # 温度
        humi_list.push( item[4].to_f )  # 湿度
        didx_list.push( item[15].to_f ) # 不快係数
      end
    end
  end
  p "plot from #{time_list[0]} to #{time_list[-1]}"

  next if temp_list.min == temp_list.max

  # NArray オブジェクトへ変換. 解析が容易になる.
  Numo.gnuplot do
   #    debug_on
    set ylabel:   "temperature (C)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+09:00"
    set format_x: "%Y/%m/%d"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir_temp}/#{myid}_temp_#{time_from.strftime("%Y%m%d")}.png"
    set :datafile, :missing, "#{miss}" # 欠損値
    set :nokey # 凡例なし
    plot time_list, temp_list, using:"1:($2)", with:"lines", lc_rgb:"blue", lw:3, title:"#{ARGV[1]}"
  end

  # 湿度グラフ作成
  Numo.gnuplot do
    #    debug_on
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
    plot time_list, humi_list, using:"1:($2)", with:"lines", lc_rgb:"blue", lw:3, title:"#{ARGV[1]}"
  end

  # 不快指数グラフ作成
  Numo.gnuplot do
    #    debug_on
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
    plot time_list, didx_list, using:"1:($2)", with:"lines", lc_rgb:"blue", lw:3, title:"#{ARGV[1]}"
  end

end
