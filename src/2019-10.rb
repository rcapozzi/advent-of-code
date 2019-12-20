# require './src/2019-05.rb'
require 'test/unit'
require 'byebug'
require 'matrix'

# A point and its relationship from us.
# Vectors cannot be sorted.
# The normalized vector is like a bearing, but it requires two numbers rather than one.
class Point
	attr_accessor :x, :y, :distance, :bearing
	def initialize(x,y)
		@x, @y = x, y
	end

	def bearing=(float)
		@bearing = float.round(8)
	end

	def distance=(float)
		@distance = float.round(8)
	end

	def inspect
		"<P %s:%s b:%s d:%s>" % [ @x, @y, @bearing, @distance]
	end
end

# Vector[1,0].independent?(Vector[0,1])
# norm
# magnitude
# normalize
# ary = ([nil] * 10).each.inject([]){|item| item << [nil] * 10 }
# 10.times {|x| 10.times{|y| ary[x][y] = Vector[x,y] }}
#
# Start with grid of points
# Create a new grid of vectors. Each vector is from x,y to each point
# Normalize each vector
#
# v = final point - initial point. v = <b1-a1, b2-a2>

# Creates grid of vectors to point
def asteroid_relative(x,y,grid)
	points = Hash.new
	x_root, y_root = x, y
	grid.each do |key, value|
		next unless key.is_a?(Array)
		x, y = key
		p = Point.new(x,y)
		v = Vector[x - x_root, y - y_root]
		p.distance = v.magnitude
		p.bearing = Math.atan2(-v[1], v[0])
		points[[x,y]] = p
	end
	points
end

def seen_i(grid)
	seen = Hash.new
	grid.each do |(x,y), item|
		next unless item.bearing
		key = item.bearing
		ary = seen[key] || []
		ary << item
		seen[key] = ary
	end
	# for k, items in seen
	# 	items.sort! { |a, b| a.distance <=> b.distance }
	# end
	seen
end

def scan(asteroids)
	results = Hash.new
	asteroids.each do |(x,y), item|
		ar = asteroid_relative(x,y,asteroids)
		results[[x,y]] = seen_i(ar).size
	end
	results.values.max
end

# returns [x, y, targets ]
def find_best_location(asteroids)
	results = Hash.new
	best = []
	max = 0
	asteroids.each do |(x,y), item|
		ar = asteroid_relative(x,y,asteroids)
		result = seen_i(ar)
		size = result.size
		if size > max
			max = size
			best = [ x, y, results]
		end
	end
	best
end


def count_targets(targets)

end

def load_asteroids(filename)
	y = 0
	h = {}
	File.readlines(filename).each do |line|
		line.chomp.chars.each_with_index do |c, x|
			if c == '#'
				h[ [x, y] ] = Point.new(x,y)
			end
		end
		y += 1
	end
	h
end

def day10_part1_test
	assert_equal 33, scan(load_asteroids('data/2019-10.ex1.txt'))
	assert_equal 35, scan(load_asteroids('data/2019-10.ex2.txt'))
	assert_equal 41, scan(load_asteroids('data/2019-10.ex3.txt'))
	assert_equal 210, scan(load_asteroids('data/2019-10.ex4.txt'))
end

def day10_part1
	seen = scan(load_asteroids('data/2019-10.input.txt'))
	puts 'Day 10 Part 1: Answer: %s' % seen
	assert_equal 329, seen, 'Known answer'
end

def day10_part2_test
	puts 'Not yet done'
end

def day10_part2
	puts 'Not yet done'
end

if __FILE__ == $0
	extend Test::Unit::Assertions
	day10_part1_test
	day10_part1
	day10_part2_test
	day10_part2
end

