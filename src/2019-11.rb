require 'test/unit'
require 'byebug'

class Instruction
	attr_reader :opcode, :p1, :p2, :p3, :ptr

	def initialize(int, ptr)
		str = int.to_s
		o1, o2, p1, p2, p3, p4 = str.reverse.chars.map{|e| e.to_i}
		if str.size < 2
			o2 = p1 = p2 = p3 = 0
		end
		@opcode = o1 + (10 * o2)
		@p1 = p1 || 0
		@p2 = p2 || 0
		@p3 = p3 || 0
		@ptr = ptr
	end

	def inspect
		"#<Ins %s modes: %s,%s,%s >" % [@opcode, @p1, @p2, @p3]
	end
end

class IntComputer
	attr_reader :ram, :output_result
	attr_accessor :input, :relative_base

	def is_halted?
		@halted
	end

	def ram=(program)
		@ram = Hash.new(0)
		if program.is_a?(String)
			program.split(',').each_with_index do |code, idx|
				@ram[idx] = code.to_i
			end
		else
			raise 'Expect string'
		end
	end

	def initialize(program=nil, init=nil)
		self.ram = program if program
		@op_ptr = 0
		@op_count = 0
		@input = [init].compact
		@halted = false
		@relative_base = 0
	end

	def op_input(a)
		if  @input.size == 0
			return 0
		end
		value = @input.shift or raise 'No more input'
		ram[a[0]] = value.to_i
		2
	end

	# Return pointer to ram slot
	# 0: position, 1: immediate, 2: relative:
	def addr(mode, ptr)
		if mode == 0
			@ram[ptr]
		elsif mode == 1
			ptr
		elsif mode == 2
			@relative_base + @ram[ptr]
		else
			raise 'Unsupported mode'
		end
	end

	def execute(program=nil, input=nil)
		if program
			self.ram = program
			@op_ptr = 0
		end
		@input << input if input
		@input.flatten!
		@output_result = []

		loop do
			next_op_ptr = 4
			instruction = Instruction.new(ram[@op_ptr], @op_ptr)
			@op_count += 1
			a = [ addr(instruction.p1, @op_ptr + 1),
					addr(instruction.p2, @op_ptr + 2),
					addr(instruction.p3, @op_ptr + 3)
				]
			@v = [ ram[a[0]] , ram[a[1]], ram[a[2]] ]
			@v1 = ram[a[0]]
			@v2 = ram[a[1]]
			@v3 = ram[a[2]]
#puts 'i: %d %p refs: %s vals: %s,%s,%s rbase: %s' % [@op_count, instruction, a.join(','), @v1, @v2, @v3, @relative_base]

			case instruction.opcode
			when 1
				ram[a[2]] = @v1 + @v2
			when 2
				ram[a[2]] = @v1 * @v2
			when 3
				next_op_ptr = op_input(a)
				return @output_result if next_op_ptr == 0
			when 4
				@output_result << @v1
				next_op_ptr = 2
			when 5
				if @v1 != 0
					@op_ptr = @v2
					next
				end
				next_op_ptr = 3
			when 6
				if @v1 == 0
					@op_ptr = @v2
					next
				end
				next_op_ptr = 3
			when 7
				value = @v1 < @v2 ? 1 : 0
				ram[a[2]] = value
			when 8
				value = @v1 == @v2 ? 1 : 0
				ram[a[2]] = value
			when 9
				@relative_base += @v1
				next_op_ptr = 2
			when 99
				@halted = true
				break
			else
				raise "Bad opcode #{opcode}"
			end
			@op_ptr += next_op_ptr
		end
		@output_result
	end
end


class Panel
	attr_accessor :color, :visited
	attr_reader :x, :y
	def initialize(x,y)
		@x, @y = x, y
		@color = @visited = 0
	end

	def inspect
		'<Panel %dx%d c=%d v=%d>' % [@x, @y, @color, @visited]
	end

	def paint(color)
		@color = color
		@visited += 1
	end
end

class Robot
	@@deltas = {N: [0, 1], E: [1, 0], S: [0, -1], W: [-1, 0] }
	@@compass = { N: [:W, :E], E: [:N, :S], S: [:E, :W], W: [:S, :N], }

	attr_accessor :x, :y, :facing, :panels

	def computer; @ic; end
	def pos
		[@x, @y]
	end

	def program=(str)
		@ic = IntComputer.new(str)
	end

	def initialize(program=nil,white_power=false)
		@panels = Hash.new{|h, k| h[k] = Panel.new(*k)}
		@facing = :N
		@x = @y = 0
		self.program = program if program
		paint_panel(1) if white_power
	end

	# 0: left 90 degrees. 1 right 90 degrees
	def turn(direction)
		raise 'Invalid direction' unless direction == 0 or direction == 1
		now_facing = @@compass[@facing][direction]
		dx, dy = @@deltas[now_facing]
		@x += dx
		@y += dy
		@facing = now_facing
		self
	end

	def paint_panel(color)
		panel = @panels[pos]
		panel.paint(color)
		self
	end

	def camera
		@panels[pos].color
	end

	def inspect
		cam = camera()
		'<Rob %dx%d facing=%s cam=%s>' % [@x, @y, @facing, cam]
	end

	def run
		raise 'IntComputer not initialized' unless @ic
		while true
			color, direction = @ic.execute(nil, camera)
			break if computer.is_halted?
			paint_panel(color.to_i)
			turn(direction.to_i)
		end
		self
	end

	def print
		x_range = Range.new *panels.keys.map(&:first).minmax
		y_range = Range.new *panels.keys.map(&:last).minmax
		doc = []
		y_range.reverse_each do |y|
			row = []
			x_range.each do |x|
				panel = @panels[[x,y]]
				c = panel.color == 0 ? ' ' : '0'
				row << c
			end
			doc << row.join
		end
		doc.join("\n")
	end
end

def day11_part1_test
	robot = Robot.new
	robot.program = '104,1125899906842624,99'
	assert_equal :N, robot.facing
	assert_equal [0,0], robot.pos
	assert_equal 0, robot.camera
	assert_equal [1,0], robot.turn(1).pos

	puts 'OK: day11_part1_test'
end

def day11_part1
	input = ARGV[0] || File.read('data2/2019-11.input.txt').chomp
	robot = Robot.new(input)
	robot.run
	answer = robot.panels.inject(0){|m, (k,v)| v.visited > 0 ? m+1 : m}
	puts 'Day 11 Part 1: %s' % answer
end

def day11_part2
	input = ARGV[0] || File.read('data2/2019-11.input.txt').chomp
	puts 'Day 11 Part 2:'
	puts Robot.new(input,true).run.print
end

if __FILE__ == $0
	extend Test::Unit::Assertions
	day11_part1_test
	day11_part1
	day11_part2
end


