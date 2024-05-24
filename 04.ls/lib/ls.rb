# frozen_string_literal: true

def align_file_names(file_names, num_of_column)
  num_of_row = file_names.size / num_of_column + 1
  file_names.each_slice(num_of_row).to_a
end
