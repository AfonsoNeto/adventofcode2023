file_lines = File.readlines('input.txt')

file_lines.map do |line|
  matching_numbers = line.scan(/\d{1}/)
  (matching_numbers.first + matching_numbers.last).to_i
end.sum