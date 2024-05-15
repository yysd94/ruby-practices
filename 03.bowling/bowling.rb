#!/usr/bin/env ruby

def main
  points = ARGV[0].split(",")
  framePoints = Array.new
  frameCount = 1
  while frameCount <= 10 do
    if points[0] == 'X'
      framePoint = 10 + point_to_i(points[1]) + point_to_i(points[2])
      framePoints.push(framePoint)
      points.shift
    else
      framePoint = point_to_i(points[0]) + point_to_i(points[1])
      if framePoint == 10
        framePoint += point_to_i(points[2])
      end
      framePoints.push(framePoint)
      points.shift(2)
    end
    frameCount += 1
  end

  score = framePoints.sum
  puts score
end

def point_to_i(pointString)
  if pointString == 'X'
    return 10
  else
    return pointString.to_i
  end
end

main
