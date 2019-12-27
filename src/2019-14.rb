require 'matrix'
require 'test/unit'
require 'byebug'

module AOC

class Factory
	attr_accessor :inventory, :ore
	
	# I was thinking to solve the puzzle using gaus elimination
	# in which case, I'd need each chemical to be indexed for the matrix
	def self.parse_input_line(data)
		@@seen ||= Hash.new{|h,k| h[k] = h.size}
		result = []
		data.map do |item|
			id = @@seen[item[1]]
			[item[0].to_i, item[1], id ]
		end
	end

	def initialize(reactions)
		@tick = 0
		@ore = 0
		@reactions = reactions
		@reactions['ORE'] = {:batch_size=>1, :in=>[ ]}
		
		@inventory = {}
		@inventory['FUEL'] = 0
		reactions.each do |chem, r|
			r[:in].each{|(iq, iname)| @inventory[iname] = 0 }
		end
		# TODO: Why does this cause concurrent problems.
		# @inventory = Hash.new(0)
	end

	def produce(qty_desired, chemical)
		return if qty_desired < 1
		#puts 'Factory#produce enter args: %d, %s' % [qty_desired, chemical]
		reaction = @reactions[chemical]
		batch_size = reaction[:batch_size]
		batches = (qty_desired.to_f / batch_size).ceil
		qty = batches * batch_size
		@inventory[chemical] += qty
		if 'ORE' == chemical
			# puts 'ORE += %d' % [qty]
			@ore += qty
		end
		reaction[:in].each{|(iqty, iname)| consume(iqty * batches, iname) }
		self
	end
	
	def consume(qty, chemical)
		@inventory[chemical] -= qty
	end
	
	def reset
		@tick = 0
		@ore = 0
		@inventory.each{|k,v| @inventory[k] = 0}
	end

	def make(q, c)
		#puts 'MAKE for %s %s' %  [q,c]
		tock = 0
		@inventory[c] -= q
		while true
			break unless @inventory.any?{|k, v| v < 0 }
			#puts 'make-ing %p' %  self
			@inventory.each do |k, v| 
				next if v > -1
				produce(v * -1, k)
				#break
			end
			tock += 1
			@tick += 1
			if tock > 50
				puts 'Tock break %d' %  tock		
				break
			end
		end
		#puts '  Ending fac %p' %  self
	end
	
	def inspect
		'#<Factory: tick=%p ore=%p inv=%p> ' % [@tick, @ore, @inventory]
	end

end

	class Day14

		def self.binsearch(f, guess=1)
			max = target = 1000000000000
			tick = 0
			min = 0
			while true
				f.reset
				f.make(guess, 'FUEL')
				if f.ore > target
					max = guess - 1
				elsif f.ore < target
					min = guess
				end
				puts 'min: %d max: %d guess:%d ore: %d' % [min, max, guess, f.ore]
				guess = min + ((max - min) / 2)
				tick += 1
				break if min == max
				break if tick > 100
			end
		end

		def self.part1_test
			extend Test::Unit::Assertions
			data = parse_examples
			data.delete(6)

			f = AOC::Factory.new(data[1][:recipes])
			f.produce(1, "A")
			assert_equal 10, f.inventory['A']

			data.each do |k, v|
				f = AOC::Factory.new(v[:recipes])
				f.make(1, "FUEL")
				assert_equal v[:answer],  f.ore
			end
		end

		def self.part1
			extend Test::Unit::Assertions
			data = parse_examples
			f = AOC::Factory.new(data[6][:recipes])
			f.produce(1, "FUEL")
			puts 'Day 14 Part 1 answer: %s' % f.ore
		end

		def self.parse_examples(filename='data/2019-14.ex.txt')
			id = 0
			h = Hash.new
			File.readlines(filename).each do |line|
				line.chomp!
				if line =~ /^(\d+) ORE for 1 FUEL/
					id += 1
					h[id] = { answer: $1.to_i, recipes: {}, reactions: [] }
				elsif matches = line.scan(/(\d+) (\w+)/)
					if matches.size > 0
						data = Factory.parse_input_line(matches)
						output = data.pop
						batch_size, chemical = output
						h[id][:recipes][chemical] = { batch_size: batch_size, in: data }
						#h[id][:reactions] <<  { out: output, in: data }
					end
				else
					puts 'skip %s' % line
				end
			end
			h
		end
		
		def self.ex1
			ary = []
			ary << %w/10	0	0	0	0	0	0/
			ary << %w/1	0	0	0	0	0	0/
			ary << %w/0	7	1	0	0	0	0/
			ary << %w/0	7	0	1	0	0	0/
			ary << %w/0	7	0	0	1	0	0/
			ary << %w/0	7	0	0	0	1	0/
			# Convert all elements to ints
			a = ary.inject([]){|m,o| m << o.map(&:to_i) }
			b = [
[0,	10,	0,	0,	0,	0,	0],
[0,	0,	1,	0,	0,	0,	0],
[0,	0,	0,	1,	0,	0,	0],
[0,	0,	0,	0,	1,	0,	0],
[0,	0,	0,	0,	0,	1,	0],
[0,	0,	0,	0,	0,	0,	1],
]
			return [a, b]
			# Only want Fuel or Ore on one side
			ma = Matrix[a]
			mb = Matrix[b]
			a0 = [
			[10,-10,0,0,0,0],
			[1,0,-1,0,0,0],
			[0,7,1,-1,0,0],
			[0,7,0,1,-1,0],
			[0,7,0,0,1,-1],
			[0,7,0,0,0,1 ],
			]
			m1 = Matrix[a0]
			coef = Matrix[ [0,0,0,0,0,1] ]
			[m1, coef]

		end

	end

end

if __FILE__ == $0
	extend Test::Unit::Assertions
	AOC::Day14.part1_test

end

__END__
