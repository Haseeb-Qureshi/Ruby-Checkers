require_relative 'board'
require_relative 'player'
require 'colorize'
require 'io/console'

class Game
  attr_reader :board, :cursor, :captured

  def initialize
    @board = Board.new(self)
    @cursor = [0, 0]
    @select = false
    @players = [Player.new(self, @board, :b), Player.new(self, @board, :r)]
    @avail_moves = [] # implement this later
    @captured = []
    @debug = []
  end

  def play
    welcome
    render
    until game_over?
      @players.first.make_move
      @players.rotate!
      render
    end
    game_over_message
  end

  def render
    system "clear"
    rendered_board = []
    @board.rows.each_with_index do |row, i|
      rendered_board << render_row(row, i)
    end
    puts rendered_board + @debug
  end

  def reset_render
    sleep (1)
    render
  end

  def move_cursor!(movement)
    x, y = @cursor
    dx, dy = movement
    @cursor = [x + dx, y + dy]
    @avail_moves = @board[*@cursor].moves.map(&:to) unless @select
    init_debug                            #remove later
    render
  end

  def select!
    @select = true
  end

  def deselect!
    @select = false
    move_cursor!([0, 0])
  end

  private

  def welcome
    puts "Welcome to Checkers! Red goes first."
  end

  def game_over?
    false
  end

  def game_over_message
    puts "Game over. #{@players.last} wins."
  end

  def render_row(row, i)
    str = ""
    row.each_with_index do |piece, j|
      background = (i + j).even? ? :black : :white
      background = :green if @avail_moves.include?([i, j])
      background = :yellow if [i, j] == cursor

      str << " #{piece} ".colorize(background: background)
    end
    add_decoration(str, i)
  end

  def add_decoration(str, i)
    decoration = case i
    when 0 then @captured.select { |piece| piece.color == :r }
    when 4 then
      red_str = "Red's turn.".colorize(color: :red)
      blue_str = "Blue's turn.".colorize(color: :blue)
      @players.first.color == :r ? [red_str] : [blue_str]
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
    debug_str << "Valid_moves: #{@board.valid_moves(@players.first.color)}"
    debug_str << ""
    debug_str << ""
    @debug << debug_str
  end
end

if __FILE__ == $0
  Game.new.play
end
