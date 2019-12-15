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

	def ram=(program)
		if program.is_a?(String)
			@ram = program.split(',').map{|e| e.to_i}
		else
			@ram = program
		end
	end

	def initialize(program=nil)
		self.ram = program if program
		@halted = false
	end

	# Opcode 3 takes a single integer as input
	# and saves it to the position given by its only parameter.
	def op_input(instruction)
		ptr = instruction.ptr
		return @output_result if  @input.size == 0
		value = @input.shift or raise 'No more input'
		value = value.to_i
		pos_v1 = ram[ptr + 1]
		puts "Inputing value #{value} to #{pos_v1}"
		ram[pos_v1] = value
	end

	def op_output(instruction)
		ptr = instruction.ptr
		pos_v1 = ram[ptr + 1]
		value = instruction.p1 == 0 ? ram[pos_v1] : pos_v1
		#puts "output @#{ptr + 1} #{value}"
		@output_result = value
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
		self.ram = program if program
		@input = input if input
		@output_result = nil
		op_ptr = 0
		loop do
			next_op_ptr = 4
			opcode = ram[op_ptr]
			instruction = Instruction.new(opcode, op_ptr)
			@v1 = get_ram(instruction.ptr, instruction.p1, 1)
			@v2 = get_ram(instruction.ptr, instruction.p2, 2)

			if instruction.opcode == 1
				ram[ram[op_ptr + 3]] = @v1 + @v2
			elsif instruction.opcode == 2
				ram[ram[op_ptr + 3]] = @v1 * @v2
			elsif instruction.opcode == 3
				next_op_ptr = 2
				op_input(instruction)
			elsif instruction.opcode == 4
				next_op_ptr = 2
				op_output(instruction)
			elsif instruction.opcode == 5 or
			      instruction.opcode == 6
				next_op_ptr = 3
				if jump = op_jump(instruction,instruction.opcode == 5)
					op_ptr = jump
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
			op_ptr += next_op_ptr
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

class FeebackAmp
	attr_accessor :amps
	def initialize(data, program)
		@program = program
		amps = []
		data.size.times do |i|
			amp = IntComputer.new(program)
			amp.input = [ data[i] ]
			amps << amp
		end
		@amps = amps
	end

	def execute
		@amps.each do |amp|
			output = amp.execute
		end
	end
end

program = '3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5'
# program = '3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5'
# amps = FeebackAmp.init([9,8,7,6,5],program)
def part1
	# 1st part
	filename = ARGV[0] || 'data/2019-07.input.txt'
	program = File.read(filename).chomp
	max = 0
	(0..4).to_a.permutation do |data|
		result = maxamp(program, data)
		max = result > max ? result : max
	end
	puts 'Part 1: Highest output: %s' % max
	assert_equal 368584, max, 'Now I know the answer'
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

	part1
end
