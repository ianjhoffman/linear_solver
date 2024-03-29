# 
# main.rb
# Tuesday, January 10th, 2017
# Ian Hoffman
# ijh6@cornell.edu
# 

require_relative 'parse'
require_relative 'equation'
require_relative 'row_reduce'

puts
puts "Welcome to the linear equation system solver! Please enter your equations below."
puts "Equations must have variables on the lhs and one value on the rhs"
puts "If you are finished entering equations, press ENTER"
puts

equations = []

# Input loop
loop do
	print "> "
	input = gets.chomp.strip
	break if input == ""
	terms, result = parse_equation(input)

	if terms.nil? or result.nil?
		puts "Unable to parse equation, please try again"
		puts
		next
	end

	equations << Equation.new(terms, result)
	# equations.last.disp # TEMP
	# puts # TEMP
end

puts
puts "Solving system of equations..."

# cross reference all equations' varnames to 
# construct matrix for Gaussian Row Reduction

all_vars = {}
equations.each {|eq| eq.varnames.each {|varname| all_vars[varname] = true}}
# equation solving fails if there are less equations than unique variables
if all_vars.size > equations.length
	puts "Not enough equations to solve system (# variables: #{all_vars.size}, # equations: #{equations.length})"
	exit 1
end

all_vars = all_vars.keys
# m x (n+1) parameter matrix, where m is # equations and n is # variables
eq_matrix = Array.new(equations.length) { Array.new(all_vars.size + 1) }

equations.each_with_index do |eq, eq_idx|
	all_vars.each_with_index do |var, var_idx|
		eq_matrix[eq_idx][var_idx] = eq.eq_terms.key?(var) ? eq.eq_terms[var] : 0
	end
	eq_matrix[eq_idx][-1] = eq.eq_res
end

puts "Linear system matrix, before Gaussian elimination:"
print_row_reduce_mat(eq_matrix)

# perform Gaussian elimination to solve linear system
eq_matrix = row_reduce(eq_matrix)

if not is_consistent(eq_matrix)
	puts "System of equations is not consistent - exiting!"
	puts
	exit 1
end

puts "Linear system matrix, after Gaussian elimination:"
print_row_reduce_mat(eq_matrix)

# continue Gauss-Jordan elimination to isolate variables,
# producing reduced row echelon form of the system matrix
eq_matrix = back_eliminate(eq_matrix)

puts "Linear system matrix, after completing Gauss-Jordan elimination:"
print_row_reduce_mat(eq_matrix)

all_vars.each_with_index do |var, idx|
	puts "#{var} = #{eq_matrix[idx][-1]}"
end
puts

