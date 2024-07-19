#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

MAX_COLUMN_WIDTH = 7

def main
  flags = { lines: false, words: false, chars: false }
  opt = OptionParser.new
  opt.on('-l') { flags[:lines] = true }
  opt.on('-w') { flags[:words] = true }
  opt.on('-c') { flags[:chars] = true }
  opt.parse!(ARGV)
  if ARGV.empty?
    input_lines = readlines(chomp: true)
    output = count_status(input_lines).values.map do |v|
      v.to_s.rjust(MAX_COLUMN_WIDTH)
    end.join(' ')
    puts output
  else
    display_count_status_list(count_status_list_of_files)
  end
end

def count_status(input_lines)
  n_lines = input_lines.size
  n_words = input_lines.map { |line| line.split(/\s+/).size }.sum
  n_chars = input_lines.map(&:size).sum + n_lines
  { n_lines:, n_words:, n_chars: }
end

def total_count_status(count_status)
  total_lines = count_status.map { |v| v[:n_lines] }.sum
  total_words = count_status.map { |v| v[:n_words] }.sum
  total_chars = count_status.map { |v| v[:n_chars] }.sum
  {
    n_lines: total_lines,
    n_words: total_words,
    n_chars: total_chars
  }
end

def read_files(file_path)
  input_lines = []
  file = File.open(file_path, 'r')
  loop do
    line = file.gets
    break if line.nil?

    input_lines << line
  end
  file.close
  input_lines
end

def count_status_list_of_files
  count_status_list = []
  ARGV.each do |arg|
    if !File.exist?(arg)
      puts "wc: #{arg}: No such file or directory"
    elsif File.directory?(arg)
      puts "wc: #{arg}: Is a directory"
      count_status_list << { n_lines: 0, n_words: 0, n_chars: 0, filename: arg }
    else
      input_lines = read_files(arg)
      count_status_list << { **count_status(input_lines), filename: arg }
    end
  end
  count_status_list << { **total_count_status(count_status_list), filename: 'total' } if ARGV.size > 1
  count_status_list
end

def display_count_status_list(count_status_list)
  return if count_status_list.empty?

  max_width = count_status_list[0].except(:filename).keys.map do |key|
    count_status_list.map { |v| v[key].to_s.size }.max
  end.max
  count_status_list.each do |output|
    output_line = output.except(:filename).values.map do |value|
      value.to_s.rjust(max_width)
    end.join(' ')
    puts "#{output_line} #{output[:filename]}"
  end
end

main
