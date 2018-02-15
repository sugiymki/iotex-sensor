#!/usr/bin/env ruby
# coding: utf-8
#
# 表題: データ解析スクリプト. 10 分平均から 1 日平均を作る.
#
#完成しなくてごめんなさい
require 'csv'
require 'narray'
require 'date'
require 'fileutils'

###
### デバイス毎の設定
###

# デバイス名
myid = ARGV[0]

# 公開ディレクトリ
#pubdir = "/iotex/graph_1day/#{myid}"     # 本番
pubdir = "/iotex/graph_1day/tmp/#{myid}"  # テスト用

###
### 初期化
###

# データ置き場
srcdir = "/iotex/data_csv_10min/#{myid}/"

# 公開ディレクトリの作成
FileUtils.rm_rf(   pubdir ) if    FileTest.exists?( pubdir )
FileUtils.mkdir_p( pubdir ) until FileTest.exists?( pubdir )

# 欠損値
miss = 999.9

# csv ファイルに含まれる変数の一覧
vars = [
  "time","temp","temp2","temp3","humi","humi2","humi3",
  "dp","dp2","dp3","pres","bmptemp","dietemp","objtemp","lux",
  "didx","didx2","didx3"
]


###
### データの取得とグラフの作成
### 

# 配列の初期化
time_list = Array.new
temp_list = Array.new
humi_list = Array.new
didx_list = Array.new

vars_list = Array.new
num = vars.size - 1 # 時刻分を除く
num.times do |i|
  vars_list[i] = Array.new
end

# csv ファイルの読み込み. 配列化
Dir.glob("#{srcdir}/*csv").sort.each do |csvfile|
  CSV.foreach( csvfile ) do |item|
#    p item
    
    # 時刻. DateTime オブジェクト化.
    time = DateTime.parse( "#{item[0]} JST" )
    
    # 毎正時の値のみ抽出
    if time.min == 0
      time_list.push( time )  # 時刻
      num.times do |i|
        vars_list[i].push( item[i+1].to_f ) #各データ
      end
    end
  end
end

# NArray オブジェクトへ変換. 解析が容易になる. 
 vars_list_narray = Array.new
  num.times do |i|
  vars_list_narray[i] = NArray.to_na( vars_list[i] )
 end

###
### 統計処理
###

# 初期化
count = 24 # 24 時間

# 平均を取る開始時刻の添字. 時刻が 00:00:00 となるよう調整. 
time0= DateTime.new(
  time_list[0].year, time_list[0].month, time_list[0].day + 1,
  0, 0, 0, "JST"
)
idx0 = time_list.index( time0 )

# 平均を取る終了時刻の添字
idx1 = idx0 + count

# 時刻をずらしながら 1 日の統計量を作成する. 
while (time_list[idx0] + 1 < time_list[-1]) do 

  # 配列初期化
  time0  = time_list[idx0]
  mean   = Array.new( num, miss )  # 欠損値
  min    = Array.new( num, miss )  # 欠損値
  max    = Array.new( num, miss )  # 欠損値
  
  mean2   = Array.new( num, miss )  # 欠損値
  min2    = Array.new( num, miss )  # 欠損値
  max2    = Array.new( num, miss )  # 欠損値

  puts "#{time0} : #{time_list[idx0+1]}..#{time_list[idx1]}"
  
  # 1 つでも欠損値が含まれていたら日平均は欠損値扱いに.
  # 欠損値が含まれていない場合は idx2 は nil になる. 
  idx2 = ( vars_list_narray[0][idx0+1..idx1] ).to_a.index( miss )    
  unless ( idx2 )
    num.times do |i|
      mean[i]  = vars_list_narray[i][idx0+1..idx1].mean(0)
      mean2[i]  = vars_list_narray[i][idx0+9..idx0+16].mean(0)

      min[i]   = vars_list_narray[i][idx0+1..idx1].min(0)
      min2[i]   = vars_list_narray[i][idx0+9..idx0+16].min(0)

      max[i]   = vars_list_narray[i][idx0+1..idx1].max(0)
      max2[i]   = vars_list_narray[i][idx0+9..idx0+16].max(0)
    end
  end      

  # ファイルの書き出し (平均値)
  csv = open("#{pubdir}/#{myid}_mean.csv", "a")
  csv.puts "#{time0.strftime("%Y/%m/%d")},#{mean.join(',')},\n"
  csv.close
  csv = open("#{pubdir}/#{myid}_mean2.csv", "a")
  csv.puts "#{time0.strftime("%Y/%m/%d")},#{mean2.join(',')},\n"
  csv.close
 

  # ファイルの書き出し (最大値)
  csv = open("#{pubdir}/#{myid}_max.csv", "a")
  csv.puts "#{time0.strftime("%Y/%m/%d")},#{max.join(',')},\n"
  csv.close
  csv = open("#{pubdir}/#{myid}_max2.csv", "a")
  csv.puts "#{time0.strftime("%Y/%m/%d")},#{max2.join(',')},\n"
  csv.close

  # ファイルの書き出し (最小値)
  csv = open("#{pubdir}/#{myid}_min.csv", "a")
  csv.puts "#{time0.strftime("%Y/%m/%d")},#{min.join(',')},\n"
  csv.close
  csv = open("#{pubdir}/#{myid}_min2.csv", "a")
  csv.puts "#{time0.strftime("%Y/%m/%d")},#{min2.join(',')},\n"
  csv.close

  # 添字の更新
  idx0 = idx1 
  idx1 = idx0 + count  # 24時間分進める
end

#グラフ
(DateTime.parse("#{ARGV[0]}")..DateTime.now).select{|d| d.day==1}.each do |time_from|

  # 公開ディレクトリの作成
  pubdir_temp = "#{pubdir}/temp/#{time_from.strftime("%Y-%m")}"
  pubdir_humi = "#{pubdir}/humi/#{time_from.strftime("%Y-%m")}"
  pubdir_didx = "#{pubdir}/didx/#{time_from.strftime("%Y-%m")}"
  FileUtils.mkdir_p( pubdir_temp ) until FileTest.exists?( pubdir_temp )
  FileUtils.mkdir_p( pubdir_humi ) until FileTest.exists?( pubdir_humi )
  FileUtils.mkdir_p( pubdir_didx ) until FileTest.exists?( pubdir_didx )
 # 配列の初期化
  time_list = Array.new
  mean_list = Array.new 
  mean2_list = Array.new 
  max_list = Array.new
  max2_list = Array.new
  min_list = Array.new
  min2_list = Array.new
 # csv読み込み
  Dir.glob("#{srcdir}/*csv").sort.each do |csvfile|
   CSV.foreach( csvfile ) do |item|
 
      time = DateTime.parse( "#{item[0]} JST" )
      if time >= time_from && time <= time_from + 1 && time.min == 0
        time_list.push( time )          # 時刻
     end
    end
  end
  mean_list = CSV.read("#{pubdir}/#{myid}_mean.csv")
  mean2_list = CSV.read("#{pubdir}/#{myid}_mean2.csv")
  max_list = CSV.read("#{pubdir}/#{myid}_max.csv")
  max2_list = CSV.read("#{pubdir}/#{myid}_max2.csv")
  min_list = CSV.read("#{pubdir}/#{myid}_min.csv")
  min2_list = CSV.read("#{pubdir}/#{myid}_min2.csv")

  p "plot from #{time_list[0]} to #{time_list[-1]}"

  next if temp_list.min == temp_list.max

 #平均値 

  Numo.gnuplot do
    set title:    "#{ARGV[1]} (平均値)"
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
