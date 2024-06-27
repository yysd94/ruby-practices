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

  display_files(filename_paths, flags)
  puts if !filename_paths.empty? && !dir_paths.empty?
  display_dirs(dir_paths, flags)
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

def display_filenames(filenames)
  return if filenames.empty?

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

def display_total_blocks(filenames, dir_path = '.')
  block_counts = filenames.map do |filename|
    File.lstat(File.expand_path(filename, dir_path)).blocks
  end.sum
  puts "total #{block_counts / BLOCK_SIZE_RATIO}"
end

def convert_filemode_to_display_format(filemode)
  filemode_octal = format('%06<number>d', number: filemode.to_s(8))
  filemode_str = FILETYPE[filemode_octal.slice(0..1)] + (3..5).map { |i| PERMISSION[filemode_octal.slice(i)] }.join
  special_permission = format('%03<number>d', number: filemode_octal.slice(2).to_i(2))
  if special_permission.slice(0) == '1'
    filemode_str[3] = filemode_str[3] == 'x' ? 's' : 'S'
  end
  if special_permission.slice(1) == '1'
    filemode_str[6] = filemode_str[6] == 'x' ? 's' : 'S'
  end
  if special_permission.slice(2) == '1'
    filemode_str[9] = filemode_str[9] == 'x' ? 't' : 'T'
  end

  filemode_str
end

def convert_timestamp_to_display_format(timestamp)
  timestamp.strftime('%b %e ') + if timestamp.year == Time.now.year
                                   timestamp.strftime('%R')
                                 else
                                   timestamp.strftime(' %Y')
                                 end
end

def file_status_list(filenames, dir_path = '.')
  filenames.map do |filename|
    file_path = File.expand_path(filename, dir_path)
    fs = File.lstat(file_path)
    owner_name = Etc.getpwuid(fs.uid).name
    group_name = Etc.getgrgid(fs.gid).name
    filemode = convert_filemode_to_display_format(fs.mode)
    timestamp = convert_timestamp_to_display_format(fs.mtime)
    filename += " -> #{File.readlink(file_path)}" if File.symlink?(file_path)
    [filemode, fs.nlink.to_s, owner_name, group_name, fs.size.to_s, timestamp, filename]
  end
end

def display_file_status(filenames, dir_path = '.')
  return if filenames.empty?

  file_status_list = file_status_list(filenames, dir_path).transpose.map.with_index do |column, index|
    column_width = column.map(&:size).max
    case index
    when 1, 4 then column.map! { |v| v.rjust(column_width) }
    when 2, 3, 6 then column.map! { |v| v.ljust(column_width) }
    end
    column
  end.transpose
  file_status_list.each { |row| puts row.join(' ') }
end

def display_files(filename_paths, flags)
  if flags[:long_format]
    display_file_status(filename_paths)
  else
    display_filenames(filename_paths)
  end
end

def display_dirs(dir_paths, flags)
  dir_paths.each_with_index do |dir_path, index|
    puts "#{dir_path}:" if ARGV.size > 1
    filenames = Dir.glob('*', flags[:filename_pattern], base: dir_path)
    sorted_filenames = sort_for_display(filenames, flags[:reverse])
    if flags[:long_format]
      display_total_blocks(sorted_filenames, dir_path)
      display_file_status(sorted_filenames, dir_path)
    else
      display_filenames(sorted_filenames)
    end
    puts unless index == dir_paths.size - 1
  end
end

main
