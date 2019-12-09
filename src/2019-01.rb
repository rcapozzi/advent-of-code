#!/usr/bin/env ruby

# Fuel required to launch a given module is based on its mass. Specifically,
# to find the fuel required for a module, 
# 1. take its mass, 
# 2. divide by three,
# 3. round down, and 
# 4. subtract 2.
def fuel_for_mass(mass)
	(mass / 3.0).floor - 2
end

def fuel_for_filename(filename)
	total_mass = 0
	total_fuel = 0
	File.open(filename).each do |line|
		mass = line.chomp.to_i
		total_mass += mass
		total_fuel += fuel_for_mass(mass)
	end
	[ total_mass, total_fuel ]
end

def day01
	mass, fuel = fuel_for_filename('./data/2019-01')
	puts "mass=%d, fuel: %d" % [ mass, fuel ]
end

if __FILE__ == $0
	day01()
end
