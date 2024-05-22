#!/usr/bin/env ruby
# frozen_string_literal: true

def main
  points = ARGV[0].split(',').map { |point_str| point_str == 'X' ? 10 : point_str.to_i }
  frame_points = []
  frame_count = 1
  while frame_count <= 10
    current_point = points.shift
    frame_point = current_point + points[0]
    if current_point == 10
      frame_point += points[1]
    else
      frame_point += points[1] if frame_point == 10
      points.shift
    end
    frame_points << frame_point
    frame_count += 1
  end

  score = frame_points.sum
  puts score
end

main
