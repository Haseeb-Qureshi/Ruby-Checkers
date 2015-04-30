require_relative 'board'
require_relative 'player'
require 'colorize'
require 'io/console'

class Game
  attr_reader :board, :cursor, :captured

  def initialize
    @board = Board.new(self)
    @cursor = [0, 0]
    @players = [Player.new(self, @board, :b), Player.new(self, @board, :r)]
    @avail_moves = [] # implement this later
    @captured = []
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
    puts rendered_board
  end

  def reset_render
    sleep (1)
    render
  end

  def move_cursor(movement)
    x, y = @cursor
    dx, dy = movement
    @cursor = [x + dx, y + dy]
    render
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
      bg = (i + j).even? ? :black : :white
      bg = :green if @avail_moves.include?([i, j])
      bg = :yellow if [i, j] == cursor
      str << " #{piece} ".colorize(background: bg)
    end
    str
  end

end
