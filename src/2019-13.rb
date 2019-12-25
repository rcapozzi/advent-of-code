require 'test/unit'
require 'byebug'
load './src/2019-11.rb'

# col = x
# row = y
# pos [0, 1] = [row, col] = [y,x]
class FrameRow
	def []=(x,y,value)
		@f[y][x] = value
	end

	def initialize(x_size,y_size)
        @f = [ ]
        y_size.times{|i| @f << ' ' * x_size}
	end

    def draw
        puts "\e[H\e[2J"
        @f.each do |row|
            puts row
        end
	end
end

class Frame
	def frame
		@f
	end

	def []=(x,y,value)
		@f[y][x] = value
	end

	def initialize(x_size,y_size)
		@yr = Range.new(0,y_size-1)
		@xr = Range.new(0,x_size-1)
		@f = [' ']  * @yr.size
		@yr.each do |row|
			cols = [' '] * @xr.max
			@f[row] = cols
		end
	end

	def draw
		puts "\e[H\e[2J"
		@yr.each do |y|
			puts @f[y].join
		end
	end
end

class Board
	attr_reader :frame, :ic, :tick, :score, :draw

	def cheat
		# 1602 starting paddle
		(1583..1621).each {|i| ic.ram[i] = 3 }
	end
	def initialize(opts=nil)
		if ic = opts[:ic]
			@ic = opts[:ic]
			@ic.ram[0] = 2
		end
		cheat() if true == opts[:cheat]
		@draw = true
		@tick = 0
		@frame = Frame.new(40, 26)
		@frame = FrameRow.new(40, 26)
		@tiles = Hash.new{|h,k| h[k] = Tile.new(k[0],k[1],nil)}
	end

	def tick(input=nil)
		results = @ic.execute(nil,input)
		update(results)
		draw_frame if @draw == true
		@tick += 1
	end

	def draw_frame
		x = 30
		x.upto(10) {|i| @frame[x, 25] = ' '}
		@tick.to_s.chars.each_with_index do |d,i|
			@frame[x+i, 25] = d
		end
		frame.draw
	end

	def draw_score
		return unless @draw == true
		x = 5
		x.upto(15) {|i| @frame[x, 25] = ' '}
		@score.to_s.chars.each_with_index do |d,i|
			@frame[x+i, 25] = d
		end
	end

	def update(results)
		results.each_slice(3) do |x,y,id|
			if -1 == x and 0 == y
				@score = id
				draw_score
				next
			end
			if id == 4
				@ball = [x,y]
			end
			@tiles[[ x, y ]].id = id
			@frame[x, y] = @tiles[[ x, y ]].char
		end
		self
	end

	def run
		loop do
			tick(0)
			sleep 0.05 if @draw == true
			break if ic.is_halted?
		end
	end

end

class Tile
	def initialize(x,y,tile_id)
		@x,@y = x,y
		self.id = tile_id
	end
	def id=(value)
		@id = value
		@char = case @id
		when 0 then ' '    # empty
		when 1 then "|" # wall \xDB
		when 2 then '#'    # block
		when 3 then '='    # paddle
		when 4 then 'O'    # ball
		else '!'
		end
	end
	def char
		@char
	end

	def inspect
		'#<T %d:%d "%s">' % [@x,@y,@char]
	end
end

module AOC
	class Day13
		def self.part1(filename)
			program = File.read(filename).chomp
			results = IntComputer.new(program).execute
			blocks = results.each_slice(3).count{|i| i[2] == 2}
		end

		def self.part2(filename)
			program = File.read(filename).chomp
			board = Board.new(ic: IntComputer.new(program), cheat: true, draw: false)
			board.run
			puts 'Game over tick: %d' % board.tick
			board.score
		end

	end
end

def day13_part1_test
end

def day13_part1
	filename = ARGV[0] || 'data2/2019-13.input.txt'
	answer = AOC::Day13.part1(filename)
	assert_equal 230, answer, 'Accepted answer'
	puts 'Day 13 Part 1: %s' % answer
end

def day13_part2
	filename = ARGV[0] || 'data2/2019-13.input.txt'
	answer = AOC::Day13.part2(filename)
	puts 'Day 13 Part 2: %s' % answer
	assert_equal 11140, answer, 'Accepted answer'
end

if __FILE__ == $0
	extend Test::Unit::Assertions
	day13_part1_test
	day13_part1
	day13_part2
end
