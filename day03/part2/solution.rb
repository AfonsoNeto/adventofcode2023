# frozen_string_literal: true

def csv_as_matrix
  @csv_as_matrix ||= File.readlines('../input.txt').map { _1.strip.split('') }
end

NUMS = ('0'..'9').to_a.freeze
all_valid_gears = []

def a_star_symbol?(elem) = elem.eql?('*')
def a_number?(elem) = !elem.nil? && NUMS.include?(elem)

def relative_upper_row(row_index)
  return false if row_index <= 0

  row_index - 1
end

def relative_bottom_row(row_index)
  return false if row_index >= csv_as_matrix.size - 1

  row_index + 1
end

def any_x_on_adjacent_row?(row_index, starting_num_index, ending_num_index, position: :upper, x_proc: Proc.new)
  matrix_limit_check = position.eql?(:upper) ? row_index.zero? : row_index.eql?(csv_as_matrix.size - 1)
  return false if matrix_limit_check

  row_index = position.eql?(:upper) ? row_index - 1 : row_index + 1

  relevant_row = csv_as_matrix[row_index]
  elements = relevant_row[starting_num_index..ending_num_index]
  elements.any? { x_proc.call(_1) }
end

def any_star_symbol_on_adjacent_row?(row_index, starting_num_index, ending_num_index, position: :upper)
  any_x_on_adjacent_row?(
    row_index, starting_num_index, ending_num_index, position: position, x_proc: method(:a_star_symbol?)
  )
end

def any_number_on_adjacent_row?(row_index, starting_num_index, ending_num_index, position: :upper)
  any_x_on_adjacent_row?(
    row_index, starting_num_index, ending_num_index, position: position, x_proc: method(:a_number?)
  )
end

def any_gear_part_on_adjacent_row?(row_index, starting_num_index, ending_num_index, position: :upper)
  next_row = position.eql?(:upper) ? row_index - 1 : row_index + 1
  second_row = position.eql?(:upper) ? next_row - 1 : next_row + 1

  is_a_gear_part = false
  gear_part = nil

  is_a_gear_part = any_star_symbol_on_adjacent_row?(row_index, starting_num_index, ending_num_index, position: position) &&
                    (
                      any_number_on_adjacent_row?(next_row, starting_num_index, ending_num_index, position: position) ||
                      any_number_on_adjacent_row?(next_row, starting_num_index - 1, ending_num_index, position: position) ||
                      any_number_on_adjacent_row?(next_row, starting_num_index, ending_num_index + 1, position: position)
                    )

  gear_part = find_relative_gear_part(second_row, starting_num_index, ending_num_index) if is_a_gear_part
  gear_part = find_relative_gear_part(second_row, starting_num_index, ending_num_index + 1) if is_a_gear_part && gear_part.nil?
  gear_part = find_relative_gear_part(second_row, starting_num_index - 1, ending_num_index) if is_a_gear_part && gear_part.nil?

  [is_a_gear_part, gear_part]
end

def any_gear_part_on_left_or_right?(row_index, starting_num_index, ending_num_index, position: :upper)
  left_element = csv_as_matrix[row_index][starting_num_index - 1]
  right_element = csv_as_matrix[row_index][ending_num_index + 1]

  next_left_element = csv_as_matrix[row_index][starting_num_index - 2]
  next_right_element = csv_as_matrix[row_index][ending_num_index + 2]

  is_a_gear_part = false
  gear_part = nil

  is_gear_part_from_left = (a_star_symbol?(left_element) && a_number?(next_left_element))
  is_gear_part_from_right = (a_star_symbol?(right_element) && a_number?(next_right_element))
  is_a_gear_part = is_gear_part_from_left || is_gear_part_from_right

  if is_a_gear_part
    if is_gear_part_from_left
      custom_range_check = Proc.new do |range|
        range.include?(starting_num_index - 2)
      end
      left_gear_part = find_relative_gear_part(row_index, starting_num_index - 1, ending_num_index, custom_range_check:)

    elsif is_gear_part_from_right
      custom_range_check = Proc.new do |range|
        range.include?(ending_num_index + 2)
      end
      right_gear_part = find_relative_gear_part(row_index, starting_num_index, ending_num_index + 2, custom_range_check:)
    end

    gear_part = left_gear_part || right_gear_part
  end

  [is_a_gear_part, gear_part]
end

