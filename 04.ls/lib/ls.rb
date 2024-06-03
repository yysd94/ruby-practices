# frozen_string_literal: true

INDENT_SIZE = 2
MAX_NUM_OF_COLUMNS = 3

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
    list_width += INDENT_SIZE * (count_of_columns)
    break if list_width > window_width
    count_of_columns += 1
  end
  align_file_names(file_names, count_of_columns)
end
