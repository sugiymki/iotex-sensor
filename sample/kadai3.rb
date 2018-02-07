#!/usr/bin/env ruby
#cording: utf-8

require 'csv'
require 'date'
require 'fileutils'
require 'numo/gnuplot'


#欠損地
miss = 999.9

(DateTime.parse("#{ARGV[0]}")..DateTime.now).select{|d| d.wday==0}.each do |time_from|

	#公開ディレクトリ
	pubdir_temp = "/iotex/compare_1week/iot-21_iot-25_iot-33/temp/#{time_from.strftime("%Y")}"
	#FileUtils.rm_rf(pubdir_temp) if FileTest.exists?(pubdir_temp)
	FileUtils.mkdir_p(pubdir_temp) until FileTest.exists?(pubdir_temp)
	pubdir_humi = "/iotex/compare_1week/iot-21_iot-25_iot-33/humi/#{time_from.strftime("%Y")}"
	#FileUtils.rm_rf(pubdir_humi) if FileTest.exists?(pubdir_humi)
	FileUtils.mkdir_p(pubdir_humi) until FileTest.exists?(pubdir_humi)
	pubdir_didx = "/iotex/compare_1week/iot-21_iot-25_iot-33/didx/#{time_from.strftime("%Y")}"
	#FileUtils.rm_rf(pubdir_didx) if FileTest.exists?(pubdir_didx)
	FileUtils.mkdir_p(pubdir_didx) until FileTest.exists?(pubdir_didx)
	temp_list  = Hash["iot-21", 0, "iot-25", 1, "iot-33", 2]
	humi_list  = Hash["iot-21", 0 ,"iot-25", 1, "iot-33", 2]
	didx_list  = Hash["iot-21", 0, "iot-25", 1, "iot-33", 2]
 	temp2_list = Hash["iot-21", 0, "iot-25", 1, "iot-33", 2]
	time2_list = Hash["iot-21", 0, "iot-25", 1, "iot-33", 2]
	#csvファイルから指定された時刻を読み込み配列化
	["iot-21","iot-25","iot-33"].each do |myid|
		#データ置場
		srcdir = "/iotex/data_csv_10min/#{myid}/"
		#配列の初期化
		time2_list[myid] = Array.new
		temp_list[myid]  = Array.new
		humi_list[myid]  = Array.new
		didx_list[myid]  = Array.new
		Dir.glob("#{srcdir}/*csv").sort.each do |csvfile|
			CSV.foreach(csvfile) do |item|
				time = DateTime.parse("#{item[0]} JST")
				#7日分の毎時のデータを取得
				if time >= time_from && time <= time_from + 7 && time.min == 0
					time2_list[myid].push(time)
					temp_list[myid].push( item[1].to_f )
					humi_list[myid].push( item[4].to_f )
					didx_list[myid].push( item[15].to_f )
				end
			end
		end
	p "plot"
	end
	Numo.gnuplot do
		set ylabel:	"temperature (C)"
		set xlabel:	"time"
		set xdata:	"time"
		set timefmt_x:	"%Y-%m-%dT%H:%M:%S+00:00"
		set format_x:	"%m/%d %H:%M"
		set xtics:	"rotate by -60"
		set terminal:	"png"
		set output:	"#{pubdir_temp}/iot-21_iot25_iot33_temp_#{time_from.strftime("%Y%m%d")}.png"
		set :datafile,	:missing, "#{miss}"
		set :key

		plot [time2_list["iot-21"], temp_list["iot-21"], using:'1:($2)', with:"linespoints", lc_rgb:"red",   lw:2, title:"iot-21"],
	             [time2_list["iot-25"], temp_list["iot-25"], using:'1:($2)', with:"linespoints", lc_rgb:"blue",  lw:2, title:"iot-25"],
		     [time2_list["iot-33"], temp_list["iot-33"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:2, title:"iot-33"]
	end

	Numo.gnuplot do
		set ylabel:	"humidity (%)"
		set xlabel:	"time"
		set xdata:	"time"
		set timefmt_x:	"%Y-%m-%dT%H:%M:%S+00:00"
		set format_x:	"%m/%d %H:%M"
		set xtics:	"rotate by -60"
		set terminal:	"png"
		set output:	"#{pubdir_humi}/iot-21_iot25_iot33_humi_#{time_from.strftime("%Y%m%d")}.png"
		set :datafile,	:missing, "#{miss}"
		set :key

		plot [time2_list["iot-21"], humi_list["iot-21"], using:'1:($2)', with:"linespoints", lc_rgb:"red",   lw:2, title:"iot-21"],
	             [time2_list["iot-25"], humi_list["iot-25"], using:'1:($2)', with:"linespoints", lc_rgb:"blue",  lw:2, title:"iot-25"],
		     [time2_list["iot-33"], humi_list["iot-33"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:2, title:"iot-33"]
	end
	Numo.gnuplot do
		set ylabel:	"discomfort index"
		set xlabel:	"time"
		set xdata:	"time"
		set timefmt_x:	"%Y-%m-%dT%H:%M:%S+00:00"
		set format_x:	"%m/%d %H:%M"
		set xtics:	"rotate by -60"
		set terminal:	"png"
		set output:	"#{pubdir_didx}/iot-21_iot25_iot33_didx_#{time_from.strftime("%Y%m%d")}.png"
		set :datafile,	:missing, "#{miss}"
		set :key

		plot [time2_list["iot-21"], didx_list["iot-21"], using:'1:($2)', with:"linespoints", lc_rgb:"red",   lw:2, title:"iot-21"],
	             [time2_list["iot-25"], didx_list["iot-25"], using:'1:($2)', with:"linespoints", lc_rgb:"blue",  lw:2, title:"iot-25"],
		     [time2_list["iot-33"], didx_list["iot-33"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:2, title:"iot-33"]
	end
end
