require 'byebug'

class Planet
	attr_accessor :name, :parent, :depth, :children
	def initialize(name)
		@name = name
		@children = []
	end
end

def visit_parent(node, ss, level=0)
	#return if name.nil?
	#node = ss[name]
	#puts '..%s %s' % ['..' * level, node.name ]
	return level unless parent = node.parent
	find_parent(parent.name, ss, level+1)
end

def visit_children(node, depth)
  node.depth = depth
  node.children.each do |child|
  	visit_children(child, depth + 1)
  end
end

def load_system(io)
	ss = Hash.new
	while line = io.gets
		line.chomp
		name1, name2 = line.chomp.split(')')
		p1 = p2 = nil
		unless p1 = ss[name1]
			p1 = Planet.new(name1)
			ss[name1] = p1
		end

		unless p2 = ss[name2]
			p2 = Planet.new(name2)
			p2.parent = p1
			ss[name2] = p2
		end
		p1.children << p2
	end
	puts "Loaded #{ss.size} objects"
	ss
end

def path_to(node)
  path = []
  while parent = node.parent do
    path.append(parent)
    node = parent
  end
  path
end


def count_paths(ss)
	n = 0
	ss.keys.each do |name|
		i = visit_parent(name, ss)
		n += i
	end
	puts 'Counted %d' % n
	visit_children(ss['COM'], 0)
	n = 0
	ss.each do |_k, node|
		n += node.depth
	end
	puts 'Counted %d' % n


end

def process_file(filename)
	File.open(filename,'r+') do |io|
		count_paths(load_system(io))
	end
end

if __FILE__ == $0
	want = 227612
	filename = 'data/2019-06.input.txt'
	process_file(filename)
end

__END__

