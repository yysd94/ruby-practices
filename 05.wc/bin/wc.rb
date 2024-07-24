#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative '../lib/wc_command'

params = { lines: false, words: false, chars: false }
opt = OptionParser.new
opt.on('-l') { params[:lines] = true }
opt.on('-w') { params[:words] = true }
opt.on('-c') { params[:chars] = true }
opt.parse!(ARGV)
file_paths = ARGV
stdin_lines = file_paths.empty? ? readlines : []

puts run_wc(file_paths, params, stdin_lines)
