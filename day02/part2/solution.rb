# frozen_string_literal: true

file_lines = File.readlines('../input.txt')

# Stores [
#  1: { red: 12, green: 13, blue: 14, power: 2184 },
#  2: { red: 12, green: 13, blue: 14, power: 2184 }
all_rounds = []

file_lines.each do |line|
  game_id_column, game_details = line.split(':')
  game_id = game_id_column.scan(/\d+/).first.to_i
  new_hsh = { game_id:, red: 0, green: 0, blue: 0 }

  game_details.split(';').each do |detail|
    red_balls = detail.scan(/\d+ red/)
    green_balls = detail.scan(/\d+ green/)
    blue_balls = detail.scan(/\d+ blue/)

    red_balls_this_round = red_balls.map { |ball| ball.scan(/\d+/).first.to_i }.max.to_i
    new_hsh[:red] = red_balls_this_round if red_balls_this_round > new_hsh[:red]

    green_balls_this_round = green_balls.map { |ball| ball.scan(/\d+/).first.to_i }.max.to_i
    new_hsh[:green] = green_balls_this_round if green_balls_this_round > new_hsh[:green]

    blue_balls_this_round = blue_balls.map { |ball| ball.scan(/\d+/).first.to_i }.max.to_i
    new_hsh[:blue] = blue_balls_this_round if blue_balls_this_round > new_hsh[:blue]

    new_hsh[:power] = new_hsh[:red] * new_hsh[:green] * new_hsh[:blue]
  end

  all_rounds << new_hsh
end

puts all_rounds.map { |hsh| hsh[:power] }.sum
