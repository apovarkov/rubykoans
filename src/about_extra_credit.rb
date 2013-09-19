# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.

class DiceSet
  attr_reader :values

  def roll(dice)
    @values = []
    r = Random.new
    dice.times do
      @values << r.rand(1..6)
    end
  end

end

class Game
  MAX_ROLL = 5
  TARGET_SCORE = 3000
  GET_IN_SCORE = 300

  def initialize
    @players = []
    @turn = 0
    @last_roll = Hash.new
    @last_turn = false
  end

  def start(players_num)
    while players_num < 2
      puts "More than 1 player should play a game:\n"
      puts "Enter number of players"
      players_num = gets
    end
    players_num.times do |num|
      puts "Who is player #{num + 1}:"
      @players << Player.new(gets)
    end
    while !@last_turn
      puts "TURN: #{@turn+=1}"
      turn(@players)
      puts "***************************************************************"
    end
    end_turn_players = @players.sort_by {|player| player.total_score}
    end_turn_players.pop
    puts "LAST TURN"
    turn(end_turn_players)
    puts "***************************************************************"
    end_game
  end

  private
  def end_game
    @players.sort_by! {|player| player.total_score}
    puts "#{@players.last.name} WINS with SCORE: #{@players.last.total_score}!!!!!"
  end

  private
  def turn(players)
    players.each do |player|
      start_player_turn(player)
      if check_end_game(player)
        @last_turn = true
        break
      end
    end
  end

  private
  def start_player_turn(player)
    player.dice = MAX_ROLL
    roll(player)
    player_turn(player)
  end

  private
  def player_turn(player)
    puts "Do you want to continue?"
    while gets.strip == "y"
      roll(player)
      if check_end_turn(player)
        break
      end
      puts "Do you want to continue?"
    end
    end_player_turn(player)
  end

  private
  def end_player_turn(player)
    unless player.total_score == 0 && player.turn_score < GET_IN_SCORE
      player.total_score += player.turn_score
    end
    player.turn_score = 0
    puts player
    puts "==============================================================="
  end

  private
  def roll(player)
    roll = player.roll
    puts "#{player.name} roll: #{roll}"
    score(roll)
    player.turn_score += @last_roll[:score]
    player.dice -= (@last_roll[:scoring] == MAX_ROLL ? 0 : @last_roll[:scoring])
    puts player
  end

  private
  def score(dice)
    score = 0
    scoring = 0
    1.upto(6).each do |num|
      amount = dice.count(num)
      if amount >= 3
        scoring += 3
        score += num == 1 ? 1000 : num * 100
        amount -= 3
      end
      if num == 1
        scoring += amount
        score += 100 * amount
      end
      if num == 5
        scoring += amount
        score += 50 * amount
      end
    end
    @last_roll[:scoring] = scoring
    @last_roll[:score] = score
  end

  private
  def roll_failed
    @last_roll[:scoring] == 0
  end

  private
  def check_end_turn(player)
    if roll_failed
      player.turn_score = 0
      true
    elsif player.dice == 0
      true
    else
      false
    end
  end

  private
  def check_end_game(player)
    player.total_score >= TARGET_SCORE
  end
end

class Player
  attr_accessor :name, :turn_score, :total_score, :dice

  def initialize(name)
    @name = name
    @turn_score = 0
    @total_score = 0
    @dice = 0
    @dice_set = DiceSet.new
  end

  def roll
    @dice_set.roll(@dice)
    @dice_set.values
  end

  def to_s
    %{#{@name}\t\tdice left: #{@dice}
      \tcurrent turn score: #{@turn_score}
      \ttotal score: #{@total_score}}
  end

end


