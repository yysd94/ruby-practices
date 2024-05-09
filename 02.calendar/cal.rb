#!/usr/bin/env ruby

require 'date'
require 'optparse'

# 年、月を引数で受け取り、その月のカレンダーを表示する関数
def display_calender_of_month(month=Date.today.month, year=Date.today.year)
  #月の初日と最終日のインスタンスを作成
  first_date_of_month = Date.new(year, month, 1)
  last_date_of_month = Date.new(year, month, -1) #-1日は指定した月の最終日を指す。

  # カレンダーのヘッダを出力
  print("#{first_date_of_month.strftime("%B")} #{year}".center(20) + "\n") # 月、年を表示
  print("Su Mo Tu We Th Fr Sa\n") # 曜日を表示

  # 月の初日を表示する位置のインデント量を、その曜日に応じて計算
  indent_length = 3 * first_date_of_month.wday # wdayメソッドの返リ値は0-6 (日曜日が0)
  print("".rjust(indent_length)) # 初日表示部分までの空白を出力

  # 日付けをヘッダに続けて成形して出力
  for day in Range.new(1, last_date_of_month.day)
    date = Date.new(year, month, day) # dateインスタンスを作成
    #もし日付が今日であれば、色を反転して出力
    if date.month == Date.today.month \
      && date.year == Date.today.year \
      && date.day == Date.today.day
      print("\e[7m") # 文字色と背景色を入れ替えて表示(ANSI excape codeを使用)
      printf("%2d", date.day.to_s) #日付を半角2桁の幅で右寄せで出力
      print("\e[0m") #文字色、背景色をリセット
    else
      printf("%2d", date.day.to_s) #日付を半角2桁の幅で右寄せで出力
    end
    # もし曜日が土曜日なら改行を、そうでなければスペースを出力
    if date.saturday?
      print("\n")
    else
      print(" ")
    end
  end
  # 最後に改行を出力
  print("\n")
end

# 以下、メインの処理

# コマンドラインに入力されたオプションの引数を受けとる処理
opt = OptionParser.new
params = {}

opt.on('-m, month') {|v| params[:m] = v } # 引数monthを必ず取ることを明示
opt.on('-y') {|v| params[:y] = v } # 引数を取らない
opt.parse!(ARGV)

# コマンドラインで指定された月と年の値を格納する変数を準備し、nilで初期化
input_month=nil
input_year=nil

# オプションの指定形式に応じて、monthとyearの値を設定する
# 以下の2通りのUsageで入力を受け付けられるものとする。
# cal [-y] [[month] year]
# cal [-m month] [year]
case ARGV.length # ARGVの要素数(=コマンドライン引数の個数)で分岐処理
when 0 then
  input_month = params[:m]
  input_year = nil
when 1 then
  input_month = params[:m]
  input_year = ARGV[0]
when 2 then
  input_month = ARGV[0]
  input_year = ARGV[1]
else
  printf "Usage: ./cal.rb [-y] [[month] year]\n"
  printf "       ./cal.rb [-m month] [year]\n"
  exit
end

year = nil
month = nil

# input_yearについてバリデーションチェックをし、問題なければ値をyearに代入
# 注意：
# input_monthの値によってyearの値を変化させる機能があるため、
# input_monthのバリデーションチェックより先に処理すること。
if !input_year.nil?
  #有効な形式を表す正規表現とマッチさせる
  m_y = /^[1-9][0-9]{0,}$/.match(input_year)
  if m_y
    m_y_i = m_y[0].to_i
    if m_y_i <= 0 || 10000 <= m_y_i
      puts "year '#{input_year}' not in range 1..9999"
      exit
    else
      year = input_year.to_i
    end
  else
    puts "not a valid year #{input_year}"
    exit
  end
end

# input_monthについてバリデーションチェックをし、問題なければ値をmonthに代入
if !input_month.nil?
  #有効な形式を表す正規表現とマッチさせる
  m_m_s = /^(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)/i.match(input_month)
  m_m_i = /^[1-9]$|^[1][0-2]$/.match(input_month)
  m_m_f = /^[1-9][f]$|^[1][0-2][f]$/.match(input_month)
  m_m_p = /^[1-9][p]$|^[1][0-2][p]$/.match(input_month)
  #アルファベット表記の月と月番号を対応させるハッシュテーブルを準備
  hash_of_month = {
    "JAN" => 1, "FEB" => 2, "MAR" => 3, "APR" => 4, "MAY" => 5, "JUN" => 6,
    "JUL" => 7, "AUG" => 8, "SEP" => 9, "OCT" => 10, "NOV" => 11, "DEC" => 12,
  }
  if m_m_s # 英単語フォーマットの場合
    month = hash_of_month[m_m_s[0].upcase]
  elsif m_m_i # 数字フォーマットの場合
    month = m_m_i[0].to_i
  elsif m_m_f # 末尾にfがあるフォーマットの場合
    month = m_m_f[0].chop.to_i
    if year.nil? && month == Date.today.month
      year = Date.today.year + 1 # 今日の日付よりyearを1だけ進める
    end
  elsif m_m_p # 末尾にpがあるフォーマットの場合
    month = m_m_p[0].chop.to_i
    year = Date.today.year - 1 # 今日の日付よりyearを1だけさかのぼる
  else
    puts("#{input_month} is neither a month number (1..12) nor a name")
    exit
  end
end

# 以下、カレンダーを表示する処理
if !year.nil?
  if !month.nil?
    display_calender_of_month(month, year)
  else
    puts("一年分のカレンダーを表示する機能は未実装です。")
    exit
  end
else
  if !month.nil?
    display_calender_of_month(month, Date.today.year)
  else
    display_calender_of_month(Date.today.month, Date.today.year)
  end
end
