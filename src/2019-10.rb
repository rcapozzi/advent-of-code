# require './src/2019-05.rb'
require 'test/unit'
require 'byebug'
require 'matrix'

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
def asteroid_vectors(x,y,grid)
	vectors = Hash.new
	x_root, y_root = x, y
	grid.each do |key, value|
		next unless key.is_a?(Array)
		x, y = key
		p = Point.new(x,y)
		v = Vector[x - x_root, y - y_root]
		p.v = v
		p.distance = v.magnitude.round(8)
		p.norm = v.normalize.round(8) rescue nil
		vectors[[x,y]] = p
	end
	vectors
end

def scan_i(grid)
	seen = Hash.new
	grid.each do |(x,y), item|
		next unless item.norm
		#puts item.norm
		ary = seen[item.norm] || []
		ary << item
		seen[item.norm] = ary
	end
	# for k, items in seen
	# 	items.sort! { |a, b| a.distance <=> b.distance }
	# end
	seen.size
end

def scan(asteroids)
	results = Hash.new
	asteroids.each do |(x,y), item|
		av = asteroid_vectors(x,y,asteroids)
		results[[x,y]] = scan_i(av)
	end
	results.values.max
end

class Point
	attr_accessor :x, :y, :distance, :norm, :v
	def initialize(x,y)
		@x, @y, @v = x, y, nil
	end
	def loc
		[@x, @y]
	end
	def inspect
		"#<P #{@x}x#{@y}>"
	end
end
def create_grid(x,y)
	h = {}
	y.times do |i_y|
		x.times do |i_x|
			h[ [i_x, i_y] ] = 0
		end
	end
	h
end

# Point = OpenStruct.new
def load_asteroids(filename)
	y = 0
	h = {}
	File.readlines(filename).each do |line|
		line.chomp.chars.each_with_index do |c, x|
			if c == '#'
				tbd = {x: x, y: y}
				h[ [x, y] ] = Point.new(x,y)
			end
		end
		y += 1
	end
	#h[:max_x] = h.keys.inject(0){|m, (x, y)| m > x ? m : x}
	#h[:max_y] = y - 1
	h
end

#
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

if __FILE__ == $0
	extend Test::Unit::Assertions
	day10_part1_test
	day10_part1
end

