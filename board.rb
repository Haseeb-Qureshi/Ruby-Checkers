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
    full_move = piece.moves.find { |move| move == my_move }
    full_move.captured.each do |capture_piece|
      kill(capture_piece.pos)
    end

    self[*from] = EmptySpace.new
    self[*to] = piece
    piece.pos = to
    piece.make_king if piece.pos.first) % 7 == 0
    if full_move.captured.any? && piece.my_attacks.any?
      @game.moving_again = piece
      @game.current_player.move_further(to)
      @game.moving_again = nil
    end
  end

  def pieces(color)
    @rows.flatten.select { |piece| piece.color == color }
  end

  def valid_moves(color)
    pieces(color).inject([]) { |valid_moves, piece| valid_moves += piece.moves }
  end

  private

  def kill(coords)
    @game.captured << self[*coords]
    self[*coords] = EmptySpace.new
  end

  def seed_board
    3.times { |row| create_row_of_pieces(row, :b) }
    3.times { |row| create_row_of_pieces(row + 5, :r) }
  end

  def create_row_of_pieces(row, color)
    config = row.odd? ? :odd? : :even?
    places = (0..7).select(&config).map{ |col| [row, col] }
    generate_men(places, color)
  end

  def generate_men(places, color)
    places.each { |x, y| self[x, y] = Piece.new(color, [x, y], self) }
  end
end
