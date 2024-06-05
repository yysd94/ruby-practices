#!/usr/bin/env ruby
# frozen_string_literal: true

INDENT_SIZE = 2
MAX_NUM_OF_COLUMNS = 3
WINDOW_WIDTH = `tput cols`.chomp.to_i

def main
  filename_paths = []
  dir_paths = []
  if ARGV.empty?
    dir_paths << '.'
  else
    filename_paths, dir_paths = valid_input_paths
  end
  display_filename_paths(filename_paths)
  display_filenames_in_dirs(dir_paths)
end

def valid_input_paths
  absolute_dir_paths = []
  relative_dir_paths = []
  absolute_filename_paths = []
  relative_filename_paths = []
  ARGV.each do |arg|
    unless File.exist?(arg)
      puts "ls: cannot access '#{arg}': No such file or directory"
      next
    end
    if File.directory?(arg)
      arg[0] == '/' ? absolute_dir_paths << arg : relative_dir_paths << arg
    else
      arg[0] == '/' ? absolute_filename_paths << arg : relative_filename_paths << arg
    end
  end
  valid_filename_paths = absolute_filename_paths + relative_filename_paths
  valid_dir_paths = absolute_dir_paths + relative_dir_paths
  [valid_filename_paths, valid_dir_paths]
end

def align_list_to_matrix(list, num_of_column)
  num_of_row = list.size / num_of_column + 1
  list.each_slice(num_of_row).to_a
end

def filename_matrix_for_display(filenames, window_width)
  num_of_columns = 1
  while num_of_columns < MAX_NUM_OF_COLUMNS
    list_width = align_list_to_matrix(filenames, num_of_columns + 1).map do |column|
      column.map(&:size).max
    end.sum + INDENT_SIZE * num_of_columns
    break if list_width > window_width

    num_of_columns += 1
  end
  align_list_to_matrix(filenames, num_of_columns)
end

def display_filename_paths(filename_paths)
  print filename_paths.join(' ' * INDENT_SIZE)
  2.times { puts '' } unless filename_paths.empty?
end

def display_filenames_in_dirs(dir_paths)
  dir_paths.each_with_index do |dir_path, idx|
    puts "#{dir_path}:" if ARGV.size > 1

    filenames = Dir.glob('*', base: dir_path)
    filename_matrix = filename_matrix_for_display(filenames, WINDOW_WIDTH)
    last_row = filename_matrix.map(&:size).max
    (0...last_row).each do |row|
      filename_matrix.each do |column|
        column_width = column.map(&:size).max + INDENT_SIZE
        printf("%-#{column_width}s", column[row])
      end
      puts ''
    end
    puts '' unless idx == dir_paths.size - 1
  end
end

main
