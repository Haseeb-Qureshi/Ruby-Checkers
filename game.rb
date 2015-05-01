require_relative 'board'
require_relative 'player'
require_relative 'computer'
require 'colorize'
require 'io/console'
require 'yaml'

class Game
  attr_reader :board, :cursor, :captured

  def self.load(filename)
    YAML.load_file(filename + ".yml")
  rescue
    system 'clear'
    puts "Sorry, that file couldn't be found.".bold
    exit
  end

  def initialize
    @board = Board.new(self)
    @cursor = [0, 0]
    @select = false
    @avail_moves = []
    @players = []
    @captured = []
    @debug = []
  end

  def start
    welcome
    play
  end

  def play
    render
    until game_over?
      current_player.make_move
      @players.rotate!
      render
    end
    game_over_message
  end

  def render
    system "clear"
    rendered_board = @board.rows.map.with_index { |row, i| render_row(row, i) }
    puts rendered_board + @debug
  end

  def reset_render
    sleep (1)
    render
  end

  def move_cursor_by!(movement)
    x, y = @cursor
    dx, dy = movement
    @cursor = [x + dx, y + dy]
    update_available_moves
  end

  def select!
    @select = true
    update_available_moves
  end

  def deselect!
    @select = false
    update_available_moves
  end

  def current_player
    @players.first
  end

  def save_game
    puts "What would you like to name your savegame?"\
         "Enter a filename (with no extension)."
    filename = gets.chomp + ".yml"
    File.open(filename, 'w') do |f|
      f.puts(self.to_yaml)
    end

    puts "Your game was successfully saved to #{filename}!"
    sleep(0.8)
    puts "Now resuming gameplay."
    sleep(0.8)
  end

  def multiple_moves!(piece)
    @moving_again = piece
  end

  def let_player_move_further(from)
    current_player.move_further(from)
  end

  def moving_more_than_once?
    @moving_again
  end

  def multiple_moves_concluded
    @moving_again = nil
  end

  private

  def welcome
    puts "Welcome to Checkers! Select your option."
    puts "1: Player vs Player"
    puts "2: Player vs Computer"
    puts "3: Computer vs Computer"
    puts "4: Load Game"
    process_input($stdin.getch.to_i)

  rescue InputError
    puts "Sorry, invalid input. Please try again."
    retry
  rescue LoadingError
    puts "Sorry, I couldn't load that file."
    retry
  end

  def process_input(num)
    case num
    when 1
      @players << Player.new(self, @board, :b)
      @players << Player.new(self, @board, :r)
    when 2
      @players << Computer.new(self, @board, :b)
      @players << Player.new(self, @board, :r)
    when 3
      @players << Computer.new(self, @board, :b)
      @players << Computer.new(self, @board, :r)
    when 4
      load_game
    else
      raise InputError
    end
  end

  def load_game
    puts "Please type in the savegame filename (without extension)."
    Game.load(gets.chomp).play
  end

  def game_over?
    @board.pieces(current_player.color).empty?
  end

  def game_over_message
    puts "\n\n\nGame over! #{@players.last} wins.\n\n\n"
    sleep(3)
    exit
  end

  def update_available_moves
    here = @board[*@cursor]

    unless @select || here.color == @players.last.color
      @avail_moves = here.moves.map(&:to)
    end

    @avail_moves = @moving_again.my_attacks.map(&:to) if @moving_again
    #init_debug
    render
  end

  def render_row(row, i)
    str = ""
    row.each_with_index do |piece, j|
      background = (i + j).even? ? :black : :white
      background = :green if @avail_moves.include?([i, j])
      background = :yellow if [i, j] == @cursor

      str << " #{piece} ".colorize(background: background)
    end
    add_decoration(str, i)
  end

  def add_decoration(str, rownum)
    decoration = case rownum
    when 0 then @captured.select { |piece| piece.color == :r }
    when 4 then
      red_str = "Red's turn.".colorize(color: :red)
      blue_str = "Blue's turn.".colorize(color: :blue)
      current_player.color == :r ? [red_str] : [blue_str]
    when 7 then @captured.select { |piece| piece.color == :b }
    else []
    end
    str + "   " + decoration.join(" ")
  end

  def init_debug
    @debug = []
    debug_str = ""
    piece = @board[*@cursor]
    debug_str << "Cursor: #{@cursor}\n"
    debug_str << "Piece: #{piece.class}\n"
    debug_str << "Moves: #{piece.moves}\n"
    debug_str << "Avail moves: #{@avail_moves}\n"
    debug_str << "Valid_moves: #{@board.valid_moves(@players.first.color)}\n"
    debug_str << "Moving_again? #{@moving_again.inspect}\n"
    debug_str << "Select? #{@select.inspect}\n"
    debug_str << "Attacks: #{@moving_again.my_attacks.map(&:to)}" if @moving_again
    @debug << debug_str
  end
end

class InputError < StandardError
end

class LoadingError < StandardError
end

if __FILE__ == $0
  Game.new.start
end
