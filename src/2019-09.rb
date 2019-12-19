# require './src/2019-05.rb'
require 'test/unit'
require 'byebug'

class Instruction
	attr_reader :opcode, :p1, :p2, :p3, :ptr

	def initialize(int, ptr)
		str = int.to_s
		o1, o2, p1, p2, p3, p4 = str.reverse.chars.map{|e| e.to_i}
		if str.size < 2
			o2 = p1 = p2 = p3 = 0
		end
		@opcode = o1 + (10 * o2)
		@p1 = p1 || 0
		@p2 = p2 || 0
		@p3 = p3 || 0
		@ptr = ptr
	end

	def inspect
		"#<Instruction %s modes: %s,%s,%s >" % [@opcode, @p1, @p2, @p3]
	end
end

class IntComputer
	attr_reader :ram, :output_result
	attr_accessor :input, :relative_base

	def is_halted?
		@halted
	end

	def ram=(program)
		@ram = Hash.new(0)
		if program.is_a?(String)
			# @ram = program.split(',').map{|e| e.to_i}
			program.split(',').each_with_index do |code, idx|
				@ram[idx] = code.to_i
			end
		else
			raise 'Expect string'
		end
	end

	def initialize(program=nil, init=nil)
		self.ram = program if program
		@op_ptr = 0
		@op_count = 0
		@input = [init].compact
		@halted = false
		@relative_base = 0
	end

	# Opcode 3 takes a single integer as input
	# and saves it to the position given by its only parameter.
	def op_input(a)
		if  @input.size == 0
			return 0
		end
		value = @input.shift or raise 'No more input'
		ram[a[0]] = value.to_i
		2
	end

	def op_output(instruction)
		puts "output #{@v1}"
		@output_result = @v1
		2
	end

	# Return pointer to ram slot
	# a1 = get_addr(1, @op_ptr + 1)
	# 0: position
	# 1: immediate
	# 2: relative:
	def addr(mode, ptr)
		if mode == 0
			@ram[ptr]
		elsif mode == 1
			ptr
		elsif mode == 2
			@relative_base + @ram[ptr]
		else
			raise 'Unsupported mode'
		end
	end

	# Opcode 5: jump-if-v1 != 0:
	# Opcode 6: jump-if-v1 == 0:
	# if p1 != 0, sets the instruction pointer to p2. else noop.

	# Opcode 7 is less than
	# Opcode 8 is equals: if the first parameter is equal to the
	# second parameter, it stores 1 in the position given by the
	# third parameter. Otherwise, it stores 0.

	def execute(program=nil, input=nil)
		if program
			self.ram = program
			@op_ptr = 0
		end
		@input << input if input
		@output_result = nil

		loop do
			next_op_ptr = 4
			instruction = Instruction.new(ram[@op_ptr], @op_ptr)
			@op_count += 1
			a = [ addr(instruction.p1, @op_ptr + 1),
					addr(instruction.p2, @op_ptr + 2),
					addr(instruction.p3, @op_ptr + 3)
				]
			@v = [ ram[a[0]] , ram[a[1]], ram[a[2]] ]
			@v1 = ram[a[0]]
			@v2 = ram[a[1]]
			@v3 = ram[a[2]]
puts 'i: %d %p refs: %s vals: %s,%s,%s rbase: %s' % [@op_count, instruction, a.join(','), @v1, @v2, @v3, @relative_base]

			case instruction.opcode
			when 1
				ram[a[2]] = @v1 + @v2
			when 2
				ram[a[2]] = @v1 * @v2
			when 3
				next_op_ptr = op_input(a)
				return @output_result if next_op_ptr == 0
			when 4
				next_op_ptr = op_output(instruction)
			when 5
				if @v1 != 0
					@op_ptr = @v2
					next
				end
				next_op_ptr = 3
			when 6
				if @v1 == 0
					@op_ptr = @v2
					next
				end
				next_op_ptr = 3
			when 7
				value = @v1 < @v2 ? 1 : 0
				ram[a[2]] = value
			when 8
				value = @v1 == @v2 ? 1 : 0
				ram[a[2]] = value
			when 9
				@relative_base += @v1
				next_op_ptr = 2
			when 99
				@halted = true
				break
			else
				raise "Bad opcode #{opcode}"
			end
			@op_ptr += next_op_ptr
		end
		@output_result.to_i
	end
