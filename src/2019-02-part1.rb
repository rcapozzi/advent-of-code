#!/usr/bin/env ruby

# step: loop count
# ary: ary of ints
def intCode_i(step, ary)
	i = step * 4
	op = ary[i]
	return false if op == 99
	pos_v1 = ary[i += 1]
	pos_v2 = ary[i += 1]
	pos_vx = ary[i += 1]

	v1 = ary[pos_v1]
	v2 = ary[pos_v2]

	value = op == 1 ? v1 + v2 : v1 * v2
	ary[pos_vx] = value
	true
end

def to_ary_of_int(str)
	str.split(',').map{|item| item.to_i}
end

def intCode(str)
	ary = str.split(',').map{|item| item.to_i}
	i = 0
	loop do
		intCode_i(i, ary) or break
		i += 1
	end
	ary.join(',')
end

# Per instructions, we gotta make a slight adjustment to raw input.
def noodle(str)
	ary = str.split(',').map{|item| item.to_i}
	ary[1] = 12
	ary[2] = 2
	str = ary.join(',')
	intCode(str)
end

if __FILE__ == $0
	str = File.read(ARGV[0]).chomp
	puts "Result: %s" % noodle(str)
end
