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
		# puts "%p" % self
	end
end

class IntComputer
	attr_reader :ram, :input
	OP_ADD = 1
	OP_MULT = 2
	OP_INPUT = 3
	OP_OUTPUT = 4
	OP_HALT = 99

	def ram=(program)
		if program.is_a?(String)
			@ram = program.split(',').map{|e| e.to_i}
		else
			@ram = program
		end
	end

	def initialize(program)
		@input = []
		ram = program
	end

	def add(instruction)
		ptr = instruction.ptr
		pos_v1 = ram[ptr + 1]
		pos_v2 = ram[ptr + 2]
		pos_v3 = ram[ptr + 3]
		v1 = instruction.p1 == 0 ? ram[pos_v1] : pos_v1
		v2 = instruction.p2 == 0 ? ram[pos_v2] : pos_v2

		ram[pos_v3] = v1 + v2
	end

	def mult(instruction)
		ptr = instruction.ptr
		pos_v1 = ram[ptr + 1]
		pos_v2 = ram[ptr + 2]
		pos_v3 = ram[ptr + 3]
		v1 = instruction.p1 == 0 ? ram[pos_v1] : pos_v1
		v2 = instruction.p2 == 0 ? ram[pos_v2] : pos_v2
		# v1 = ram[pos_v1]
		# v2 = ram[pos_v2]
		ram[pos_v3] = v1 * v2
	end

	# Opcode 3 takes a single integer as input
	# and saves it to the position given by its only parameter.
	def op_input(instruction)
		#value = @input.shift or raise 'No more input'
		puts 'Faking input as 1'
		value = 1
		ptr = instruction.ptr
		pos_v1 = ram[ptr + 1]
		ram[pos_v1] = value
	end

	def op_output(instruction)
		ptr = instruction.ptr
		pos_v1 = ram[ptr + 1]
		# value = instruction.p1 == 0 ? ram[instruction.p1] : pos_v1
		value = instruction.p1 == 0 ? ram[pos_v1] : pos_v1
		puts "output #{value}"
	end

	def execute(program=nil)
		if program
			self.ram= program
		end
		result = nil
		op_ptr = 0
		loop do
			opcode = ram[op_ptr]
			instruction = Instruction.new(opcode, op_ptr)
			if instruction.opcode == OP_ADD
				next_op_ptr = 4
				add(instruction)
			elsif instruction.opcode == OP_MULT
				next_op_ptr = 4
				mult(instruction)
			elsif instruction.opcode == OP_INPUT
				next_op_ptr = 2
				op_input(instruction)
			elsif instruction.opcode == OP_OUTPUT
				next_op_ptr = 2
				op_output(instruction)
			elsif instruction.opcode == OP_HALT
				result = ram[0]
				break
			else
				raise "Bad opcode #{opcode}"
			end
			op_ptr += next_op_ptr
		end
		result
	end
end


if __FILE__ == $0
	filename = ARGV[0] || 'data/2019-05.input.txt'
	program = File.read(filename).chomp
	ic = IntComputer.new
	ic.input << 1
	puts ic.execute(program)
end
