#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

MAX_COLUMN_WIDTH = 7

def main
  flags = { n_lines: false, n_words: false, n_chars: false }
  opt = OptionParser.new
  opt.on('-l') { flags[:n_lines] = true }
  opt.on('-w') { flags[:n_words] = true }
  opt.on('-c') { flags[:n_chars] = true }
  opt.parse!(ARGV)

  count_status_list = []
  column_width = MAX_COLUMN_WIDTH
  options = enabled_options(flags)
  if ARGV.empty?
    input_lines = readlines
    count_status_list.append(count_status(input_lines))
  else
    count_status_list = count_status_list_of_files
    column_width = options.map do |option|
      count_status_list.map { |count_status| count_status[option].to_s.size }.max
    end.max
  end
  display_count_status_list(count_status_list, options, column_width)
end

def enabled_options(flags)
  enabled_options = []
  flags.each_key { |key| enabled_options.append(key) if flags[key] }
  enabled_options.append(*flags.keys) if enabled_options.empty?
  enabled_options
end

def count_status(input_lines)
  n_lines = input_lines.size
  n_words = input_lines.map { |line| line.strip.split(/\s+/).size }.sum
  n_chars = input_lines.map(&:size).sum
  { n_lines:, n_words:, n_chars: }
end

def total_count_status(count_status)
  {
    n_lines: count_status.map { |v| v[:n_lines] }.sum,
    n_words: count_status.map { |v| v[:n_words] }.sum,
    n_chars: count_status.map { |v| v[:n_chars] }.sum
  }
end

def read_file(file_path)
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
      input_lines = read_file(arg)
      count_status_list << { **count_status(input_lines), filename: arg }
    end
  end
  count_status_list << { **total_count_status(count_status_list), filename: 'total' } if ARGV.size > 1
  count_status_list
end

def display_count_status_list(count_status_list, options, column_width)
  return if count_status_list.empty?

  count_status_list_for_display = count_status_list.map do |count_status|
    count_status.slice(*options, :filename)
  end
  count_status_list_for_display.each do |count_status|
    output = count_status.except(:filename).values.map do |value|
      value.to_s.rjust(column_width)
    end
    output << count_status[:filename]
    puts output.join(' ')
  end
end

main
