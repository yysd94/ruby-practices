#!/usr/bin/env ruby
# frozen_string_literal: true

INDENT_SIZE = 2
MAX_NUM_OF_COLUMNS = 3
WINDOW_WIDTH = `tput cols`.chomp.to_i

def main
  filename_paths, dir_paths = valid_input_paths
  display_filenames(filename_paths)
  puts if !filename_paths.empty? && !dir_paths.empty?
  dir_paths.each_with_index do |dir_path, index|
    puts "#{dir_path}:" if ARGV.size > 1
    filenames = Dir.glob('*', base: dir_path)
    display_filenames(filenames)
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

main
