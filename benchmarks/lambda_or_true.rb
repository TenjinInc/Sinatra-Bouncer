require 'benchmark'

# Testing whether it is faster for simple #can statements to use a shared lamda that returns true, distinct lamdas for
# each statement or the true constant
#
# General expectation is it does not matter enough at most scales to matter, but worth verifying.
# The results to evaluate are 'X and sometimes', which emulate a 50-50 split of #can and #can_sometimes statements
#
# Result: as of ruby 3.1, the difference is ~10%, but on negligible time scales. Further, added complexity degrades
# the development experience (and potentially risks accidental rule-passing). Overall, likely isn't worth it.

# big N to be measurable
n = 1000000

true_array            = Array.new(n, true)
shared_lambda         = lambda do
   true
end
shared_lambda_array   = Array.new(n, shared_lambda)
distinct_lambda_array = Array.new(n) do
   lambda do
      true
   end
end

sometimes_lambda_array = Array.new(n) do
   lambda do
      # this would normally be checking vs a database or some model object,
      # so doing a makework test here to emulate that
      (0..4).cover? rand(5)
   end
end

true_and_sometimes_array     = true_array.slice(0...(true_array.length / 2)) +
      sometimes_lambda_array.slice(0...(true_array.length / 2))
shared_and_sometimes_array   = shared_lambda_array.slice(0...(true_array.length / 2)) +
      sometimes_lambda_array.slice(0...(true_array.length / 2))
distinct_and_sometimes_array = distinct_lambda_array.slice(0...(true_array.length / 2)) +
      sometimes_lambda_array.slice(0...(true_array.length / 2))

puts 'Array Lengths'
puts true_array.length
puts shared_lambda_array.length
puts distinct_lambda_array.length
puts true_and_sometimes_array.length
puts shared_and_sometimes_array.length
puts distinct_and_sometimes_array.length

# using bmbm to also check for whether Ruby caches responses from simple lambdas
# using #all? to emulate the big-O case where it's the last rule that passes
Benchmark.bmbm(20) do |x|
   x.report 'pure true' do
      true_array.all? do |element|
         element
      end
   end

   x.report 'pure shared lambda' do
      shared_lambda_array.all? do |element|
         element.call
      end
   end

   x.report 'pure distinct lambda' do
      distinct_lambda_array.all? do |element|
         element.call
      end
   end

   x.report 'true and sometimes' do
      true_and_sometimes_array.all? do |element|
         element == true ? element : element.call
      end
   end

   x.report 'shared and sometimes' do
      shared_and_sometimes_array.all? do |element|
         element == true ? element : element.call
      end
   end

   x.report 'distinct and sometimes' do
      distinct_and_sometimes_array.all? do |element|
         element == true ? element : element.call
      end
   end
end
