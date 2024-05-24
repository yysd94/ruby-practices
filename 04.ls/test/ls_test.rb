# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/ls'

class LsTest < Minitest::Test
  def test_align_file_names_in_single_columns
    num_of_column = 1
    file_names = ["file1", "file2", "file3"]
    assert_equal(["file1", "file2", "file3"], align_file_names(file_names, num_of_column))
  end
end
