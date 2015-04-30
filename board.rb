require_relative 'piece'

class Board
  attr_reader :rows

  def self.on?(coords)
    coords.all? { |n| n.between?(0, 7) }
  end

  def initialize(game)
    @rows = Array.new(8) { Array.new(8) { EmptySpace.new } }
    @game = game
    seed_board
  end

  def [](x, y)
    @rows[x][y]
  end

  def []=(x, y, val)
    @rows[x][y] = val
  end

  def move(my_move)
    from, to = my_move.from, my_move.to

    piece = self[*from]
    my_move.captured.each { |capture_piece| @game.captured << capture_piece }

    self[*from] = EmptySpace.new
    self[*to] = piece
    piece.pos = to
  end

  def pieces(color)
    @rows.flatten.select { |piece| piece.color == color }
  end

  def kill(coords)
    @game.captured << self[*coords]
    self[*coords] = EmptySpace.new
  end

  def valid_moves(color)
    pieces(color).inject([]) { |valid_moves, piece| valid_moves += piece.moves }
  end

  private

  def seed_board
    3.times { |row| create_row_of_pieces(row, :b) }
    3.times { |row| create_row_of_pieces(row + 5, :r) }
  end

  def create_row_of_pieces(row, color)
    config = row.odd? ? :odd? : :even?
    places = (0..7).select(&config).map{ |y| [row, y] }
    generate_men(places, color)
  end

  def generate_men(places, color)
    places.each { |x, y| self[x, y] = Piece.new(color, [x, y], self) }
  end
end
