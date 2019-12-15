# require './src/2019-05.rb'
require 'test/unit'
require 'byebug'

class Instruction
	attr_reader :opcode, :p1, :p2, :p3, :ptr

	def initialize(int, ptr=0)
		str = int.to_s
		@code = str
		o1, o2, p1, p2, p3, p4 = str.reverse.chars.map{|e| e.to_i}
		if str.size < 2
			o2 = p1 = p2 = p3 = 0
		end
		@opcode = o1 + (10 * o2) # str[-2,2].to_i
		@p1 = p1 || 0
		@p2 = p2 || 0
		@p3 = p3 || 0
		@ptr = ptr
		#puts "%p" % self
	end
end

class IntComputer
	attr_reader :ram, :output_result
	attr_accessor :input

	def is_halted?
		@halted
	end
	def ram=(program)
		if program.is_a?(String)
			@ram = program.split(',').map{|e| e.to_i}
		else
			@ram = program
		end
	end

	def initialize(program=nil, init=nil)
		self.ram = program if program
		@op_ptr = 0
		@input = [init].compact
		@halted = false
	end

	# Opcode 3 takes a single integer as input
	# and saves it to the position given by its only parameter.
	def op_input(instruction)
		ptr = instruction.ptr
		if  @input.size == 0
			#puts 'No more input. returning.'
			return 0
		end
		value = @input.shift or raise 'No more input'
		ram[ram[ptr + 1]] = value.to_i
		2
	end

	def op_output(instruction)
		ptr = instruction.ptr
		pos_v1 = ram[ptr + 1]
		value = instruction.p1 == 0 ? ram[pos_v1] : pos_v1
		#puts "output @#{ptr + 1} #{value}"
		@output_result = value
		2
	end

	def get_ram(ptr, mode, param_id)
		if value = ram[ptr + param_id]
		mode == 0 ? ram[value] : value
		end
	end

	# Opcode 5: jump-if-true:
	# if p1 != 0, sets the instruction pointer to p2. else noop.
	def op_jump(instruction,mode=true)
		#ptr = instruction.ptr
		return @v2 if mode == true and @v1 != 0
		return @v2 if mode == false and @v1 == 0
		nil
	end

	def op_less_than(instruction)
		ptr = instruction.ptr
		value = @v1 < @v2 ? 1 : 0
		ram[get_ram(ptr, 1, 3)] = value
	end

	# Opcode 8 is equals: if the first parameter is equal to the
	# second parameter, it stores 1 in the position given by the
	# third parameter. Otherwise, it stores 0.
	def op_equals(instruction)
		ptr = instruction.ptr
		pos_v1, pos_v2, pos_v3 = ram[ptr + 1, 3]
		v1 = instruction.p1 == 0 ? ram[pos_v1] : pos_v1
		v2 = instruction.p2 == 0 ? ram[pos_v2] : pos_v2
		value = v1 == v2 ? 1 : 0
		ram[pos_v3] = value
	end

	def execute(program=nil, input=nil)
		if program
			self.ram = program
			@op_ptr = 0
		end
		@input << input if input
		@output_result = nil

		loop do
			next_op_ptr = 4
			opcode = ram[@op_ptr]
			instruction = Instruction.new(opcode, @op_ptr)
			@v1 = get_ram(instruction.ptr, instruction.p1, 1)
			@v2 = get_ram(instruction.ptr, instruction.p2, 2)

			if instruction.opcode == 1
				ram[ram[@op_ptr + 3]] = @v1 + @v2
			elsif instruction.opcode == 2
				ram[ram[@op_ptr + 3]] = @v1 * @v2
			elsif instruction.opcode == 3
				next_op_ptr = op_input(instruction)
				return @output_result if next_op_ptr == 0
			elsif instruction.opcode == 4
				next_op_ptr = op_output(instruction)
				#return @output_result.to_i
				#				break
			elsif instruction.opcode == 5 or
			      instruction.opcode == 6
				next_op_ptr = 3
				if jump = op_jump(instruction,instruction.opcode == 5)
					@op_ptr = jump
					next_op_ptr = 0
				end
			elsif instruction.opcode == 7
				op_less_than(instruction)
			elsif instruction.opcode == 8
				op_equals(instruction)
			elsif instruction.opcode == 99
				result = ram[0]
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

def test_part2
	vector = [9,8,7,6,5]
	program = '3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5'
	assert_equal 139629729, part2_i(vector,program)

	vector = [9,7,8,5,6]
	program = '3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10'
	assert_equal 18216, part2_i(vector,program)
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

if __FILE__ == $0
	extend Test::Unit::Assertions

	program = '3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0'
	data = [4,3,2,1,0]
	assert_equal 43210, maxamp(program, data)

	data = [0, 1, 2, 3, 4]
	assert_equal 54321, maxamp('3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0', data)

	data = [1,0,4,3,2]
	assert_equal 65210, maxamp('3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0', data)

	day07_part1
	vector = [9,8,7,6,5]
	program = '3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5'
	ic = IntComputer.new(program, 9)
	assert_equal 5, ic.execute(nil,0)
	assert_equal [99, 5, 5, 4], ic.ram[-4,4]
	assert_equal false, ic.is_halted?

	ic2 = IntComputer.new(program, 8)
	assert_equal 14, ic2.execute(nil,5)
	assert_equal [3, 26, 1001, 26, -4, 26, 3, 27, 1002, 27, 2, 27, 1, 27, 26, 27, 4, 27, 1001, 28, -1, 28, 1005, 28, 6, 99, 4, 14, 4], ic2.ram

	test_part2
	day07_part2
end

