#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

INDENT_SIZE = 2
MAX_NUM_OF_COLUMNS = 3
WINDOW_WIDTH = `tput cols`.chomp.to_i
BLOCK_SIZE_RATIO = 2

FILETYPE = {
  '01' => 'p',
  '02' => 'c',
  '04' => 'd',
  '06' => 'b',
  '10' => '-',
  '12' => 'l',
  '14' => 's'
}.freeze
PERMISSION = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

def main
  flags = { filename_pattern: 0, reverse: false, long_format: false }
  opt = OptionParser.new
  opt.on('-a') { flags[:filename_pattern] = File::FNM_DOTMATCH }
  opt.on('-r') { flags[:reverse] = true }
  opt.on('-l') { flags[:long_format] = true }
  opt.parse!(ARGV)

  filename_paths, dir_paths = valid_input_paths
  display_filenames(filename_paths, flags[:long_format])
  puts if !filename_paths.empty? && !dir_paths.empty?
  dir_paths.each_with_index do |dir_path, index|
    puts "#{dir_path}:" if ARGV.size > 1
    filenames = Dir.glob('*', flags[:filename_pattern], base: dir_path)
    sorted_filenames = sort_for_display(filenames, flags[:reverse])
    display_filenames(sorted_filenames, flags[:long_format])
    puts unless index == dir_paths.size - 1
  end
end

def valid_input_paths
  valid_dir_paths = []
  valid_filename_paths = []
  valid_dir_paths << '.' if ARGV.empty?
  ARGV.each do |arg|
    unless File.exist?(arg)
      puts "ls: cannot access '#{arg}': No such file or directory"
      next
    end
    (File.directory?(arg) ? valid_dir_paths : valid_filename_paths) << arg
  end
  [valid_filename_paths, valid_dir_paths]
end

def sort_for_display(filenames, reverse_flag)
  sorted_filenames = filenames.sort_by { |filename| filename.delete_prefix('.').downcase }
  reverse_flag ? sorted_filenames.reverse : sorted_filenames
end

def create_matrix_for_display(filenames, num_of_columns)
  num_of_rows = (filenames.size - 1) / num_of_columns + 1
  filename_matrix = filenames.each_slice(num_of_rows).to_a
  max_row_size = filename_matrix.map(&:size).max
  filename_matrix.map do |column|
    column_width = column.map(&:size).max
    column.map { |path| path.ljust(column_width) }
          .values_at(0...max_row_size) # 各列の要素数を最大の要素数に合わせ、nilで補充する
  end.transpose
end

def convert_to_display_format(filemode)
  filemode_octal = format('%06<number>d', number: filemode.to_s(8))
  filemode_str = FILETYPE[filemode_octal.slice(0..1)] + (3..5).map { |i| PERMISSION[filemode_octal.slice(i)] }.join
  special_permission = format('%03<number>d', number: filemode_octal.slice(2).to_i(2))
  if special_permission.slice(0) == 1
    filemode_str[3] = filemode_str[3] == 'x' ? 's' : 'S'
  end
  if special_permission.slice(1) == 1
    filemode_str[6] = filemode_str[6] == 'x' ? 's' : 'S'
  end
  if special_permission.slice(2) == 1
    filemode_str[9] = filemode_str[9] == 'x' ? 't' : 'T'
  end

  filemode_str
end

def display_file_status(filenames)
  return if filenames.empty?

  block_counts = filenames.map do |filename|
    File.lstat(File.expand_path(filename)).blocks
  end.sum
  puts "total #{block_counts / BLOCK_SIZE_RATIO}"

  filenames.each do |filename|
    fs = File.lstat(File.expand_path(filename))
    owner_name = Etc.getpwuid(fs.uid).name
    group_name = Etc.getgrgid(fs.gid).name
    filemode = convert_to_display_format(fs.mode)
    puts "#{filemode} #{fs.nlink} #{owner_name} #{group_name} #{fs.size} #{fs.mtime} #{filename}"
  end
end

def display_filenames(filenames, long_format_flag)
  return if filenames.empty?

  if long_format_flag
    display_file_status(filenames)
    return
  end

  num_of_columns = 1
  # ウインドウの幅におさまる範囲で表示列数を最大にする
  while num_of_columns < MAX_NUM_OF_COLUMNS
    matrix_display_width =
      create_matrix_for_display(filenames, num_of_columns + 1)[0].join(' ' * INDENT_SIZE).length
    break if matrix_display_width > WINDOW_WIDTH

    num_of_columns += 1
  end
  create_matrix_for_display(filenames, num_of_columns).each do |row|
    puts row.join(' ' * INDENT_SIZE)
  end
end

main
