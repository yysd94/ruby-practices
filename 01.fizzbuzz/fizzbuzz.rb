# frozen_string_literal: true

def main
  (1..20).each do |num|
    puts get_string_to_display(num)
  end
end

def get_string_to_display(num)
  res += 'Fizz' if (num % 3).zero?
  res += 'Buzz' if (num % 5).zero?
  res += num.to_s if res == ''
  res
end

main
