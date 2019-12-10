require 'minitest'
require 'minitest/autorun'
require './src/2019-01'
require './src/2019-02'

class TestDay01 < Minitest::Test
	def test_calc_fuel
		mass, fuel = fuel_for_filename('./data/2019-01')
		assert_equal 10198868, mass, 'Good mass'
		assert_equal 3399394, fuel, 'Good fuel'
	end

	def test_fuel_for_fuel
		actual = fuel_for_fuel(100756)
		expected = 50346
		assert_equal expected, actual, 'Pizza is better with cheese'
	end

	def test_day02_xxx
		str0 = "1,9,10,3,2,3,11,0,99,30,40,50"
		str1 = "1,9,10,70,2,3,11,0,99,30,40,50"
		str2 = "3500,9,10,70,2,3,11,0,99,30,40,50"

		data = [
			['1,0,0,0,99', '2,0,0,0,99'],
			['2,3,0,3,99', '2,3,0,6,99'],
			['1,1,1,4,99,5,6,0,99', '30,1,1,4,2,5,6,0,99'],
		]
		
		assert_equal data[0][1], intCode(data[0][0]), 'intCode works'
	end
end