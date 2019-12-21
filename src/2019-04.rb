require 'test/unit'
require 'byebug'

extend Test::Unit::Assertions

# Need to see a char twice
def has_double?(str)
	seen = str.chars.inject(Hash.new(0)) { |m, d| m[d] += 1; m}
	seen.has_value?(2)
end

def has_adjacent?(str)
	return str =~ /(\d)\1+/ ? true : false
end

def increasing?(str)
	str.size.times do |i|
		next if i == 0
		return false if str[i-1] > str[i]
	end
	true
end

def valid_password?(str)
	return -1 unless str =~ /^\d{6,6}$/
	return -1 unless has_adjacent?(str)
	return -1 unless increasing?(str)
	return 1
end

def valid_password2?(str)
	return -1 unless str =~ /^\d{6,6}$/
	return -1 unless has_double?(str)
	return -1 unless increasing?(str)
	return 1
end

def try0()
	input = '130254-678275'
	ordered_input = input.chars.sort.join

	n = 0
	ordered_input.size.times do |i|
		pw = ordered_input[i,6]
		break if pw.size != 6
		is_valid = valid_password?(pw)
		if is_valid > 0
			n += 1
		end
		puts "#{pw} #{is_valid} #{n}"
	end
	puts "Valid possible passwords #{input} -> #{ordered_input}: #{n}"
end

def try1()
	input = File.read(ARGV[0]).chomp rescue '130254-678275'
	if input =~ /(\d+)-(\d+)/
		i_start, i_end = $1.to_i, $2.to_i
	end
	puts "Finding valid passwords for #{i_start} to #{i_end}"
	seen = Hash.new
	v1 = v2 = skips = 0
	i_start.upto(i_end) do |i|
		key = i.to_s.chars.map(&:to_i).sort.join
		#key = i.digits.sort.join
		i_key = key.to_i
		if i_key < i_start || i_key > i_end || seen[key]
			skips += 1
			next
		end
		password = i.to_s
		if valid_password?(password) > 0
			v1 += 1
		end
		if valid_password2?(password) > 0
			v2 += 1
		end
		seen[key] = [v1, v2]
	end
	puts "valid passwords for #{i_start} to #{i_end}: v1: #{v1}, v2: #{v2}"
	puts "Seen values #{seen.keys.size} skips: #{skips}"
end

if __FILE__ == $0
	# Test methods
	assert_equal -1, valid_password?('11111'), 'Fail 5 digits'
	assert_equal -1, valid_password?('1111111'), 'Fail 7 digits'
	assert_equal -1, valid_password?('123456'), 'No adjacent digits'
	assert_equal -1, valid_password?('123321'), 'decreasing digits'

	assert_equal -1, valid_password?('223450'), 'No decreasing digits'
	assert_equal -1, valid_password?('123789'), 'No double'
	assert_equal 1, valid_password?('111111'), 'Valid password'

	# Part 2
	assert_equal true, has_double?('112233'), 'Valid'
	assert_equal false, has_double?('123444'), 'Invalid'
	assert_equal true, has_double?('111122'), 'Valid'

	assert_equal 1, valid_password2?('112233'), 'Valid'
	assert_equal -1, valid_password2?('123444'), 'Invalid'
	assert_equal 1, valid_password2?('111122'), 'Valid'

	try1()
end
__END__
