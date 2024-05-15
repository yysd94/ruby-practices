#!/usr/bin/env ruby
# frozen_string_literal: true

def main
  points = ARGV[0].split(',')
  frame_points = []
  frame_count = 1
  while frame_count <= 10
    if points[0] == 'X'
      frame_point = 10 + point_to_i(points[1]) + point_to_i(points[2])
      frame_points.push(frame_point)
      points.shift
    else
      frame_point = point_to_i(points[0]) + point_to_i(points[1])
      frame_point += point_to_i(points[2]) if frame_point == 10
      frame_points.push(frame_point)
      points.shift(2)
    end
    frame_count += 1
  end

  score = frame_points.sum
  puts score
end

def point_to_i(point_str)
  point_str == 'X' ? 10 : point_str.to_i
end

main
