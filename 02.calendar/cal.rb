#!/usr/bin/env ruby

require 'date'
require 'optparse'

def main
  input_month, input_year = get_input_month_and_year()
  month, year = get_valid_month_and_year(input_month, input_year)
  if year
    if month
      display_calender_of_month(month, year)
    else
      puts("一年分のカレンダーを表示する機能は未実装です。")
      exit
    end
  else
    if month
      display_calender_of_month(month, Date.today.year)
    else
      display_calender_of_month(Date.today.month, Date.today.year)
    end
  end
end

def display_calender_of_month(month=Date.today.month, year=Date.today.year)
  first_date_of_month = Date.new(year, month, 1)
  last_date_of_month = Date.new(year, month, -1)
  # 月の初日を表示する位置のインデント量を、その曜日に応じて計算
  indent_length = 3 * first_date_of_month.wday # wdayメソッドの返リ値は0-6 (日曜日が0)

  # カレンダーのヘッダを出力
  print("#{first_date_of_month.strftime("%B")} #{year}".center(20) + "\n")
  print("Su Mo Tu We Th Fr Sa\n")
  print("".rjust(indent_length)) # 初日表示部分までの空白を出力
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
    if date.saturday?
      print("\n")
    else
      print("\s")
    end
  end
  print("\n")
end

def get_input_month_and_year()
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
    printf "Usage: ./cal.rb [-y] [[month] year]\n"
    printf "       ./cal.rb [-m month] [year]\n"
    exit
  end
  return input_month, input_year
end

def get_valid_month_and_year(input_month, input_year)
  month = nil
  year = nil
  if input_year
    m_y = /^[0-9]{0,}$/.match(input_year)
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
  if input_month
    #月の入力値の有効な文字列フォーマットは4パターン
    m_m_s = /^(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)/i.match(input_month)
    m_m_i = /^[0]{0,}([1-9]|[1][0-2])[fp]?$/.match(input_month)
    #アルファベット表記の月と月番号を対応させるハッシュテーブルを定義
    table_of_month_name_to_index = {
      "JAN" => 1, "FEB" => 2, "MAR" => 3, "APR" => 4, "MAY" => 5, "JUN" => 6,
      "JUL" => 7, "AUG" => 8, "SEP" => 9, "OCT" => 10, "NOV" => 11, "DEC" => 12,
    }
    # 各フォーマットにマッチした場合に応じて、月の番号を取得する
    if m_m_s
      month = tabel_of_month_name_to_index[m_m_s[0].upcase]
    elsif m_m_i
      case m_m_i[0].slice(-1)
      when 'f'
        month = m_m_i[0].chop.to_i
        if year
          year += 1
        elsif month <= Date.today.month
          year = Date.today.year + 1
        end
      when 'p'
        month = m_m_i[0].chop.to_i
        if year
          year -= 1
        elsif month >= Date.today.month
          year = Date.today.year - 1
        end
      else
        month = m_m_i[0].to_i
      end
    else
      puts("#{input_month} is neither a month number (1..12) nor a name")
      exit
    end
  end
  return month, year
end

# mainメソッド呼び出し
main
