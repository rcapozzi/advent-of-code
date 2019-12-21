# require './src/2019-05.rb'
require 'test/unit'
require 'byebug'
require 'matrix'

# Use Linear algibra's Vector.magnitude for distance
# Use Geometrey's PI for bearing.
# * Bearing is like a normalized vector, but it is a single, sortable number.
#
# Units of Measure
# Vector
# Degrees
# atan expressed as units of PI (radians)
# Convert radians to 360 degrees


# A point and its relationship from us.
# Vectors cannot be sorted.
# The normalized vector is like a bearing, but it requires two numbers rather than one.
class Point
	attr_accessor :x, :y, :distance, :bearing, :vaporized
	def initialize(x,y)
		@x, @y = x, y
		@vaporized = 0
	end

	def bearing=(float)
		@bearing = float.round(8)
	end

	def distance=(float)
		@distance = float.round(8)
	end

	def inspect
		"<P %s:%s b:%s d:%s v:%d>" % [ @x, @y, @bearing, @distance, @vaporized ]
	end

	def <=>(b)
		self.distance <=> b.distance
	end

	# Absolute positions
	def self.from_offset(x_root, y_root, x, y)
		p = Point.new(x,y)
		x_delta = x - x_root
		y_delta = y - y_root
		#v = Vector[x_delta, y_delta]
		#p.distance = v.magnitude
		# Use -y to match clockwise rotation
		p.distance = Math.sqrt(x_delta**2 + y_delta**2)
		p.bearing = laser_bearing(x_delta, y_delta)
		p
	end

end

# Vector[1,0].independent?(Vector[0,1])
# norm
# magnitude
# normalize
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
	grid.each do |(x, y), value|		
		points[[x,y]] = Point.from_offset(x_root, y_root, x, y)
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
	best = nil
	max = 0
	asteroids.each do |(x,y), item|
		ar = asteroid_relative(x,y,asteroids)
		result = seen_i(ar)
		size = result.size
		if size > max
			max = size
			best = [ x, y, result]
		end
	end
	remove_self(*best)
	best
end

def	remove_self(x,y,targets)
	targets.each do |bearing, points|
		points.each_with_index do |point, idx|
			if point.x == x and point.y == y
				points.delete_at(idx)
				return
			end
		end
	end
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

# Bearing from 
def laser_bearing(x,y)
	max = 360.0
	f = Math.atan2(y,x)
	# Convert to -+ degress
	f = (f > 0 ? f : (2*Math::PI + f)) * max / (2*Math::PI)
	f += max
	f += (max * 0.25)
	f < max ? f : f % max
end

# HOA
# keys: bearing
# values: ary of +Points+
def vaporize_targets(hoa)
	results = {}
	count = rotation_count = 0
	loop do
		list = hoa.sort_by{|k,v| [k, v.sort!]}
		prev_count = count
		rotation_count += 1
		list.each do |bearing, points|
			#puts 'vaporize_targets rotation_count: %d bearing: %d'  % [rotation_count, bearing]
			if point = points.shift
				count += 1
				point.vaporized = count
				#puts 'vaporized %4d %p' % [ count, point]
				results[[point.x, point.y]] = point
			end
			if points.size == 0
				hoa.delete(bearing)
			end
			next
			# In place hash more loops
			points.each do |point|
				if point.distance < 0.5
					# puts 'Too close'
					next
				end

				if point.vaporized > 0
					# puts 'already vaporized'
					next
				end
				count += 1
				point.vaporized = count
				#puts 'vaporized %4d %p' % [ count, point]
				break
			end
		end
		break if prev_count == count
		prev_count = count
	end
	results
end

def hoa_to_hash(hoa)
	hash = {}
	hoa.each do |bearing, points|
		points.each do |point|
			hash[[point.x, point.y]] = point
		end
	end
	hash
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

	seen = scan(load_asteroids('data2/2019-10.input.txt'))
	puts 'Day 10 Part 1: Answer: %s' % seen
	assert_equal 214, seen, 'Known answer'
end

def day10_part2_test
	asteroids = load_asteroids('data/2019-10.ex4.txt')
	x, y, targets = find_best_location(asteroids)
	puts 'Station placed at %dx%d' % [x, y]
	points = hoa_to_hash(targets)

	assert_equal 11, x
	assert_equal 13, y
	assert_equal 210, targets.size

	assert_equal 0.0, points[[ 11,12 ]].bearing
	assert_equal 90.0, points[[ 12,13 ]].bearing
	assert_equal 180.0, points[[ 11,14 ]].bearing
	assert_equal 270.0, points[[ 10,13 ]].bearing

	results = vaporize_targets(targets)

	assert_equal 1, results[[11, 12]].vaporized
	assert_equal 2, results[[12, 1]].vaporized
	assert_equal 200, results[[8,2]].vaporized
	assert_equal 299, results[[11,1]].vaporized

end

def day10_part2
	asteroids = load_asteroids('data2/2019-10.input.txt')
	x, y, targets = find_best_location(asteroids)
	puts 'Station placed at %dx%d' % [x, y]
	results = vaporize_targets(targets)
	if point = results.find{|k,v| v.vaporized == 200}[1]
		answer = point.x * 100 + point.y
	end

	puts 'Day 10 Part 2: Answer: %d @ %p' % [answer, point]
end

if __FILE__ == $0
	extend Test::Unit::Assertions
	day10_part1_test
	day10_part1
	day10_part2_test
	day10_part2
end

