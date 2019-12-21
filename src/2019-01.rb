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

# break when additional amount is below 0
# returns the fuel needed for fuel
def fuel_for_fuel(mass, total=0)
	fuel = fuel_for_mass(mass)
	if fuel < 0
		return total
	end
	total += fuel
	fuel_for_fuel(fuel,total)
end

def fuel_for_filename(filename)
	total_mass = 0
	total_fuel = 0
	total_f4f = 0
	File.open(filename).each do |line|
		mass = line.chomp.to_i
		fuel = fuel_for_mass(mass)
		f4f  = fuel_for_fuel(fuel)
		total_mass += mass
		total_fuel += fuel
		total_f4f += f4f
	end
	[ total_mass, total_fuel, total_f4f ]
end

def day01
	mass, fuel, f4f = fuel_for_filename('./data2/2019-01.input.txt')
	total_fuel = fuel + f4f
	puts "mass=%d, fuel: %d, f4f: %d, total: %d" % [ mass, fuel, f4f, total_fuel ]
end

if __FILE__ == $0
	day01()
end
