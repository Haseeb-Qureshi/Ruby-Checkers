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
    reassign_squares!(my_move)
    unload_captures!(my_move)
    king_check(my_move.piece)

    check_for_multiple_jumps(my_move)
  end

  def pieces(color)
    @rows.flatten.select { |piece| piece.color == color }
  end

  def valid_moves(color)
    pieces(color).inject([]) { |valid_moves, piece| valid_moves += piece.moves }
  end

  def build_move(from, to, color)
    move_shell = Move.new(from, to)
    valid_moves(color).find { |valid_move| valid_move == move_shell }
  end

  def my_color?(coords, color)
    self[*coords].color == color
  end

  private

  def reassign_squares!(my_move)
    from, to = my_move.from, my_move.to
    piece = my_move.piece

    self[*from] = EmptySpace.new
    self[*to] = piece

    piece.pos = to
  end

  def unload_captures!(my_move)
    my_move.captured.each { |capture_piece| kill!(capture_piece.pos) }
  end

  def kill!(coords)
    @game.captured << self[*coords]
    self[*coords] = EmptySpace.new
  end

  def king_check(piece)
    piece.king_me! if [0, 7].include?(piece.pos.first)
  end

  def check_for_multiple_jumps(my_move)
    piece = my_move.piece
    if my_move.captured.any? && piece.my_attacks.any?
      @game.multiple_moves!(piece)
      @game.let_player_move_further(my_move.to)
      @game.multiple_moves_concluded
    end
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
