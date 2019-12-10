require 'minitest'
require 'minitest/autorun'
require './src/2019-02'

class T2019_02 < Minitest::Test
	def test_day02_xxx
		# initial, final
		data = [
			['1,9,10,3,2,3,11,0,99,30,40,50', '3500,9,10,70,2,3,11,0,99,30,40,50'],
			['1,0,0,0,99', '2,0,0,0,99'],
			['2,3,0,3,99', '2,3,0,6,99'],
			['1,1,1,4,99,5,6,0,99', '30,1,1,4,2,5,6,0,99'],
		]
		
		data.each_with_index do |item, idx|
			assert_equal item[1], intCode(item[0]), "Gravey #{idx}"
		end
	end
end