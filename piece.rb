require 'singleton'
class Piece
  attr_reader :col
  attr_accessor :pos, :king

  REG_MOVES = [[1, 1], [1, -1]]
  KING_MOVES = [1, 1, -1, -1].permutation(2).to_a.uniq

  def initialize(col = nil, pos = nil)
    @col = col
    @pos = pos
    @dir = col == :b ? 1 : -1
    @king = false
  end

  def move
    @king ? king_moves : regular_moves
  end

  def king_moves
  end

  def regular_moves

    #based on @dir, map dir to the array
  end

  def to_s
    if @king
      @col == :r ? "◎".colorize(color: :red) : "◉".colorize(color: :blue)
    else
      @col == :r ? "○".colorize(color: :red) : "●".colorize(color: :blue)
    end
  end

end

class Empty_Space

  def to_s
    " "
  end

  def nil?
    true
  end

  def method_missing(*args)
    self
  end
end
