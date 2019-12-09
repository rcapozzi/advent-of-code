require 'minitest'
require 'minitest/autorun'
require './src/2019-01'

class TestDay01 < Minitest::Test
	def test_calc_fuel
		mass, fuel = fuel_for_filename('./data/2019-01')
		assert_equal 10198868, mass, 'Good mass'
		assert_equal 3399394, fuel, 'Good fuel'
	end
end