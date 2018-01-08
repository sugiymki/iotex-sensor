#!/usr/bin/env ruby
# coding: utf-8
#
# 表題: データ解析スクリプト (1 日平均)
#
require 'csv'
require 'narray'
require 'narray_miss'
require 'date'
require 'fileutils'

###
### 前処理
###

# csv ファイルに含まれる変数の一覧
vars = [
  "time", "temp", "temp2", "temp3", "humi", "humi2", "humi3",
  "dp", "dp2", "dp3", "pres", "bmptemp", "dietemp", "objtemp", "lux",
  "didx", "didx2", "didx3"
]

# ファイルの保存先
srcdir = "/iotex/data_csv_1day/"
pubdir = "/iotex/data_csv_1month/"

# 操作
ops = ["mean", "min", "max"]

# 欠損値
miss = 999.9

###
### 全てのホストについて, 1 日おきのデータを取得
###

50.times do |i|
  num0 = i + 1

  next if num0 == 46 ||  num0 == 47

  myid = "iot-#{sprintf('%02d', num0)}"
  p myid
  
  # データ置き場の作成. スクリプト実行のたびに全て作り直す.
  FileUtils.rm_rf( "#{pubdir}/#{myid}" )  if FileTest.exist?("#{pubdir}/#{myid}")
  FileUtils.mkdir( "#{pubdir}/#{myid}" ) 

  ###
  ### データの取得
  ###

  # 配列の初期化
  time_list = Array.new
  vars_list = Hash.new
  num = vars.size - 1 # 時刻分を除く
  ops.each do |op|
    vars_list[op] = Array.new
    num.times do |i|
      vars_list[op][i] = Array.new
    end
  end
  
  # csv ファイルの読み込み. 配列化
  ops.each do |op|
    time_list = Array.new

    Dir.glob("#{srcdir}/#{myid}/#{myid}_#{op}.csv").sort.each do |csvfile|
      CSV.foreach( csvfile ) do |item|        
        time_list.push( DateTime.parse( "#{item[0]} 00:00:00 JST" ) )
        num.times do |i|
          vars_list[op][i].push( item[i+1].to_f )
        end
      end
    end
  end
  
  # narray miss オブジェクトへ変換 (欠損値込み)
  vars_list_narray = Hash.new
  ops.each do |op|
    vars_list_narray[op] = Array.new
    num.times do |i|      
      vars_list_narray[op][i] = NArrayMiss.to_nam( NArray.to_na( vars_list[op][i] ), miss )
    end
  end
  
  # 初期値. 
  delt  = 1.0   # 1 月
  time0 = DateTime.new(
    time_list[0].year, time_list[0].month, 1,  0, 0, 0, "JST"
  )
  p time_list[0], time0
  time1 = time0 >> delt  # 1 月進める
  time_last = time_list[-1]
  tmax = time_list.size
  idx0 = 0
  idx1 = 0
  
  # 時刻をずらしながら 1 日の統計量を作成する. 
  while (time1 < time_last) do 

    # 添字の取得
    idx0 = idx1 
    idx1 = time_list.index( time1 ) - 1
    
    # 配列を欠損値で初期化
    min = Array.new( num, miss )
    max = Array.new( num, miss )
    mean= Hash.new
    ops.each do |op| 
      mean[op] = Array.new( num, miss )
    end
    
    puts "#{time0} : #{time_list[idx0+1]}..#{time_list[idx1]}"
    
    # 半月以上のデータがないと欠損値扱い
    idx2 = 0
    idx2 = ( vars_list_narray["mean"][0][idx0+1..idx1] ).to_a.uniq.size
    
    if ( idx2 > 15 )           

      # データの平均
      ops.each do |op| 
        num.times do |i|
          mean[op][i] = vars_list_narray[op][i][idx0..idx1].mean(0)
        end
      end
      
      # 最小の最小
      num.times do |i|
        min[i] = vars_list_narray["min"][i][idx0..idx1].min 
      end
      
      # 最大の最小
      num.times do |i|
        max[i] = vars_list_narray["max"][i][idx0..idx1].max
      end
    end
      
    ops.each do |op| 
      csv = open("#{pubdir}/#{myid}/#{myid}_#{op}_mean.csv", "a")
      csv.puts "#{time0.strftime("%Y/%m")},#{mean[op].join(',')},\n"
      csv.close
    end
    csv = open("#{pubdir}/#{myid}/#{myid}_min_min.csv", "a")
    csv.puts "#{time0.strftime("%Y/%m")},#{min.join(',')},\n"
    csv.close
    csv = open("#{pubdir}/#{myid}/#{myid}_max_max.csv", "a")
    csv.puts "#{time0.strftime("%Y/%m")},#{max.join(',')},\n"
    csv.close
    
    time0 = time1
    time1 = time1 >> delt
  end
end
