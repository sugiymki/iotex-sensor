require 'csv'
require 'date'
require 'fileutils'
require 'numo/gnuplot'

###
### デバイスごとの設定
###

# デバイス名
myid=ARGV[0]

# 公開ディレクトリ
pubdir="/iotex/graph_1week/#{myid}"

#データ置場
srcdir="/iotex/data_csv_10min/#{myid}/"

(DateTime.parse("#{ARGV[2]}")..DateTime.now).select{|d| d.wday==0}.each do |time_from|
	#公開ディレクトリの作成
	pubdir_temp="#{pubdir}/temp/#{time_from.strftime("%Y")}"
	FileUtiles.mkdir_p(pubdir_temp) until FileTestexists?(pubdir_temp)

	#欠損値
	miss = 999.9

	###
	###データの取得とグラフの作成
	###

	#7日の幅で描画
	7.each do |range|
		p "#{range} days"
		
		#描画範囲
		time_from=DataTime.now - range

		#ハッシュと配列の初期化
		time_list = Array.new
		temp_list = Array.new
		humi_list = Array.new
		didx_list = Array.new

		#csvファイルから指定された時刻を読み込み,配列化
		Dir.glob("#{srcdir}/*csv").sort.each do |csvfile|
			CSV.foreach(csvfile) do |item|

				#時刻
				time = DateTime.parse("{item[0]} JST")

				#7日分の毎正時のデータを取得.
				if time >= time_from && time <= time_from+1 && time.min == 0
					time_list.push(time)
					time_list.push(item[1].to_f)
					time_list.push(item[4].to_f)
					time_list.push(item[15].to_f)
				end
	 	 	end
		 end
		 next if temp_list.min == temp_list.max

		 #gnuplotで作図
		 Numo.gnuplot do 
		 	set title: "#{ARGV[1]}(温度)"
			set ylabel: "temperature (C)"
			set xlabel: "time"
			set xdata: "time"
			set timefmt_x: %
