#!/usr/bin/env ruby
# coding: utf-8
require 'open3'

#初期化
count = 0

#無限ループ
loop do
  # ネットワークの導通をチェック
  o, e, s = Open3.capture3("ping -c 2 10.0.0.7")
  mes = s.to_s.split(" ")
  num = mes.pop.to_i

  # "exit 0" (正常終了) か，それ以外かを判断.
  # 正常終了した場合には回数をリセット
  if num == 0
    count = 0
  else
    count += 1
  end

  # 5 分ネットワークが止まっていたら再起動
  if count > 5
    system('reboot')
    break
  end

  # 1 分待つ
  sleep 60
end
