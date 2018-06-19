require 'weighted_randomizer'

#Method to pluralise a word
def pluralise(number, word)
    return (number > 1)? "#{number} #{word}s" : "#{number} #{word}"
end

#Method to indicate '*' for the player who is not out
def not_out(score, out)
    return (out == true)? "#{score}" : "#{score}*"
end

#Simulating tie breaker
def tie_breaker(team, probability, target_score)

    current_score = 0
    balls = 6
    remaining_balls = 6
    available_players = team.keys.reverse
    on_field_players = { 0 => available_players.pop, 1 => available_players.pop }
    current_player_index = 0

    balls.times do |ball|
          remaining_balls -= 1
          randomizer = WeightedRandomizer.new(probability[on_field_players[current_player_index]])
          score_number = randomizer.sample.to_i
          team[on_field_players[current_player_index]][:balls] += 1
          
          if score_number == -1
              team[on_field_players[current_player_index]][:out] = true
              puts "0.#{ball + 1} #{on_field_players[current_player_index]} gets out!"
              return [current_score, remaining_balls]
          end

          team[on_field_players[current_player_index]][:runs] += score_number
          current_score += score_number
          puts "0.#{ball + 1} #{on_field_players[current_player_index]} scores #{pluralise(score_number, "run")}"
          return [current_score, remaining_balls] if !target_score.nil? && current_score > target_score
          current_player_index = ((current_player_index + 1) % 2) if [1, 3, 5].include?(score_number)
    end
    return [current_score, remaining_balls]
end


probabilities = {
    "Lengaburu" => {
    "Kirat Boli" => {"0"=>5, "1"=>10, "2"=>25, "3"=>10, "4"=>25, "5"=>1, "6"=>14, "-1"=>10},
    "NS Nodhi" => {"0"=>5, "1"=>15, "2"=>15, "3"=>10, "4"=>20, "5"=>1, "6"=>19, "-1"=>15}
    },

    "Enchai" => {
    "DB Vellyers" => {"0"=>5, "1"=>10, "2"=>25, "3"=>10, "4"=>25, "5"=>1, "6"=>14, "-1"=>10},
    "H Mamla" => {"0"=>10, "1"=>15, "2"=>15, "3"=>10, "4"=>20, "5"=>1, "6"=>19, "-1"=>10}
    }
}

teams = {
    "Lengaburu"=> {"Kirat Boli"=> {:runs=>0, :balls=>0, :out => false}, "NS Nodhi"=> {:runs=>0, :balls=>0, :out => false}},
    "Enchai"=> {"DB Vellyers"=> {:runs=>0, :balls=>0, :out => false}, "H Mamla"=> {:runs=>0, :balls=>0, :out => false}},
}


puts "\nLengaburu innings:"
lengaburu_result = tie_breaker(teams["Lengaburu"], probabilities["Lengaburu"], nil)

puts "\nEnchai innings:"
enchai_result = tie_breaker(teams["Enchai"], probabilities["Enchai"], lengaburu_result[0])


if lengaburu_result.first > enchai_result.first
     puts "Lengaburu wins!"
     puts "\nLengaburu won with #{lengaburu_result.last} balls remaining"
elsif lengaburu_result.first < enchai_result.first
     puts "Enchai wins!"
     puts "\nEnchai won with #{enchai_result.last} balls remaining"
else
     puts "It's a draw"
end
 

teams.each do |team, players|
     puts "\n#{team}"
     players.each do |player, score|
          puts "#{player} - #{not_out(score[:runs], score[:out])} (#{pluralise(score[:balls], "ball")})"
     end
end
