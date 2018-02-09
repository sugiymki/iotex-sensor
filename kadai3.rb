
require 'csv'
require 'date'
require 'fileutils'
require 'numo/gnuplot'

#欠損値
miss = 999.9


(DateTime.parse("#{ARGV[0]}")..DateTime.now).select{|d| d.wday==0}.each do | time_from|

#公開ディレクトリの作成
	pubdir_temp = "/iotex/compare_1week/iot-01_iot-02_iot-03_iot-04_iot-05/temp/#{time_from.strftime("%Y")}"
	FileUtils.mkdir_p(pubdir_temp) until FileTest.exists?(pubdir_temp)

	pubdir_humi = "/iotex/compare_1week/iot-01_iot-02_iot-03_iot-04_iot-5/humi/#{time_from.strftime("%Y")}"
	FileUtils.mkdir_p(pubdir_humi) until FileTest.exists?(pubdir_humi)

	pubdir_didx = "/iotex/compare_1week/iot-01_iot-02_iot-03_iot-04_iot-05/didx/#{time_from.strftime("%Y")}"
	FileUtils.mkdir_p(pubdir_didx) until FileTest.exists?(pubdir_didx)

	temp_list = Hash["iot-01", 0, "iot-02", 1, "iot-03", 2, "iot-04", 3, "iot-05", 4]
	humi_list = Hash["iot-01", 0, "iot-02", 1, "iot-03", 2, "iot-04", 3, "iot-05", 4]
	didx_list = Hash["iot-01", 0, "iot-02", 1, "iot-03", 2, "iot-04", 3, "iot-05", 4]
	temp2_list = Hash["iot-01", 0, "iot-02", 1, "iot-03", 2, "iot-04", 3, "iot-05", 4]
	time2_list = Hash["iot-01", 0, "iot-02", 1, "iot-03", 2, "iot-04", 3, "iot-05", 4]
	
	#CSVファイルから指定された時刻を読み込み初期化
	["iot-01","iot-02","iot-03","iot-04","iot-05"].each do |myid|
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
				if time >= time_from && time<= time_from + 1 && time.min == 0
					time2_list[myid].push(time)
					temp_list[myid].push( item[1].to_f ) #温度
					humi_list[myid].push( item[4].to_f ) #湿度
					didx_list[myid].push( item[15].to_f ) #不快指数
				end
			end
		end
	p "plot"
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
		set output:	"#{pubdir_temp}/iot-01_iot-02_iot-03_iot-04_iot-05_temp_#{time_from.strftime("%Y%m%d")}.png"
		set :datafile, :missing, "#{miss}" #欠損値
		set :nokey #凡例なし
		
		plot [time2_list["iot-01"], temp_list["iot-01"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-01"],
		     [time2_list["iot-02"], temp_list["iot-02"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:2, title:"iot-02"],
		     [time2_list["iot-03"], temp_list["iot-03"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:2, title:"iot-03"],
		     [time2_list["iot-04"], temp_list["iot-04"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-04"],
		     [time2_list["iot-05"], temp_list["iot-05"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-05"]
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
                set output:     "#{pubdir_humi}/iot-01_iot-02_iot-03_iot-04_iot-05_temp_#{time_from.strftime("%Y%m%d")}.png"
                set :datafile, :missing, "#{miss}" #欠損値
                set :nokey #凡例なし

                plot [time2_list["iot-01"], temp_list["iot-01"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-01"],
                     [time2_list["iot-02"], temp_list["iot-02"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:2, title:"iot-02"],
                     [time2_list["iot-03"], temp_list["iot-03"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:2, title:"iot-03"],
                     [time2_list["iot-04"], temp_list["iot-04"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-04"],
                     [time2_list["iot-05"], temp_list["iot-05"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-05"]
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
                set output:     "#{pubdir_didx}/iot-01_iot-02_iot-03_iot-04_iot-05_temp_#{time_from.strftime("%Y%m%d")}.png"
                set :datafile, :missing, "#{miss}" #欠損値
                set :nokey #凡例なし

                plot [time2_list["iot-01"], temp_list["iot-01"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-01"],
                     [time2_list["iot-02"], temp_list["iot-02"], using:'1:($2)', with:"linespoints", lc_rgb:"blue", lw:2, title:"iot-02"],
                     [time2_list["iot-03"], temp_list["iot-03"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:2, title:"iot-03"],
                     [time2_list["iot-04"], temp_list["iot-04"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-04"],
                     [time2_list["iot-05"], temp_list["iot-05"], using:'1:($2)', with:"linespoints", lc_rgb:"red", lw:2, title:"iot-05"]
        end
end
