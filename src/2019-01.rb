#!/usr/bin/env ruby

# Fuel required to launch a given module is based on its mass. Specifically,
# to find the fuel required for a module, 
# 1. take its mass, 
# 2. divide by three,
# 3. round down, and 
# 4. subtract 2.
def day01(io=$stdin)
	i = 0
	while line = io.gets
		step1 = line.chomp.to_i or abort "Time to surf"
		step2 = step1 / 3.0
		step3 = step2.floor
		step4 = step3 - 2
		i += step4
	end
	puts i
end

if __FILE__ == $0
	day01(File.open('./data/2019-01'))
end
