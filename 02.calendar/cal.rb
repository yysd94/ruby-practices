#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'

def main
  opt = OptionParser.new
  params = {}
  opt.on('-m, month') { |v| params[:m] = v }
  opt.on('-y, year') { |v| params[:y] = v }
  opt.parse!(ARGV)

  month = params[:m] ? params[:m].to_i : Date.today.month
  year = params[:y] ? params[:y].to_i : Date.today.year

  display_calender_of_month(month, year)
end

INDENT_LENGTH_OF_DAY = 3
CALENDAR_WIDTH = 20

def display_calender_of_month(month, year)
  first_date_of_month = Date.new(year, month, 1)
  last_date_of_month = Date.new(year, month, -1)

  # カレンダーのヘッダを出力
  puts("#{first_date_of_month.strftime('%B')} #{year}".center(CALENDAR_WIDTH))
  puts('Su Mo Tu We Th Fr Sa')
  print(' ' * INDENT_LENGTH_OF_DAY * first_date_of_month.wday)

  # 日付けを出力
  Range.new(1, last_date_of_month.day).each do |day|
    date = Date.new(year, month, day)
    if date == Date.today
      print("\e[7m") # 文字色と背景色を入れ替えて表示(ANSI excape codeを使用)
      printf('%2d', date.day.to_s)
      print("\e[0m") # 文字色、背景色をリセット
    else
      printf('%2d', date.day.to_s)
    end
    date.saturday? ? print("\n") : print(' ')
  end
  print("\n")
end

main
