#!/usr/bin/env ruby
# frozen_string_literal: true

INDENT_SIZE = 2
MAX_NUM_OF_COLUMNS = 3

def main
  window_width = `tput cols`.chomp.to_i
  file_names = Dir.glob("*", base: Dir.pwd)
  display_filenames(get_filename_list_for_display(file_names, window_width))
end

def align_file_names(file_names, num_of_column)
  num_of_row = file_names.size / num_of_column + 1
  file_names.each_slice(num_of_row).to_a
end

def get_filename_list_for_display(file_names, window_width)
  count_of_columns = 1
  while count_of_columns < MAX_NUM_OF_COLUMNS
    list_width = align_file_names(file_names, count_of_columns + 1).map do | column_list |
      column_list.map(&:size).max
    end.sum
    list_width += INDENT_SIZE * (count_of_columns + 1)
    break if list_width > window_width
    count_of_columns += 1
  end
  align_file_names(file_names, count_of_columns)
end

def display_filenames(filename_list)
  Range.new(0, filename_list[0].size - 1).each do | index_of_rows |
    filename_list.each do | column_list |
      column_width = column_list.map(&:size).max + INDENT_SIZE
      printf("%-#{column_width.to_s}s", column_list[index_of_rows])
    end
    puts ''
  end
end

main
