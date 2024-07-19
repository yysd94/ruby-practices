#!/usr/bin/env ruby
# frozen_string_literal: true

def main
  input_lines = readlines(chomp: true)
  n_lines = input_lines.size
  n_words = input_lines.map do |line|
    line.split(/\s+/).size
  end.sum
  n_chars = input_lines.map(&:size).sum + n_lines
  puts "行数: " + n_lines.to_s
  puts "単語数: " + n_words.to_s
  puts "文字数: " + n_chars.to_s
end

main
