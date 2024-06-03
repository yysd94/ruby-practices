# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/ls'

class LsTest < Minitest::Test
  def test_align_list_to_single_column_matrix
    num_of_column = 1
    filenames = %w[file1 file2 file3]
    assert_equal([%w[file1 file2 file3]], align_list_to_matrix(filenames, num_of_column))
  end

  def test_align_list_to_multi_column_matrix
    filenames = %w[file1 file2 file3 file4 file5 file6 file7]
    assert_equal(
      [%w[file1 file2 file3 file4], %w[file5 file6 file7]],
      align_list_to_matrix(filenames, 2)
    )
    assert_equal(
      [%w[file1 file2 file3], %w[file4 file5 file6], %w[file7]],
      align_list_to_matrix(filenames, 3)
    )
    assert_equal(
      [%w[file1], %w[file2], %w[file3], %w[file4], %w[file5], %w[file6], %w[file7]],
      align_list_to_matrix(filenames, 8)
    )
  end

  def test_filename_matrix_for_display
    filenames = %w[file_a file_bbb file_c file_d file_e file_f file_gggggggggg]
    assert_equal(
      [%w[file_a file_bbb file_c], %w[file_d file_e file_f], %w[file_gggggggggg]],
      filename_matrix_for_display(filenames, 40)
    )
    assert_equal(
      [%w[file_a file_bbb file_c file_d], %w[file_e file_f file_gggggggggg]],
      filename_matrix_for_display(filenames, 30)
    )
    assert_equal(
      [%w[file_a file_bbb file_c file_d file_e file_f file_gggggggggg]],
      filename_matrix_for_display(filenames, 20)
    )
    assert_equal(
      [%w[file_a file_bbb file_c file_d file_e file_f file_gggggggggg]],
      filename_matrix_for_display(filenames, 1)
    )
  end
end
