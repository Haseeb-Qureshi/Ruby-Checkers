require_relative 'piece'
class Board
  attr_reader :rows

  def initialize(game)
    @rows = Array.new(8) { Array.new(8) { Empty_Space.new } }
    @game = game
    seed_board
  end

  def [](x, y)
    @rows[x][y]
  end

  def []=(x, y, val)
    @rows[x][y] = val
  end

  def move(from, to)
    piece = self[*from]

    self[*from] = nil
    self[*to] = piece
    piece.pos = to
  end

  def seed_board
    3.times { |row| create_row_of_pieces(row, :b) }
    3.times { |row| create_row_of_pieces(row + 5, :r) }
  end

  def create_row_of_pieces(row, color)
    config = row.odd? ? :odd? : :even?
    places = (0..7).select(&config).map{ |y| [row, y] }
    make_men(places, color)
  end

  def make_men(places, color)
    places.each { |x, y| self[x, y] = Piece.new(color, [x, y]) }
  end
end
