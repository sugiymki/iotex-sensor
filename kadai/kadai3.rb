
require 'csv'
require 'date'
require 'fileutils'
require 'numo/gnuplot'

#欠損値
miss = 999.9


(DateTime.parse("#{ARGV[0]}")..DateTime.now).select{|d| d.wday==0}.each do | time_from|

#公開ディレクトリの作成
	pubdir_temp = "/iotex/compare_1week/iot-11_iot-12_iot-13_iot-36_iot-37/temp/#{time_from.strftime("%Y")}"
	FileUtils.mkdir_p(pubdir_temp) until FileTest.exists?(pubdir_temp)

	pubdir_humi = "/iotex/compare_1week/iot-11_iot-12_iot-13_iot-36_iot-37/humi/#{time_from.strftime("%Y")}"
	FileUtils.mkdir_p(pubdir_humi) until FileTest.exists?(pubdir_humi)

	pubdir_didx = "/iotex/compare_1week/iot-11_iot-12_iot-13_iot-36_iot-37/didx/#{time_from.strftime("%Y")}"
	FileUtils.mkdir_p(pubdir_didx) until FileTest.exists?(pubdir_didx)

	temp_list = Hash["iot-11", 0, "iot-12", 1, "iot-13", 2, "iot-36", 3, "iot-37", 4]
	humi_list = Hash["iot-11", 0, "iot-12", 1, "iot-13", 2, "iot-36", 3, "iot-37", 4]
	didx_list = Hash["iot-11", 0, "iot-12", 1, "iot-13", 2, "iot-36", 3, "iot-37", 4]
	temp2_list = Hash["iot-11", 0, "iot-12", 1, "iot-13", 2, "iot-36", 3, "iot-37", 4]
	time2_list = Hash["iot-11", 0, "iot-12", 1, "iot-13", 2, "iot-36", 3, "iot-37", 4]
	
	["iot-11","iot-12","iot-13","iot-36","iot-37"].each do |myid|
		#データ置き場
		srcdir = "/iotex/data_csv_10min/#{myid}/"
		#配列の初期化
		time2_list[myid] = Array.new 
		temp_list[myid] = Array.new #温度
		humi_list[myid] = Array.new #湿度
		didx_list[myid] = Array.new #不快指数

		Dir.glob("#{srcdir}/*csv").sort.each do |csvfile|
			CSV.foreach( csvfile ) do |item|
				#時刻. DateTime オブジェクト化
				time = DateTime.parse( "#{item[0]} JST" )

				#７日分の毎正時のデータを取得
				if time >= time_from && time<= time_from + 7 
					time2_list[myid].push(time)
					temp_list[myid].push( item[1].to_f ) #温度
					humi_list[myid].push( item[4].to_f ) #湿度
					didx_list[myid].push( item[15].to_f ) #不快指数
				end
			end
		end
	end

	#温度グラフ作成
	Numo.gnuplot do
		set ylabel:	"temperature (C)"
		set xlabel:	"time"
		set xdata:	"time"
		set timefmt_x:	"%Y-%m-%dT%H:%M:%S+00:00"
		set format_x:	"%m/%d %H:%M"
		set xtics:	"rotate by -60"
		set terminal:	"png"
		set output:	"#{pubdir_temp}/iot-11_iot-12_iot-13_iot-36_iot-37_temp_#{time_from.strftime("%Y%m%d")}.png"
		set :datafile, :missing, "#{miss}" #欠損値
		set :nokey #凡例なし
		
		plot [time2_list["iot-11"], temp_list["iot-11"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-11"],
		     [time2_list["iot-12"], temp_list["iot-12"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:2, title:"iot-12"],
		     [time2_list["iot-13"], temp_list["iot-13"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:2, title:"iot-13"],
		     [time2_list["iot-36"], temp_list["iot-36"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-36"],
		     [time2_list["iot-37"], temp_list["iot-37"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-37"]
	end

	#湿度グラフ作成
	 Numo.gnuplot do
                set ylabel:     "humidity (%)"
                set xlabel:     "time"
                set xdata:      "time"
                set timefmt_x:  "%Y-%m-%dT%H:%M:%S+00:00"
                set format_x:   "%m/%d %H:%M"
                set xtics:      "rotate by -60"
                set terminal:   "png"
                set output:     "#{pubdir_humi}/iot-11_iot-12_iot-13_iot-36_iot-37_temp_#{time_from.strftime("%Y%m%d")}.png"
                set :datafile, :missing, "#{miss}" #欠損値
                set :nokey #凡例なし

                plot [time2_list["iot-11"], temp_list["iot-11"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-11"],
                     [time2_list["iot-12"], temp_list["iot-12"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:2, title:"iot-12"],
                     [time2_list["iot-13"], temp_list["iot-13"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:2, title:"iot-13"],
                     [time2_list["iot-36"], temp_list["iot-36"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-36"],
                     [time2_list["iot-37"], temp_list["iot-37"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-37"]
	end

	#不快指数グラフ作成
	 Numo.gnuplot do
	        set ylabel:     "discomfort index"
                set xlabel:     "time"
                set xdata:      "time"
                set timefmt_x:  "%Y-%m-%dT%H:%M:%S+00:00"
                set format_x:   "%m/%d %H:%M"
                set xtics:      "rotate by -60"
                set terminal:   "png"
                set output:     "#{pubdir_didx}/iot-11_iot-12_iot-13_iot-36_iot-37_temp_#{time_from.strftime("%Y%m%d")}.png"
                set :datafile, :missing, "#{miss}" #欠損値
                set :nokey #凡例なし

                plot [time2_list["iot-11"], temp_list["iot-11"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-11"],
                     [time2_list["iot-12"], temp_list["iot-12"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:2, title:"iot-12"],
                     [time2_list["iot-13"], temp_list["iot-13"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:2, title:"iot-13"],
                     [time2_list["iot-36"], temp_list["iot-36"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-36"],
                     [time2_list["iot-37"], temp_list["iot-37"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-37"]
        end
end
