#!/usr/bin/env ruby

require 'date'
require 'optparse'

def main
  # コマンドラインから入力値を取得
  input_month, input_year = input_month_and_year()

  if valid_month?(input_month) && valid_year?(input_year)
    # 取得した入力値を、表示すべきmonthとyearの整数値に変換
    month, year = month_and_year_to_i(input_month, input_year)
    # カレンダーを表示
    display_calender_of_month(month, year) if month && year
    puts("一年分のカレンダーを表示する機能は未実装です。") if !month && year
    display_calender_of_month(month, Date.today.year) if month && !year
    display_calender_of_month(Date.today.month, Date.today.year) if !month && !year
  end
end

def month_name?(input_month)
  month_name = /^(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)/i.match(input_month)
  !!month_name
end

def month_num?(input_month)
  month_num = /^[0]{0,}([1-9]|[1][0-2])$/.match(input_month)
  !!month_num
end

def month_f_option?(input_month)
  month_f_option = /^[0]{0,}([1-9]|[1][0-2])[f]$/.match(input_month)
  !!month_f_option
end

def month_p_option?(input_month)
  month_p_option = /^[0]{0,}([1-9]|[1][0-2])[p]$/.match(input_month)
  !!month_p_option
end

def valid_month?(input_month)
  return true unless input_month
  if month_name?(input_month)|| \
    month_num?(input_month) || \
    month_f_option?(input_month) || \
    month_p_option?(input_month)
    return true
  end
  puts("cal.rb: #{input_month} is neither a month number (1..12) nor a name")
  false
end

def valid_year?(input_year)
  return true unless input_year
  valid_year = /^[0-9]{0,}$/.match(input_year)
  unless valid_year
    puts "cal.rb: not a valid year #{input_year}"
    return false
  end
  unless 0 < input_year.to_i && input_year.to_i < 10000
    puts "cal.rb: year '#{input_year}' not in range 1..9999"
    return false
  end
  true
end

def month_name_to_i(input_month)
  matched_month_name = /^(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)/i.match(input_month)
  table_of_month_name_to_index = {
    "JAN" => 1,
    "FEB" => 2,
    "MAR" => 3,
    "APR" => 4,
    "MAY" => 5,
    "JUN" => 6,
    "JUL" => 7,
    "AUG" => 8,
    "SEP" => 9,
    "OCT" => 10,
    "NOV" => 11,
    "DEC" => 12,
  }
  table_of_month_name_to_index[matched_month_name[0].upcase]
end

def input_month_and_year()
  # コマンドラインに入力されたオプションの引数を受けとる処理
  opt = OptionParser.new
  params = {}
  opt.on('-m, month') {|v| params[:m] = v } # -mオプションは引数monthを必ず取る
  opt.on('-y') {|v| params[:y] = v } # -yオプションは引数を取らない
  opt.parse!(ARGV)

  # オプションの指定形式に応じて、monthとyearの値を設定する
  # 以下の2通りのUsageで入力を受け付けられるようにする。
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
    puts "Usage: cal.rb [-y] [[month] year]"
    puts "       cal.rb [-m month] [year]"
    exit
  end
  return input_month, input_year
end

def month_and_year_to_i(input_month, input_year)
  year = input_year ? input_year.to_i : Date.today.year
  month = month_name_to_i(input_month) if month_name?(input_month)
  month = input_month.to_i if month_num?(input_month)
  if month_f_option?(input_month)
    month = input_month.chop.to_i
    year += 1 unless year == Date.today.year && month > Date.today.month
  end
  if month_p_option?(input_month)
    month = input_month.chop.to_i
    year -= 1 unless year == Date.today.year && month < Date.today.month
  end
  return month, year
end

def display_calender_of_month(month=Date.today.month, year=Date.today.year)
  first_date_of_month = Date.new(year, month, 1)
  last_date_of_month = Date.new(year, month, -1)
  # 月の初日を表示する位置のインデント量を、その曜日に応じて計算
  indent_length = 3 * first_date_of_month.wday # wdayメソッドの返リ値は0-6 (日曜日が0)

  # カレンダーのヘッダを出力
  puts("#{first_date_of_month.strftime("%B")} #{year}".center(20))
  puts("Su Mo Tu We Th Fr Sa")
  print("".rjust(indent_length))
  # 日付けを出力
  for day in Range.new(1, last_date_of_month.day)
    date = Date.new(year, month, day)
    if date.month == Date.today.month \
      && date.year == Date.today.year \
      && date.day == Date.today.day
      print("\e[7m") # 文字色と背景色を入れ替えて表示(ANSI excape codeを使用)
      printf("%2d", date.day.to_s)
      print("\e[0m") #文字色、背景色をリセット
    else
      printf("%2d", date.day.to_s)
    end
    date.saturday? ? print("\n") : print("\s")
  end
  print("\n")
end

main