def any_gear_part_on_any_diagonal?(row_index, starting_num_index, ending_num_index)
  has_symbol_on_upper_row = false
  has_symbol_on_bottom_row = false

  has_symbol_on_upper_row_from_the_left = false
  has_symbol_on_upper_row_from_the_right = false

  has_symbol_on_bottom_row_from_the_left = false
  has_symbol_on_bottom_row_from_the_right = false

  has_number_on_next_upper_row = false
  has_number_on_next_bottom_row = false

  is_a_gear_part = false
  gear_part = nil

  if (upper_row = relative_upper_row(row_index))
    if a_star_symbol?(csv_as_matrix[upper_row][starting_num_index - 1])
      has_symbol_on_upper_row = true
      has_symbol_on_upper_row_from_the_left = true
      
    elsif a_star_symbol?(csv_as_matrix[upper_row][ending_num_index + 1])
      has_symbol_on_upper_row = true
      has_symbol_on_upper_row_from_the_right = true

    end

    if has_symbol_on_upper_row_from_the_left && a_number?(csv_as_matrix[upper_row -1][starting_num_index - 2])
      has_number_on_next_upper_row = true

      if has_symbol_on_upper_row_from_the_left
        custom_range_check = Proc.new do |range|
          range.include?(starting_num_index - 2)
        end
        gear_part = find_relative_gear_part(upper_row - 1, starting_num_index - 2, ending_num_index)
      end
      
    elsif has_symbol_on_upper_row_from_the_right && a_number?(csv_as_matrix[upper_row -1][ending_num_index + 2])
      has_number_on_next_upper_row = true

      if has_symbol_on_upper_row_from_the_right
        custom_range_check = Proc.new do |range|
          range.include?(ending_num_index + 2)
        end
        gear_part = find_relative_gear_part(upper_row - 1, starting_num_index, ending_num_index + 2)
      end
    end
  end
  
  if (bottom_row = relative_bottom_row(row_index))
    if a_star_symbol?(csv_as_matrix[bottom_row][starting_num_index - 1])
      has_symbol_on_bottom_row = true
      has_symbol_on_bottom_row_from_the_left = true

    elsif a_star_symbol?(csv_as_matrix[bottom_row][ending_num_index + 1])
      has_symbol_on_bottom_row = true
      has_symbol_on_bottom_row_from_the_right = true

    end

    if !csv_as_matrix[bottom_row + 1].nil?
      if has_symbol_on_bottom_row_from_the_left && a_number?(csv_as_matrix[bottom_row + 1][starting_num_index - 2])
        has_number_on_next_bottom_row = true

        if has_symbol_on_bottom_row_from_the_left
          custom_range_check = Proc.new do |range|
            range.include?(starting_num_index - 2)
          end
          gear_part = find_relative_gear_part(bottom_row + 1, starting_num_index - 2, ending_num_index)
        end

      elsif has_symbol_on_bottom_row_from_the_right && a_number?(csv_as_matrix[bottom_row + 1][ending_num_index + 2])
        has_number_on_next_bottom_row = true

        if has_symbol_on_bottom_row_from_the_right
          custom_range_check = Proc.new do |range|
            range.include?(ending_num_index + 2)
          end
          gear_part = find_relative_gear_part(bottom_row + 1, starting_num_index, ending_num_index + 2)
        end
      end
    end
  end

  is_a_gear_part = (has_symbol_on_upper_row && has_number_on_next_upper_row) ||
                    (has_symbol_on_bottom_row && has_number_on_next_bottom_row)
  
  [is_a_gear_part, gear_part]
end

def find_relative_gear_part(target_row_index, starting_num_index, ending_num_index, custom_range_check: nil)
  next_row_as_line = csv_as_matrix[target_row_index].join('')
  matched_nums_in_row = next_row_as_line.to_enum(:scan, /\d+/).map { Regexp.last_match }
  matched_nums_in_row = matched_nums_in_row.map { [_1, _1.offset(0)] }
  
  gear_part = matched_nums_in_row.find do |elems|
    # [MatchData '123', [1, 2]]
    range = Range.new(*elems[1])

    if custom_range_check
      custom_range_check.call(range)
    else
      range.include?(starting_num_index) || range.include?(ending_num_index)
    end
  end
  
  gear_part = gear_part[0].to_s.to_i if gear_part
end

#=START(MAIN BLOCK) ----------------------------------------
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

    gear_part_on_upper_row, gear_part_on_upper   = any_gear_part_on_adjacent_row?(i, starting_num_index, ending_num_index, position: :upper)
    gear_part_on_bottom_row, gear_part_on_bottom = any_gear_part_on_adjacent_row?(i, starting_num_index, ending_num_index, position: :bottom)
    gear_part_on_left_or_right, gear_on_left_or_right = any_gear_part_on_left_or_right?(i, starting_num_index, ending_num_index)
    gear_part_on_any_diagonal, gear_part_on_diagional = any_gear_part_on_any_diagonal?(i, starting_num_index, ending_num_index)

    valid_num = gear_part_on_upper_row ||
                gear_part_on_bottom_row ||
                gear_part_on_left_or_right ||
                gear_part_on_any_diagonal

    if valid_num
      all_valid_gears << {
        num:,
        gear_part: (
          gear_part_on_upper || gear_part_on_bottom || gear_on_left_or_right || gear_part_on_diagional
        )
      }
    end
  end
end
#=END(MAIN BLOCK) ----------------------------------------

all_valid_gear_parts_pairs = all_valid_gears.map { [_1[:num], (_1[:gear_part])] }

# all_valid_gear_parts_pairs = all_valid_gear_parts_pairs.map(&:sort).uniq
puts all_valid_gear_parts_pairs.inspect
all_gears_ratios = all_valid_gear_parts_pairs.map { _1[0] * _1[1] }

puts(all_gears_ratios.sum)