# frozen_string_literal: true

MAX_COLUMN_WIDTH = 7

def run_wc(file_paths, params, stdin_lines)
  counts_list = file_paths.empty? ? [counts(stdin_lines)] : counts_list_of_files(file_paths)
  options = options_to_display(params)
  column_width = calc_column_width(counts_list, options, file_paths)

  format_counts_list_for_display(counts_list, options, column_width)
end

def options_to_display(params)
  options_to_display = []
  params.each_key { |key| options_to_display.append(key) if params[key] }
  options_to_display.append(*params.keys) if options_to_display.empty?
  options_to_display
end

def counts(input_lines)
  {
    lines: input_lines.size,
    words: input_lines.map { |line| line.strip.split(/\s+/).size }.sum,
    chars: input_lines.map(&:size).sum
  }
end

def total_counts(counts)
  {
    lines: counts.map { |v| v[:lines] }.sum,
    words: counts.map { |v| v[:words] }.sum,
    chars: counts.map { |v| v[:chars] }.sum
  }
end

def counts_list_of_files(file_paths)
  counts_list = []
  file_paths.each do |file_path|
    if !File.exist?(file_path)
      puts "wc: #{file_path}: No such file or directory"
    elsif File.directory?(file_path)
      puts "wc: #{file_path}: Is a directory"
      counts_list << { lines: 0, words: 0, chars: 0, filename: file_path }
    else
      input_lines = read_file(file_path)
      counts_list << { **counts(input_lines), filename: file_path }
    end
  end
  counts_list << { **total_counts(counts_list), filename: 'total' } if file_paths.size > 1
  counts_list
end

def read_file(file_path)
  input_lines = []
  file = File.open(file_path, 'r')
  loop do
    line = file.gets
    break if line.nil?

    input_lines << line
  end
  file.close
  input_lines
end

def calc_column_width(counts_list, options, file_paths)
  return MAX_COLUMN_WIDTH if include_directory_path?(file_paths)
  return MAX_COLUMN_WIDTH if file_paths.empty? && options.size > 1

  if options.size > 1 || file_paths.size > 1
    max_width_of_all_options(counts_list)
  else
    max_width_of_display_options(counts_list, options)
  end
end

def max_width_of_all_options(counts_list)
  counts_list.map do |counts|
    counts.except(:filename).values.map(&:to_s).map(&:size).max
  end.max
end

def max_width_of_display_options(counts_list, options)
  options.map do |option|
    counts_list.map { |counts| counts[option].to_s.size }.max
  end.max
end

def include_directory_path?(file_paths)
  file_paths.map { |file_path| File.directory?(file_path) }.include?(true)
end

def format_counts_list_for_display(counts_list, options, column_width)
  return if counts_list.empty?

  counts_list_to_display = counts_list.map { |counts| counts.slice(*options, :filename) }
  counts_list_to_display.map { |counts| format_counts_for_display(counts, column_width) }.join("\n")
end

def format_counts_for_display(counts, column_width)
  ret = counts.except(:filename).values.map { |v| v.to_s.rjust(column_width) }
  ret << counts[:filename] if counts[:filename]
  ret.join(' ')
end
