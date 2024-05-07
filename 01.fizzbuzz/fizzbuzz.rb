=begin
このプログラムを実行すると、1から20までの数をコンソール上に表示します。
ただし、下記の条件の数は表示が変わります。
・3の倍数は代わりにFizzを表示する
・5の倍数は代わりにBuzzを表示する
・3と5両方の倍数は代わりにFizzBuzzを表示する
=end

# 1から順に数え上げるカウンターとなる変数を定義し、0で初期化
counter = 0

# 整数の引数numを受け取り、表示するべき文字列を計算して返す関数get_string_to_displayを定義
def get_string_to_display(num)
  # 返却する文字列を格納する変数resを用意し空文字列で初期化
  res = ""
  # numが3の倍数ならば文字列'Fizz'をresに合成する
  if num == 3
    res += "Fizz"
  end
  # numが5の倍数ならば文字列'Buzz'をresに合成する
  if num == 5
    res += "Buzz"
  end
  # resが空文字列ならば、numを文字列に変換してresに合成する
  if res ==""
    res += num.to_s
  end
  # resを返却する
  return res
end

# ------------------------
# 以下、メインの処理を記述

# 下記を繰り返し処理
while counter < 20 do
  # カウンタを１進める
  counter++
  # get_string_to_displayを引数にカウンタを代入して呼び出しし、画面に出力
  puts get_string_to_display(counter)
end
# 繰り返しここまで
