require 'minitest'
require 'minitest/autorun'
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

end