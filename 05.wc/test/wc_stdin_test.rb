# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/wc_command'

class WcStdinTest < Minitest::Test
  TEST_DIR = File.expand_path('../..', __dir__)
  LS_COMMAND_SAMPLE = 'ls -l .'
  FILE_PATHS = [].freeze
  STDIN_LINES = `#{LS_COMMAND_SAMPLE}`.scan(/.*?\n/)

  def setup
    Dir.chdir(TEST_DIR)
  end

  def test_run_wc_with_stdin_and_no_option
    expected = `#{LS_COMMAND_SAMPLE} | wc`.chomp
    params = { lines: false, words: false, chars: false }
    assert_equal(expected, run_wc(FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_stdin_and_l_option
    expected = `#{LS_COMMAND_SAMPLE} | wc -l`.chomp
    params = { lines: true, words: false, chars: false }
    assert_equal(expected, run_wc(FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_stdin_and_w_option
    expected = `#{LS_COMMAND_SAMPLE} | wc -w`.chomp
    params = { lines: false, words: true, chars: false }
    assert_equal(expected, run_wc(FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_stdin_and_c_option
    expected = `#{LS_COMMAND_SAMPLE} | wc -c`.chomp
    params = { lines: false, words: false, chars: true }
    assert_equal(expected, run_wc(FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_stdin_and_lw_option
    expected = `#{LS_COMMAND_SAMPLE} | wc -lw`.chomp
    params = { lines: true, words: true, chars: false }
    assert_equal(expected, run_wc(FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_stdin_and_wc_option
    expected = `#{LS_COMMAND_SAMPLE} | wc -wc`.chomp
    params = { lines: false, words: true, chars: true }
    assert_equal(expected, run_wc(FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_stdin_and_lc_option
    expected = `#{LS_COMMAND_SAMPLE} | wc -lc`.chomp
    params = { lines: true, words: false, chars: true }
    assert_equal(expected, run_wc(FILE_PATHS, params, STDIN_LINES))
  end

  def test_run_wc_with_stdin_and_all_option
    expected = `#{LS_COMMAND_SAMPLE} | wc -lwc`.chomp
    params = { lines: true, words: true, chars: true }
    assert_equal(expected, run_wc(FILE_PATHS, params, STDIN_LINES))
  end
end
