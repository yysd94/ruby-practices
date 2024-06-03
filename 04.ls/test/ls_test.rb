# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/ls'

class LsTest < Minitest::Test
  def test_align_file_names_in_single_columns
    num_of_column = 1
    file_names = %w[file1 file2 file3]
    assert_equal([%w[file1 file2 file3]], align_file_names(file_names, num_of_column))
  end

  def test_align_file_names_in_multi_columns
    file_names = %w[file1 file2 file3 file4 file5 file6 file7]
    assert_equal(
      [
        %w[file1 file2 file3 file4],
        %w[file5 file6 file7]
      ],
      align_file_names(file_names, 2)
    )
    assert_equal(
      [
        %w[file1 file2 file3],
        %w[file4 file5 file6],
        %w[file7]
      ],
      align_file_names(file_names, 3)
    )
    assert_equal(
      [
        %w[file1],
        %w[file2],
        %w[file3],
        %w[file4],
        %w[file5],
        %w[file6],
        %w[file7]
      ],
      align_file_names(file_names, 8)
    )
  end

  def test_get_filename_list_for_display
    file_names = %w[file_a file_bbb file_c file_d file_e file_f file_gggggggggg]
    assert_equal(
      [
        %w[file_a file_bbb file_c],
        %w[file_d file_e file_f],
        %w[file_gggggggggg]
      ],
      get_filename_list_for_display(file_names, 40)
    )
    assert_equal(
      [
        %w[file_a file_bbb file_c file_d],
        %w[file_e file_f file_gggggggggg]
      ],
      get_filename_list_for_display(file_names, 30)
    )
    assert_equal(
      [ %w[file_a file_bbb file_c file_d file_e file_f file_gggggggggg] ],
      get_filename_list_for_display(file_names, 20)
    )
    assert_equal(
      [ %w[file_a file_bbb file_c file_d file_e file_f file_gggggggggg] ],
      get_filename_list_for_display(file_names, 1)
    )
  end
end
