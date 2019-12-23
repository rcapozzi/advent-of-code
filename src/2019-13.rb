require 'test/unit'
require 'byebug'
load './src/2019-11.rb'

module AOC
	class Day13
		def self.doit(filename)
			program = File.read(filename).chomp
			results = IntComputer.new(program).execute
			blocks = results.each_slice(3).count{|i| i[2] == 2}
		end
	end
end

def day13_part1_test
end

def day13_part1
	filename = ARGV[0] || 'data2/2019-13.input.txt'
	answer = AOC::Day13.doit(filename)
	assert_equal 230, answer, 'Accepted answer'
	puts 'Day 13 Part 1: %s' % answer
end

if __FILE__ == $0
	extend Test::Unit::Assertions
	day13_part1_test
	day13_part1
	#day13_part2
end