end

# data: ary of 'init phase setting'. one for each amp.
def maxamp(program, data)
	ic = IntComputer.new
	result = 0
	data.each do |amp|
		ic.input = [amp, result]
		result = ic.execute(program)
	end
	result
end

def part2_i(vector, program)
	amps = vector.map{ |init| IntComputer.new(program, init)}
	total = 0
	while amps.none?(&:is_halted?)
		total = amps.inject(total) do |m, amp|
			m = amp.execute(nil, m)
		end
	end
	total
end

def day07_part1_test
	program = '3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0'
	data = [4,3,2,1,0]
	assert_equal 43210, maxamp(program, data)

	data = [0, 1, 2, 3, 4]
	assert_equal 54321, maxamp('3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0', data)

	data = [1,0,4,3,2]
	assert_equal 65210, maxamp('3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0', data)

	vector = [9,8,7,6,5]
	program = '3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5'
	ic = IntComputer.new(program, 9)
	assert_equal 5, ic.execute(nil,0)
	assert_equal [99, 5, 5, 4], ic.ram[-4,4]
	assert_equal false, ic.is_halted?

	ic = IntComputer.new(program, 8)
	assert_equal 14, ic.execute(nil,5)
	assert_equal [3, 26, 1001, 26, -4, 26, 3, 27, 1002, 27, 2, 27, 1, 27, 26, 27, 4, 27, 1001, 28, -1, 28, 1005, 28, 6, 99, 4, 14, 4], ic.ram
	puts 'OK: day07_part1_test'
end

def day07_part2_test
	vector = [9,8,7,6,5]
	program = '3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5'
	assert_equal 139629729, part2_i(vector,program)

	vector = [9,7,8,5,6]
	program = '3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10'
	assert_equal 18216, part2_i(vector,program)
	puts 'OK: day07_part2_test'
end

def day07_part1
	filename = ARGV[0] || 'data/2019-07.input.txt'
	program = File.read(filename).chomp
	max = 0
	(0..4).to_a.permutation do |data|
		result = maxamp(program, data)
		max = result > max ? result : max
	end
	puts 'Day 07 Part 1: Highest output: %s' % max
	assert_equal 368584, max, 'Now I know the answer'
end

def day07_part2
	filename = ARGV[0] || 'data/2019-07.input.txt'
	program = File.read(filename).chomp
	mymax = 0
	(5..9).to_a.permutation do |vector|
		x = part2_i(vector,program)
		mymax = x > mymax ? x : mymax
	end
	puts 'Day 07 Part 2: Answer: %s' % mymax
	assert_equal 35993240, mymax, 'Puzzle answer for Day 07 Part 02'
end

def day09_part1_test
	program = '109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99'
	ic = IntComputer.new(program)
	ic.execute()
	assert_equal program, ic.ram[0,16].join(',')

	program = '1102,34915192,34915192,7,4,7,99,0'
	ic = IntComputer.new(program)
	result = ic.execute()
	assert_equal 16, result.digits.size, 'A 16 digit number'

	ic = IntComputer.new('104,1125899906842624,99')
	result = ic.execute()
	assert_equal 1125899906842624, result, 'A large number in the middle'
end

def day09_part1(filename='./data/2019-09.input.txt')
	program = File.read(filename).chomp
	ic = IntComputer.new(program, 1)
	result = ic.execute
	assert_equal 3598076521, result, 'Known answers'
	puts 'Day 09 Part 1: Answer: %s' % result
end

def day09_part2(filename='./data/2019-09.input.txt')
	program = File.read(filename).chomp
	ic = IntComputer.new(program, 2)
	result = ic.execute
	puts 'Day 09 Part 2: Answer: %s' % result
end


if __FILE__ == $0
	extend Test::Unit::Assertions
	#day07_part1_test
	#day07_part2_test
	#day07_part1
	#day07_part2
	#day09_part1_test
	day09_part1
	day09_part2
end

