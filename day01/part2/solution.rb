file_lines = File.readlines('../input.txt')

POSSIBLE_NUMBER_STRINGS = [
  'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'
]

# Generate as REGEX like so: (?=(\d|zero|one|two|three|four|five|six|seven|eight|nine)){1}
# It uses the positive lookahead (?=) to match overlapping names so "oneight" would match
#   both "one" and "eight"
THE_REGEX = /(?=(\d|#{POSSIBLE_NUMBER_STRINGS.join('|')})){1}/

# Gets 'one' and returns '1', 'two' and returns '2' and so on...
def number_name_to_integer_string(name)
  if POSSIBLE_NUMBER_STRINGS.include?(name)
    return (POSSIBLE_NUMBER_STRINGS.index(name) + 1).to_s
  end

  name
end

total = file_lines.map do |line|
  matching_numbers = line.scan(THE_REGEX).flatten
  matching_numbers = matching_numbers.map { number_name_to_integer_string(_1) }
  puts [line, (matching_numbers.first + matching_numbers.last).to_i].inspect
  (matching_numbers.first + matching_numbers.last).to_i
end.sum

puts total