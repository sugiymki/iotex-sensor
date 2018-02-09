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
miss = 999.9

# 公開ディレクトリ
pubdir = "/iotex/compare_1week/iot-19_iot-20_iot-23_iot-24/" 


###
### 初期化
###

(DateTime.parse("#{ARGV[0]}")..DateTime.now).select{|d| d.wday==0}.each do |time_from|


	# 公開ディレクトリの作成
	pubdir_temp = "#{pubdir}/temp/#{time_from.strftime("%Y-%m")}"
	FileUtils.rm_rf(   pubdir_temp ) if    FileTest.exists?( pubdir_temp )
	FileUtils.mkdir_p( pubdir_temp ) until FileTest.exists?( pubdir_temp )

	pubdir_humi = "#{pubdir}/humi/#{time_from.strftime("%Y-%m")}"
	FileUtils.rm_rf(   pubdir_humi ) if    FileTest.exists?( pubdir_humi )
	FileUtils.mkdir_p( pubdir_humi ) until FileTest.exists?( pubdir_humi )


	pubdir_didx = "#{pubdir}/didx/#{time_from.strftime("%Y-%m")}"
	FileUtils.rm_rf(   pubdir_didx ) if    FileTest.exists?( pubdir_didx )
	FileUtils.mkdir_p( pubdir_didx ) until FileTest.exists?( pubdir_didx )
	# データ置き場


	###
	### データの取得とグラフの作成
	### 

	# 7, 30, 90, 120, 360 日の幅で描画
	[7].each do |range|
  		p "#{range} days"
  
  		# 描画範囲
  		time_from = DateTime.now - range
  
  		# ハッシュと配列の初期化
  		time_list = Array.new #時刻
  		temp_list = Array.new #温度
		humi_list = Array.new #湿度
  		didx_list = Array.new #不快係数
    
		["iot-19","iot-20","iot-23","iot-24"].each do |myid|

			srcdir = "/iotex/data_csv_10min/#{myid}/"

				
  			# ハッシュと配列の初期化
  			time_list[#{myid}] = Array.new #時刻
  			temp_list[#{myid}] = Array.new #温度
			humi_list[#{myid}] = Array.new #湿度
  			didx_list[#{myid}] = Array.new #不快係数
 			 # csv ファイルから指定された時刻を読み込み. 配列化
  			Dir.glob("#{srcdir}/*csv").sort.each do |csvfile|
    				CSV.foreach( csvfile ) do |item|

      					# 時刻. DateTime オブジェクト化.
      					time = DateTime.parse( "#{item[0]} JST" )

      					# 指定された時刻より後のデータを取得.
      					if time >= time_from && time <= time_from + 1 && time.min == 0
        					time_list[#{myid}].push( time )          # 時刻        
        					temp_list[#{myid}].push( item[1].to_f )  # 温度
        					humi_list[#{myid}].push( item[4].to_f )  # 湿度
        					didx_list[#{myid}].push( item[15].to_f ) # 不快係数
      					end
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
    			set output:   "#{pubdir}/iot-_19_iot-20_iot-23_iot-24_temp_#{ARGV[0]}.png"
    			set :datafile, :missing, "#{miss}" # 欠損値
    			set :nokey # 凡例なし
    			# set key: "box" #凡例あり

   			plot [time_list["iot-19"], temp_list["iot-19"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:3,title:"創造演習室"],
   		             [time_list["iot-20"], temp_list["iot-20"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:3,title:"共通工学実験室1"],
   			     [time_list["iot-23"], temp_list["iot-23"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:3,title:"共通工学実験室2"],
   			     [time_list["iot-24"], temp_list["iot-24"], using:'1:($2)', with:"linespoints", lc_rgb:"yellow", lw:3,title:"共通工学実験室3"]
 		end

		  # 湿度グラフ作成 (各自で書くこと).

		Numo.gnuplot do
   			set ylabel:   "humidity(%)"
 			set xlabel:   "time"
   			set xdata:    "time"
    			set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    			set format_x: "%m/%d %H:%M"
    			set xtics:    "rotate by -60"
    			set terminal: "png"
    			set output:   "#{pubdir}/iot-_19_iot-20_iot-23_iot-24_humi_#{ARGV[0]}.png"
    			set :datafile, :missing, "#{miss}" # 欠損値
    			set :nokey # 凡例なし
    			# set key: "box" #凡例あり

   			plot [time_list["iot-19"], humi_list["iot-19"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:3,title:"創造演習室"],
   		             [time_list["iot-20"], humi_list["iot-20"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:3,title:"共通工学実験室1"],
   			     [time_list["iot-23"], humi_list["iot-23"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:3,title:"共通工学実験室2"],
   			     [time_list["iot-24"], humi_list["iot-24"], using:'1:($2)', with:"linespoints", lc_rgb:"yellow", lw:3,title:"共通工学実験室3"]
  		end

  		# 不快指数グラフ作成 (各自で書くこと).
  
  		Numo.gnuplot do
    			#    debug_on
    			set ylabel:   "discomfort index"
    			set xlabel:   "time"
 			set xdata:    "time"
 	 		set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
			set format_x: "%m/%d %H:%M"
			set xtics:    "rotate by -60"
			set terminal: "png"
    			set output:   "#{pubdir}/iot-_19_iot-20_iot-23_iot-24_didx_#{ARGV[0]}.png"
			set :datafile, :missing, "#{miss}" # 欠損値
			set :nokey # 凡例なし
			# set key: "box" #凡例あり

   			plot [time_list["iot-19"], humi_list["iot-19"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:3,title:"創造演習室"],
   		             [time_list["iot-20"], humi_list["iot-20"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:3,title:"共通工学実験室1"],
   			     [time_list["iot-23"], humi_list["iot-23"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:3,title:"共通工学実験室2"],
   			     [time_list["iot-24"], humi_list["iot-24"], using:'1:($2)', with:"linespoints", lc_rgb:"yellow", lw:3,title:"共通工学実験室3"]
	 	end
	end
end

