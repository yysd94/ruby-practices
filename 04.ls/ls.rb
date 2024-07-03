#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

INDENT_SIZE = 2
MAX_NUM_OF_COLUMNS = 3
WINDOW_WIDTH = `tput cols`.chomp.to_i
BLOCK_SIZE_RATIO = 2 # Rubyとos標準lsコマンド間のブロックサイズの基準の違いを補正する比率

FILE_TYPES = {
  1 => 'p',
  2 => 'c',
  4 => 'd',
  6 => 'b',
  10 => '-',
  12 => 'l',
  14 => 's'
}.freeze
PERMISSION_TYPES = {
  0 => '---',
  1 => '--x',
  2 => '-w-',
  3 => '-wx',
  4 => 'r--',
  5 => 'r-x',
  6 => 'rw-',
  7 => 'rwx'
}.freeze
AUTHORITY_LEVELS = {
  0 => { name: 'owner', special_permission: { name: 'SUID', letter: 's' } },
  1 => { name: 'group', special_permission: { name: 'SGID', letter: 's' } },
  2 => { name: 'others', special_permission: { name: 'Sticky', letter: 't' } }
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

def decode_filemode_to_string(filemode)
  filemode_octal = format('%06<number>d', number: filemode.to_s(8))
  special_permission_bits = format('%03<number>d', number: filemode_octal.slice(2).to_i(2))
  file_type = FILE_TYPES[filemode_octal.slice(0..1).to_i].dup
  permission_types = AUTHORITY_LEVELS.map do |key, authority_level|
    permission_type = PERMISSION_TYPES[filemode_octal[key + 3].to_i].dup
    if special_permission_bits.slice(key).to_i.eql?(1)
      permission_type[2] =
        if permission_type[2].eql?('x')
          authority_level[:special_permission][:letter].downcase
        else
          authority_level[:special_permission][:letter].upcase
        end
    end
    permission_type
  end
  file_type + permission_types.join
end

def convert_timestamp_to_display_format(timestamp)
  timestamp.strftime('%b %e ') + if timestamp.year == Time.now.year
                                   timestamp.strftime('%R')
                                 else
                                   timestamp.strftime(' %Y')
                                 end
end

def file_status(filename, dir_path = '.')
  file_path = File.expand_path(filename, dir_path)
  fs = File.lstat(file_path)
  filemode = decode_filemode_to_string(fs.mode)
  nlink = fs.nlink.to_s
  owner_name = Etc.getpwuid(fs.uid).name
  group_name = Etc.getgrgid(fs.gid).name
  filesize = if filemode.start_with?('b', 'c')
               [fs.rdev_major, fs.rdev_minor].join(', ')
             else
               fs.size.to_s
             end
  timestamp = convert_timestamp_to_display_format(fs.mtime)
  filename += " -> #{File.readlink(file_path)}" if File.symlink?(file_path)
  { filemode:, nlink:, owner_name:, group_name:, filesize:, timestamp:, filename: }
end

def display_file_status(filenames, dir_path = '.')
  return if filenames.empty?

  file_status_list = filenames.map { |filename| file_status(filename, dir_path) }
  file_status_list.each do |file_status|
    output = file_status.map do |key, value|
      max_width = file_status_list.map { |v| v[key].size }.max
      case key
      when :nlink, :filesize then value.rjust(max_width)
      when :owner_name, :group_name, :filename then value.ljust(max_width)
      else value
      end
    end.join(' ')
    puts output
  end
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
