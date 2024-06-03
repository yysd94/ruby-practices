#!/usr/bin/env ruby
# frozen_string_literal: true

INDENT_SIZE = 2
MAX_NUM_OF_COLUMNS = 3
WINDOW_WIDTH = `tput cols`.chomp.to_i

def main
  if ARGV.empty?
    target_dirs = ['.']
  else
    absolute_paths = []
    relative_paths = []
    ARGV.each do |arg|
      unless File.exist?(arg)
        puts "ls: cannot access '#{arg}': No such file or directory"
        next
      end
      arg[0] == '/' ? absolute_paths << arg : relative_paths << arg
      target_dirs = absolute_paths + relative_paths
    end
  end
  display_filenames(target_dirs)
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

def display_filenames(target_dirs)
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
