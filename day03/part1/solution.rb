# frozen_string_literal: true

def csv_as_matrix
  @csv_as_matrix ||= File.readlines('../input.txt').map { _1.strip.split('') }
end

NUMS = ('0'..'9').to_a.freeze
all_valid_nums = []

def a_symbol?(elem) = !elem.nil? && !NUMS.include?(elem) && !elem.eql?('.')

def relative_upper_row(row_index)
  return false if row_index <= 0

  row_index - 1
end

def relative_bottom_row(row_index)
  return false if row_index >= csv_as_matrix.size - 1

  row_index + 1
end

def any_symbol_on_adjacent_row?(row_index, starting_num_index, ending_num_index, position: :upper)
  matrix_limit_check = position.eql?(:upper) ? row_index.zero? : row_index.eql?(csv_as_matrix.size - 1)
  return false if matrix_limit_check

  row_index = position.eql?(:upper) ? row_index - 1 : row_index + 1

  relevant_row = csv_as_matrix[row_index]
  elements = relevant_row[starting_num_index..ending_num_index]
  elements.any? { a_symbol?(_1) }
end

def any_symbol_on_left_or_right?(row_index, starting_num_index, ending_num_index)
  left_element = csv_as_matrix[row_index][starting_num_index - 1]
  right_element = csv_as_matrix[row_index][ending_num_index + 1]

  a_symbol?(left_element) || a_symbol?(right_element)
end

def any_symbol_on_any_diagonal?(row_index, starting_num_index, ending_num_index) # rubocop:disable Metrics/AbcSize
  has_symbol = false

  if (upper_row = relative_upper_row(row_index))
    has_symbol = true if a_symbol?(csv_as_matrix[upper_row][starting_num_index - 1])
    has_symbol = true if a_symbol?(csv_as_matrix[upper_row][ending_num_index + 1])
  end

  if (bottom_row = relative_bottom_row(row_index))
    has_symbol = true if a_symbol?(csv_as_matrix[bottom_row][starting_num_index - 1])
    has_symbol = true if a_symbol?(csv_as_matrix[bottom_row][ending_num_index + 1])
  end

  has_symbol
end

csv_as_matrix.each_with_index do |row, i|
  current_num = []
  ending_num_index = nil

  row.each_with_index do |_, j|
    next if csv_as_matrix[i][j].eql?('.')
    next if ending_num_index && ending_num_index >= j
    next unless NUMS.include?(csv_as_matrix[i][j])

    while_iterator = j
    starting_num_index = j

    while NUMS.include?(csv_as_matrix[i][while_iterator + 1])
      current_num << csv_as_matrix[i][while_iterator + 1]
      while_iterator += 1
    end

    ending_num_index = while_iterator

    num = row[starting_num_index..ending_num_index].join.to_i

    valid_num = any_symbol_on_adjacent_row?(i, starting_num_index, ending_num_index, position: :upper) ||
                any_symbol_on_adjacent_row?(i, starting_num_index, ending_num_index, position: :bottom) ||
                any_symbol_on_left_or_right?(i, starting_num_index, ending_num_index) ||
                any_symbol_on_any_diagonal?(i, starting_num_index, ending_num_index)

    all_valid_nums << num.to_i if valid_num
  end
end

puts all_valid_nums.sum
