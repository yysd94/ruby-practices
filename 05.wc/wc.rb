#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

MAX_COLUMN_WIDTH = 7

def main
  params = { lines: false, words: false, chars: false }
  opt = OptionParser.new
  opt.on('-l') { params[:lines] = true }
  opt.on('-w') { params[:words] = true }
  opt.on('-c') { params[:chars] = true }
  opt.parse!(ARGV)

  counts_list = ARGV.empty? ? [counts(readlines)] : counts_list_of_files
  options = options_to_display(params)
  column_width = calc_column_width(counts_list, options)

  display_counts_list(counts_list, options, column_width)
end

def options_to_display(params)
  options_to_display = []
  params.each_key { |key| options_to_display.append(key) if params[key] }
  options_to_display.append(*params.keys) if options_to_display.empty?
  options_to_display
end

def counts(input_lines)
  {
    lines: input_lines.size,
    words: input_lines.map { |line| line.strip.split(/\s+/).size }.sum,
    chars: input_lines.map(&:size).sum
  }
end

def total_counts(counts)
  {
    lines: counts.map { |v| v[:lines] }.sum,
    words: counts.map { |v| v[:words] }.sum,
    chars: counts.map { |v| v[:chars] }.sum
  }
end

def counts_list_of_files
  counts_list = []
  ARGV.each do |arg|
    if !File.exist?(arg)
      puts "wc: #{arg}: No such file or directory"
    elsif File.directory?(arg)
      puts "wc: #{arg}: Is a directory"
      counts_list << { lines: 0, words: 0, chars: 0, filename: arg }
    else
      input_lines = read_file(arg)
      counts_list << { **counts(input_lines), filename: arg }
    end
  end
  counts_list << { **total_counts(counts_list), filename: 'total' } if ARGV.size > 1
  counts_list
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

def calc_column_width(counts_list, options)
  return MAX_COLUMN_WIDTH if ARGV.empty? || ARGV.map { |arg| File.directory?(arg) }.include?(true)

  options.map do |option|
    counts_list.map { |counts| counts[option].to_s.size }.max
  end.max
end

def display_counts_list(counts_list, options, column_width)
  return if counts_list.empty?

  counts_list_to_display = counts_list.map { |counts| counts.slice(*options, :filename) }
  counts_list_to_display.each { |counts| puts format_for_display(counts, column_width) }
end

def format_for_display(counts, column_width)
  ret = counts.except(:filename).values.map { |v| v.to_s.rjust(column_width) }
  ret << counts[:filename]
  ret.join(' ')
end

main
