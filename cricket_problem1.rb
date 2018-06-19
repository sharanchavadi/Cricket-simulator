# I have written a custom method to generate weighted random number as below, but it seems to be an overkill.
# Beacuse, it creates a map every time when we need to generate a random number.

=begin
def random_score_generator(probability)
    score = []
    probability.map do |key, value|
      value.times { score << key }
    end
    return score.sample
end
=end

#Better option would be using a gem called 'weighted_randomizer' as below
require 'weighted_randomizer'

#Method to pluralise a word
def pluralise(number, word)
    return (number > 1)? "#{number} #{word}s" : "#{number} #{word}"
end

#Method to indicate '*' for the player who is not out
def not_out(player, on_field_players, score)
    not_out_player = on_field_players.values.select{|on_field_player| on_field_player == player}
    if not_out_player.empty? 
       "#{score}"
    else 
       "#{score}*"
    end
end

#Method to print the status of on going game
def print_status(runs_to_win, scored_runs, current_over)
    required_runs = runs_to_win - scored_runs
    puts "\n#{pluralise((4 - current_over), "over")} left. #{pluralise(required_runs, "run")} to win\n\n"
end


probabilities = {
    "Kirat Boli" => {"0"=>5, "1"=>30, "2"=>25, "3"=>10, "4"=>15, "5"=>1, "6"=>9, "-1"=>5},
    "NS Nodhi" => {"0"=>10, "1"=>40, "2"=>20, "3"=>5, "4"=>10, "5"=>1, "6"=>4, "-1"=>10},
    "R Rumrah" => {"0"=>20, "1"=>30, "2"=>15, "3"=>5, "4"=>5, "5"=>1, "6"=>4, "-1"=>20},
    "Shashi Henra" => {"0"=>30, "1"=>25, "2"=>5, "3"=>0, "4"=>5, "5"=>1, "6"=>4, "-1"=>30}
}

players = Hash[*probabilities.keys.collect { |player| [player, { runs: 0, balls: 0 }] }.flatten]

available_balls = 24
runs_to_win = 40
scored_runs = 0
required_runs = 0
wickets = 3
overs = 4
balls = 6
game_won = false

available_players = players.keys.reverse
on_field_players = { 0 => available_players.pop, 1 => available_players.pop }
current_player_index = 0

overs.times do |current_over|
      balls.times do |ball|
            if wickets > 0
                  if scored_runs < runs_to_win
                        print_status(runs_to_win, scored_runs, current_over) if ball == 0

                        #Generating a weighted random number
                        randomizer = WeightedRandomizer.new(probabilities[on_field_players[current_player_index]])
                        score_number = randomizer.sample.to_i

                        players[on_field_players[current_player_index]][:balls] += 1
                        if score_number != -1
                             players[on_field_players[current_player_index]][:runs] += score_number
                             scored_runs += score_number
                             puts "#{current_over}.#{ball + 1} #{on_field_players[current_player_index]} scores #{pluralise(score_number, "run")}"
                             current_player_index = ((current_player_index + 1) % 2) if [1, 3, 5].include?(score_number) #(0+1)%2 will give 1, (1+1)%2 will give 0.
                        else
                             puts "#{current_over}.#{ball + 1} #{on_field_players[current_player_index]} is out"
                             wickets -= 1
                             on_field_players[current_player_index] = available_players.pop
                        end
                  else
                      game_won = true
                      break
                  end
                  available_balls -= 1
            else
                break
            end
      end
      current_player_index = ((current_player_index + 1) % 2) #(0+1)%2 will give 1
end


if game_won
    puts "\n\nLengaburu won by #{pluralise(wickets, "wicket")} and #{pluralise(available_balls, "ball")} remaining\n\n"
else
    puts "\n\nLengaburu lost by #{pluralise(wickets, "wicket")} and #{pluralise(available_balls, "ball")} remaining\n\n"
end


players.each do |player, score|
    puts "#{player} - #{not_out(player, on_field_players, score[:runs])} (#{pluralise(score[:balls], "ball")})"
end

