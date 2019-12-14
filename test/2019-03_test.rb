require 'minitest'
require 'minitest/autorun'
require './src/2019-03'

class TestDay03 < Minitest::Test
	def test_grid
		p1 = Path.new('R8,U5,L5,D3')
		p2 = Path.new('U7,R6,D4,L4')
		grid = Grid.new
		grid.path(1,1,p1)
		assert_equal 0, grid.crosses.size

		grid.path(1,1,p1)
		assert_equal 0, grid.crosses.size

		grid.path(1,1,p2)
		assert_equal 2, grid.crosses.size
	end

	def test_path
		grid = Grid.new
		assert_equal [1, 2], grid.path(1, 1, 'U1')
		assert_equal [1, 3], grid.path(1, 1, 'U2')
		assert_equal [5, 3], grid.path(5, 5, 'D2')

		p1 = Path.new('R8,U5,L5,D3')
		assert_equal 9, Path.new('U9').distance
		assert_equal -9, Path.new('D9').distance
		assert_equal 4, Path.new('U2,R2').distance

		grid = Grid.new
		p1 = Path.new('R75,D30,R83,U83,L12,D49,R71,U7,L72')
		p2 = Path.new('U62,R66,U55,R34,D71,R55,D58,R83')
		grid.path(1,1,p1)
		grid.path(1,1,p2)
		assert_equal 159, grid.closest_cross.distance

		grid = Grid.new
		grid.path(1,1,'R75,D30,R83,U83,L12,D49,R71,U7,L72')
		grid.path(1,1,'U62,R66,U55,R34,D71,R55,D58,R83')
		assert_equal 122, grid.crosses.size
		assert_equal 159, grid.closest_cross.distance

		grid = Grid.new
		grid.path(1,1,'R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51')
		grid.path(1,1,'U98,R91,D20,R16,D67,R40,U7,R15,U6,R7')
		assert_equal 135, grid.closest_cross.distance

	end
end
