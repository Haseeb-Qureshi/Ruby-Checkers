require_relative 'move'
require_relative 'empty_space'

class Piece
  attr_reader :color
  attr_accessor :pos, :king

  REG_MOVES = [[1, 1], [1, -1]]
  KING_MOVES = [1, 1, -1, -1].permutation(2).to_a.uniq

  def initialize(color, pos, board)
    @color, @pos, @board = color, pos, board
    @orientation = color == :b ? 1 : -1
    @king = false
  end

  def full?
    true
  end

  def empty?
    false
  end

  def moves
    @king ? (king_jumps + king_attacks) : (regular_jumps + regular_attacks)
  end

  def my_attacks
    @king ? king_attacks : regular_attacks
  end

  def king_me!
    @king = true
  end

  def to_s
    if @king
      @color == :r ? "♚".colorize(color: :red) : "♚".colorize(color: :blue)
    else
      @color == :r ? "○".colorize(color: :red) : "●".colorize(color: :blue)
    end
  end

  def inspect
    to_s
  end

  def regular_jumps
    single_moves(REG_MOVES)
  end

  def regular_attacks
    attacks(REG_MOVES)
  end

  def king_jumps
    single_moves(KING_MOVES)
  end

  def king_attacks
    attacks(KING_MOVES)
  end

  private

  def attacks(diff_map)
    x, y = @pos
    all_attacks = []

    single_diffs = diff_map.map { |move| move.map { |dist| dist * @orientation } }
    single_diffs.each do |dx, dy|
      one_x = x + dx
      one_y = y + dy
      two_x = one_x + dx
      two_y = one_y + dy
      if valid_regular_attack?([one_x, one_y], [two_x, two_y])
          all_attacks << Move.new(@pos.dup, [two_x, two_y], self, [@board[one_x, one_y]])
      end
    end
    all_attacks
  end

  def single_moves(diff_map)
    our_diffs = diff_map.map { |move| move.map { |dist| dist * @orientation } }
    possible_moves = our_diffs.map do |diff|
      dx, dy = diff
      x, y = @pos
      Move.new([x, y], [x + dx, y + dy], self)
    end.reject do |move|
      !Board.on?(move.to) || @board[*move.to].full?
    end
  end

  def valid_regular_attack?(jumped, landing)
    Board.on?(jumped) &&
      Board.on?(landing) &&
      @board[*jumped].full? &&
      @board[*jumped].color != @color &&
      @board[*landing].empty?
  end
end
