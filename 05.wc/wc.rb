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
    count_status_list = read_count_status_from_files
    display_count_status_list(count_status_list) if !count_status_list.empty?
  end
end

def count_status(input_lines)
  n_lines = input_lines.size
  n_words = input_lines.map { |line| line.split(/\s+/).size }.sum
  n_chars = input_lines.map(&:size).sum + n_lines
  { n_lines:, n_words:, n_chars: }
end

def count_status_with_filename(file_path)
  if File.directory?(file_path)
    puts "wc: #{file_path}: Is a directory"
    { n_lines: 0, n_words: 0, n_chars: 0, filename: file_path }
  else
    input_lines = []
    file = File.open(file_path, 'r')
    loop do
      line = file.gets
      break if line.nil?

      input_lines << line
    end
    file.close
    res = count_status(input_lines)
    res[:filename] = file_path
    res
  end
end

def total_count_status(count_status)
  total_lines = count_status.map { |v| v[:n_lines] }.sum
  total_words = count_status.map { |v| v[:n_words] }.sum
  total_chars = count_status.map { |v| v[:n_chars] }.sum
  {
    n_lines: total_lines,
    n_words: total_words,
    n_chars: total_chars,
    filename: 'total'
  }
end

def read_count_status_from_files
  count_status_list = []
  ARGV.each do |arg|
    if !File.exist?(arg)
      puts "wc: cannot access #{arg}: No such file or directory"
    else
      count_status_list << count_status_with_filename(arg)
    end
  end
  count_status_list << total_count_status(count_status_list) if ARGV.size > 1
  count_status_list
end

def display_count_status_list(count_status_list)
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
