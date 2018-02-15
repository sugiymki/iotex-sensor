#!/usr/bin/env ruby
# coding: utf-8

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
	### 初期化
	###

	# データ置き場
	srcdir = "/iotex/data_csv_10min/#{myid}/"
# 公開ディレクトリ
         (DateTime.parse("#{ARGV[2]}")..DateTime.now).select{|d| d.wday==0}.each do |time_from| 
	  pubdir_temp = "#{pubdir}/temp/#{time_from.strftime("%Y-%m")}"
	#  FileUtils.rm_rf(   pubdir_temp ) if    FileTest.exists?( pubdir_temp )
	  FileUtils.mkdir_p( pubdir_temp ) until FileTest.exists?( pubdir_temp )

	  pubdir_humi = "#{pubdir}/humi/#{time_from.strftime("%Y-%m")}"
	#  FileUtils.rm_rf(   pubdir_humi ) if    FileTest.exists?( pubdir_humi )
	  FileUtils.mkdir_p( pubdir_humi ) until FileTest.exists?( pubdir_humi )

	  pubdir_didx = "#{pubdir}/didx/#{time_from.strftime("%Y-%m")}"
	#  FileUtils.rm_rf(   pubdir_didx ) if    FileTest.exists?( pubdir_didx )
	  FileUtils.mkdir_p( pubdir_didx ) until FileTest.exists?( pubdir_didx )
	  #  欠損値
	  miss = 999.9


	  ###
	  ### データの取得とグラフの作成
	  ### 

	  # 7, 30, 90, 120, 360 日の幅で描画
	  p "7 days"
		 
	  # 描画範囲
	  #time_from = DateTime.now + 7
	  
       	  #   ハッシュと配列の初期化
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
	     if time >= time_from && time <= time_from + 7 && time.min == 0
		time_list.push( time )          # 時刻        
		temp_list.push( item[1].to_f )  # 温度
		humi_list.push( item[4].to_f )  # 湿度
		didx_list.push( item[15].to_f ) # 不快係数
	      end
	    end
	  end
	  p "plot from #{time_list[0]} to #{time_list[-1]}"
          
        #  next if temp_list.min == temp_list.max
          
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
	    set output:   "#{pubdir}/temp/#{time_from.strftime("%Y-%m")}/#{myid}_temp_#{time_from.strftime("%Y%m%d")}.png"
	    set :datafile, :missing, "#{miss}" # 欠損値
	    set :nokey # 凡例なし
	    # set key: "box" #凡例あり

	    plot time_list, temp_list, using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:3
	  end

	  # 湿度グラフ作成 (各自で書くこと).
	  Numo.gnuplot do
	    #    debug_on
	    set ylabel:   "history (%)"
	    set xlabel:   "time"
	    set xdata:    "time"
	    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
	    set format_x: "%m/%d %H:%M"
	    set xtics:    "rotate by -60"
	    set terminal: "png"
	    set output:   "#{pubdir}/humi/#{time_from.strftime("%Y-%m")}/#{myid}_humi_#{time_from.strftime("%Y%m%d")}.png"
	    set :datafile, :missing, "#{miss}" # 欠損値
	    set :nokey # 凡例なし
	    # set key: "box" #凡例あり
	    plot time_list, humi_list, using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:3
	  end

	  # 不快指数グラフ作成 (各自で書くこと).
	  Numo.gnuplot do
	    #    debug_on
	    set ylabel:   "discomfort index (%)"
	    set xlabel:   "time"
	    set xdata:    "time"
	    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
	    set format_x: "%m/%d %H:%M"
	    set xtics:    "rotate by -60"
	    set terminal: "png"
	    set output:   "#{pubdir}/didx/#{time_from.strftime("%Y-%m")}/#{myid}_didx_#{time_from.strftime("%Y%m%d")}.png"
	    set :datafile, :missing, "#{miss}" # 欠損値
	    set :nokey # 凡例なし
	    # set key: "box" #凡例あり

	    plot time_list, didx_list, using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:3
	  end
	end
