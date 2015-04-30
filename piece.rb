require_relative 'move'

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
    all_moves = @king ? king_moves + king_attacks : regular_moves #+ regular_attacks
  end

  def to_s
    if @king
      @color == :r ? "◎".colorize(color: :red) : "◉".colorize(color: :blue)
    else
      @color == :r ? "○".colorize(color: :red) : "●".colorize(color: :blue)
    end
  end

  def inspect
    to_s
  end

  private

  def regular_moves
    single_moves(@pos, REG_MOVES).reject do |move|
      !Board.on?(move.to) || @board[*move.to].full?
    end
  end

  def regular_attacks
    x, y = @pos
    attacks = []

    single_diffs = REG_MOVES.map { |move| move.map { |dist| dist * @orientation } }
    single_diffs.each do |dx, dy|
      one_x = x + dx
      one_y = y + dy
      two_x = one_x + dx
      two_y = one_y + dy
      if !@board[one_x, one_y].nil? && @board[one_x, one_y].color != @color
        if Board.on?([two_x, two_y]) && @board[two_x, two_y].empty?
          attacks << Move.new(@pos.dup, [two_x, two_y], self, @board[[one_x, one_y]])
        end
      end
    end
  end

  def single_moves(pos, diff_map)
    our_diffs = diff_map.map { |move| move.map { |dist| dist * @orientation } }
    possible_moves = our_diffs.map do |diff|
      dx, dy = diff
      x, y = pos
      Move.new([x, y], [x + dx, y + dy], self)
    end
  end

  def king_moves
  end

  def king_attacks
  end
end

class EmptySpace
  def to_s
    " "
  end

  def nil?
    true
  end

  def empty?
    true
  end

  def full?
    false
  end

  def moves
    []
  end

  def to_ary
    []
  end

  def method_missing(*args)
    self
  end
end
