#!/usr/bin/env ruby
# frozen_string_literal: true

INDENT_SIZE = 2
MAX_NUM_OF_COLUMNS = 3
WINDOW_WIDTH = `tput cols`.chomp.to_i

def main
  if ARGV.empty?
    valid_filename_paths = []
    valid_dir_paths = ['.']
  else
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
  end

  display_filename_paths(valid_filename_paths) unless valid_filename_paths.empty?
  display_filenames_in_dirs(valid_dir_paths)
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
    end.sum + INDENT_SIZE * (num_of_columns + 1)
    break if list_width > window_width

    num_of_columns += 1
  end
  align_list_to_matrix(filenames, num_of_columns)
end

def display_filename_paths(target_filename_paths)
  target_filename_paths.each do |target_filename_path|
    print(target_filename_path + '  ')
  end
  print("\n\n")
end

def display_filenames_in_dirs(target_dirs)
  target_dirs.each_with_index do |target_dir, idx|
    filenames = Dir.glob('*', base: target_dir)
    filename_matrix = filename_matrix_for_display(filenames, WINDOW_WIDTH)

    puts "#{target_dir}:" if ARGV.size > 1
    (0...filename_matrix.map(&:size).max).each do |row|
      filename_matrix.each do |column|
        column_width = column.map(&:size).max + INDENT_SIZE
        printf("%-#{column_width}s", column[row])
      end
      puts ''
    end
    puts '' unless idx == target_dirs.size - 1
  end
end

main
