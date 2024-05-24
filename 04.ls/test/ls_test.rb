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
end
