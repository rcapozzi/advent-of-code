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

	v1 = ary[pos_v1] or abort "out of range v1 #{i} #{pos_v1}"
	v2 = ary[pos_v2] or abort "out of range v2"

	value = op == 1 ? v1 + v2 : v1 * v2
	ary[pos_vx] = value
	true
end

def to_ary_of_int(str)
	str.split(',').map{|item| item.to_i}
end

# ary: Ary of Ints
def intCode(ary)
#	ary = ary.is_a?(String) ? (ary.split(',').map{|item| item.to_i}) : ary
	i = 0
	loop do
		intCode_i(i, ary) or break
		i += 1
	end
	ary
end

def intSearch(value, str)
	i = 0
	j = 0
	for i in 0..99
		for j in 0..99
			ary = str.split(',').map{|item| item.to_i}
			ary[1] = i
			ary[2] = j
			v = intCode(ary)[0]
			if v == value
				return [ i, j ]
			end
		end
	end
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
	value = ARGV[0].to_i
	str = File.read(ARGV[1]).chomp
	noun, verb = intSearch(value, str)
	puts "Result: #{value} noun:%d verb:%d" % [noun, verb]
end
