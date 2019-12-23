require 'test/unit'
require 'byebug'
require 'set'

# Definitions
# total energy for a single moon is its potential energy multiplied by its kinetic energy
# potential energy is the sum of the absolute values of its x, y, and z position coordinates.
# kinetic energy is the sum of the absolute values of its velocity coordinates
module AOC
    class System
        attr_reader :objects
        def initialize(filename)
            @tick_count = 0
            @objects = []
            load_input(filename)
        end

        def tick
            # apply gravity.
            @objects.each_with_index do |o1, idx|
                @objects.each do |o2|
                    next if o1.object_id == o2.object_id
                    # %w/x y z/
                    [0, 1, 2].each do |axis|
                        a1 = o1[axis]
                        a2 = o2[axis]
                        if a1 < a2
                            o1[axis + 3] += 1
                        elsif a1 > a2
                            o1[axis + 3] -= 1
                        else
                        #   puts 'NOOP equal i:%d a:%d %p' % [idx, axis, o1]
                        end
                        #puts 'equal i:%d a:%d %p' % [idx, axis, o1]
                    end
                end
            end
            # Update positions
            @objects.each_with_index do |o1, idx|
                [0, 1, 2].each do |axis|
                    vel = o1[axis + 3]
                    o1[axis] += vel
                end
            end
            @tick_count += 1
            self
        end
        def energy
            total = 0
            @objects.each_with_index do |o1, idx|
                pot = kin = 0
                [0, 1, 2].each do |axis|
                    pot += o1[axis].abs
                    kin += o1[axis + 3].abs
                end
                total += (pot * kin)
            end
            total
        end

        # Velocity deltas to apply to 1st moon
        # m2 = Matrix[ [0, 0, 0], [1, -1, -1], [1, -1, 1], [1, 1, -1]]
        #
        # m1 = Matrix[[-1,0,2]]
        # m2 = Matrix[[3,-1,-1]]
        # m1 + m2  # => Matrix[[2, -1, 1]]
        def tick_by_matrix
            # apply gravity by updating velocity
            @objects.each_with_index do |o1, i1|
                m1 = Matrix.zero(1,3)
                d1 = [0, 0, 0]
                @objects.each_with_index do |o2, i2|
                    d2 = [0, 0, 0]
                    [0, 1, 2].each do |axis|
                        a1 = o1[axis]
                        a2 = o2[axis]
                        value = if a1 < a2
                            1
                        elsif a1 > a2
                            -1
                        else
                            0
                        end
                        d2[axis] = value
                        d1[axis] += value
                    end
                    m2 = Matrix[d2]
                    m1 = m1 + m2
                    puts '%d %d o1: %p o2: %p d1: %p d2: %p' % [i1, i2, o1[0,3], o2[0,3], d1, d2]
                end
                d1.each_with_index do |d,i|
                    o1[i] += 1
                end
            end
            @tick_count += 1
            self
        end

        def axis_state(i)
            @objects.map{|o| [o[i], o[i + 3]]}.flatten
        end

        def each_axis(&block)
            (0..2).each do |axis|
                yield axis
            end
        end

        def find_repeat
            seen = Hash.new
            each_axis do |axis|
                seen[axis] = Set.new
                seen[axis].add(axis_state(axis))
            end

            lcm = {}
            loop do
                tick
                each_axis do |axis|
                    state = axis_state(axis)
                    if seen[axis].include?(state)
                        lcm[axis] ||= @tick_count
                    else
                        seen[axis].add(state)
                    end
                end
                break if lcm.size == 3
            end
            puts '%p' % [lcm]
            lcm.map(&:last).reduce(&:lcm)
        end

        def load_input(filename)
            File.readlines(filename).each do |line|
                x,y,z = line.scan(/-*\d+/).map(&:to_i)
                @objects << [x, y, z, 0, 0, 0]
            end
            # [0,1,2].each do |axis|
            #     @seen[axis].add(axis_state(axis))
            # end
        end

    end

    class Loader
        # Return sparse array
        def self.load_example(filename)
            hash = Hash.new
            key = nil
            File.readlines(filename).each do |line|
                if line =~ /After (\d+) steps/
                    key = $1.to_i
                    hash[key] = []
                elsif line =~ /^pos/
                    hash[key] << line.scan(/-*\d+/).map(&:to_i)
                end
            end
            hash
        end
    end
end

def day12_part1_test
    sys = AOC::System.new('data/2019-12.ex1.txt')
    assert_equal 4, sys.objects.size
    sys.tick
    assert_equal [2,-1, 1, 3,-1,-1], sys.objects[0]
    assert_equal [3,-7,-4, 1, 3, 3], sys.objects[1]
end

def day12_part1
    sys = AOC::System.new('data2/2019-12.input.txt')
    1000.times do
        sys.tick
    end
    answer = sys.energy
    assert_equal 7687, answer, 'Known answer'
    puts 'Day 12 Part 1 answer %p' % answer
end

def day12_part2
    sys = AOC::System.new('data2/2019-12.input.txt')
    answer = sys.find_repeat
    assert_equal 334945516288044, answer, 'Known answer'
    puts 'Day 12 Part 2 answer %p' % answer
end

if __FILE__ == $0
    extend Test::Unit::Assertions
    day12_part1_test
    day12_part1
    day12_part2
end

