require 'date'

# 年、月を引数で受け取り、その月のカレンダーを表示する関数
def create_dates_of_month(month=Date.today.month, year=Date.today.year)
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
    printf("%2d", date.day.to_s) #日付を半角2桁の幅で右寄せで出力
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
