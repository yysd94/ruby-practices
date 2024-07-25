# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/wc_command'

class WcFilesTest < Minitest::Test
  TEST_DIR = File.expand_path('../test/', __dir__)
  TEST_FILE_PATHS = Dir.glob('wc-test-dir/*', base: TEST_DIR).sort
  STDIN_LINES = [].freeze
  WC_COMMAND_ARGS = TEST_FILE_PATHS.join(' ')

  def setup
    Dir.chdir(TEST_DIR)
  end

  # Tests with multiple files

  def test_run_wc_with_files_and_no_option
    expected = `wc #{WC_COMMAND_ARGS}`.chomp
    params = { lines: false, words: false, chars: false }
    assert_equal(expected, run_wc(TEST_FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_files_and_l_option
    expected = `wc -l #{WC_COMMAND_ARGS}`.chomp
    params = { lines: true, words: false, chars: false }
    assert_equal(expected, run_wc(TEST_FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_files_and_w_option
    expected = `wc -w #{WC_COMMAND_ARGS}`.chomp
    params = { lines: false, words: true, chars: false }
    assert_equal(expected, run_wc(TEST_FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_files_and_c_option
    expected = `wc -c #{WC_COMMAND_ARGS}`.chomp
    params = { lines: false, words: false, chars: true }
    assert_equal(expected, run_wc(TEST_FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_files_and_lw_option
    expected = `wc -lw #{WC_COMMAND_ARGS}`.chomp
    params = { lines: true, words: true, chars: false }
    assert_equal(expected, run_wc(TEST_FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_files_and_wc_option
    expected = `wc -wc #{WC_COMMAND_ARGS}`.chomp
    params = { lines: false, words: true, chars: true }
    assert_equal(expected, run_wc(TEST_FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_files_and_lc_option
    expected = `wc -lc #{WC_COMMAND_ARGS}`.chomp
    params = { lines: true, words: false, chars: true }
    assert_equal(expected, run_wc(TEST_FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_files_and_all_option
    expected = `wc -lwc #{WC_COMMAND_ARGS}`.chomp
    params = { lines: true, words: true, chars: true }
    assert_equal(expected, run_wc(TEST_FILE_PATHS, params, STDIN_LINES))
  end

  # Tests with single file

  def test_run_wc_with_single_file_and_no_option
    expected = `wc #{TEST_FILE_PATHS[0]}`.chomp
    params = { lines: false, words: false, chars: false }
    assert_equal(expected, run_wc(TEST_FILE_PATHS.slice(0, 1), params, STDIN_LINES))
  end

  def test_run_wc_with_single_file_and_l_option
    expected = `wc -l #{TEST_FILE_PATHS[0]}`.chomp
    params = { lines: true, words: false, chars: false }
    assert_equal(expected, run_wc(TEST_FILE_PATHS.slice(0, 1), params, STDIN_LINES))
  end

  def test_run_wc_with_single_file_and_w_option
    expected = `wc -w #{TEST_FILE_PATHS[0]}`.chomp
    params = { lines: false, words: true, chars: false }
    assert_equal(expected, run_wc(TEST_FILE_PATHS.slice(0, 1), params, STDIN_LINES))
  end

  def test_run_wc_with_single_file_and_c_option
    expected = `wc -c #{TEST_FILE_PATHS[0]}`.chomp
    params = { lines: false, words: false, chars: true }
    assert_equal(expected, run_wc(TEST_FILE_PATHS.slice(0, 1), params, STDIN_LINES))
  end

  def test_run_wc_with_single_file_and_lw_option
    expected = `wc -lw #{TEST_FILE_PATHS[0]}`.chomp
    params = { lines: true, words: true, chars: false }
    assert_equal(expected, run_wc(TEST_FILE_PATHS.slice(0, 1), params, STDIN_LINES))
  end

  def test_run_wc_with_single_file_and_wc_option
    expected = `wc -wc #{TEST_FILE_PATHS[0]}`.chomp
    params = { lines: false, words: true, chars: true }
    assert_equal(expected, run_wc(TEST_FILE_PATHS.slice(0, 1), params, STDIN_LINES))
  end

  def test_run_wc_with_single_file_and_lc_option
    expected = `wc -lc #{TEST_FILE_PATHS[0]}`.chomp
    params = { lines: true, words: false, chars: true }
    assert_equal(expected, run_wc(TEST_FILE_PATHS.slice(0, 1), params, STDIN_LINES))
  end

  def test_run_wc_with_single_file_and_all_option
    expected = `wc -lwc #{TEST_FILE_PATHS[0]}`.chomp
    params = { lines: true, words: true, chars: true }
    assert_equal(expected, run_wc(TEST_FILE_PATHS.slice(0, 1), params, STDIN_LINES))
  end
end
