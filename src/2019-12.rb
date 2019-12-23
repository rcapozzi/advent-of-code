require 'test/unit'
require 'byebug'


# Matrix of positions
# Matrix of velocities

# Definitions
# total energy for a single moon is its potential energy multiplied by its kinetic energy
# potential energy is the sum of the absolute values of its x, y, and z position coordinates.
# kinetic energy is the sum of the absolute values of its velocity coordinates
module AOC
    class System
        attr_reader :objects
        def initialize
            @tick_count = 0
            @objects = []
            #@pos = []
            #@vel = []
        end

        def add_object(x, y, z)
            @objects << [x, y, z, 0, 0, 0]
            #@pos << [x, y, z]
            #@vel << [0, 0, 0]
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
                            #puts 'NOOP equal i:%d a:%d %p' % [idx, axis, o1]
                        end
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
            save_state
            @tick_count += 1
            self
        end
        def save_state
            @seen[@objects[0,3]] = @count
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

    end
end

class Moon
    attr_accessor :x, :y, :z, :vx, :vy, :vz
    def initialize(x,y,z)
        @x, @y, @z = x, y, z
        @vx = @vy = @vz = 0
    end
end

def load_input(filename)
    data = []
    File.readlines(filename).each do |line|
        data << line.scan(/-*\d+/).map(&:to_i)
    end
    data
end

def day12_part1_test
    data = load_input(filename='data/2019-12.ex1.txt')
    assert_equal 4, data.size
    sys = AOC::System.new()
    data.each do |line|
        sys.add_object(*line)
    end
    puts 'System: %p' % sys
    sys.tick
    puts 'System: %d: %p' % [sys.energy, sys]
    assert_equal [2,-1, 1, 3,-1,-1], sys.objects[0]
    assert_equal [3,-7,-4, 1, 3, 3], sys.objects[1]
end
def day12_part1
    data = load_input(filename='data2/2019-12.input.txt')
    sys = AOC::System.new()
    data.each do |line|
        sys.add_object(*line)
    end
    1000.times do
        sys.tick
    end
    answer = sys.energy
    assert_equal 7687, answer, 'Known answer'
    puts 'Day 12 Part 1 answer %p' % answer

end
if __FILE__ == $0
    extend Test::Unit::Assertions
    day12_part1_test
    day12_part1
end

__END__
<x=16, y=-8, z=13>
<x=4, y=10, z=10>
<x=17, y=-5, z=6>
<x=13, y=-3, z=0>
