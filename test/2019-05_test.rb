require 'minitest'
require 'minitest/autorun'
require 'minitest/focus'
require './src/2019-05'

class T2019_05 < Minitest::Test
	def test_day05_v2
		instruction = Instruction.new(1002,99)
		assert_equal 99, instruction.ptr
		assert_equal 2, instruction.opcode
		assert_equal 0, instruction.p1
		assert_equal 1, instruction.p2
		assert_equal 0, instruction.p3

		assert_equal 3500, IntComputer.new('1,9,10,3,2,3,11,0,99,30,40,50').execute
		assert_equal 2, IntComputer.new('1,0,0,0,99').execute
		assert_equal 30, IntComputer.new('1,1,1,4,99,5,6,0,99').execute
	end

	def test_part2
		# Assume input is 1.
		ic = IntComputer.new
		ic.execute('3,9,8,9,10,9,4,9,99,-1,8')
		assert_equal [3, 9, 8, 9, 10, 9, 4, 9, 99, 0, 8], ic.ram
		assert_equal 0, ic.ram[9]

		# Using position mode, if input is less than 8; output 1 if true
		ic.execute('3,9,7,9,10,9,4,9,99,-1,8')
		assert_equal [3, 9, 7, 9, 10, 9, 4, 9, 99, 1, 8], ic.ram

		# Using immediate mode, consider whether the input is equal to 8; output 1 (if it is) or 0 (if it is not).
		ic.execute('3,3,1108,-1,8,3,4,3,99')
		assert_equal 0, ic.ram[3]

		# Using immediate mode, consider whether the input is less than 8; output 1
		ic.execute('3,3,1107,-1,8,3,4,3,99')
		assert_equal 1, ic.ram[3]
	end

	focus
	def test_jump
		ic = IntComputer.new
		ic.execute('3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9')
		assert_equal [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, 1, 1, 1, 9], ic.ram
		assert_equal 0, ic.input.size, 'No input'

		ic.input << 0
		ic.execute('3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9')
		assert_equal [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, 0, 0, 1, 9], ic.ram

		#  999: input < 8
		# 1000: input = 8
		# 1001: input > 8
		program = '3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99'
		ic.input << 4
		ic.execute(program)
		assert_equal [3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36, 98, 0, 4, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000, 1, 20, 4, 20, 1105, 1, 46, 98, 99], ic.ram
		assert_equal 999, ic.ram[32]

		ic.input << 16
		ic.execute(program)
		assert_equal 20, ic.ram[41]

		ic.input << 8
		ic.execute(program)
		assert_equal 20, ic.ram[41]
	end

end