class Move
  attr_reader :from, :to, :piece, :captured

  def initialize(from, to, piece = nil, captured = [])
    @from, @to, @piece, @captured = from, to, piece, captured
  end

  def inspect
    "#{@piece}: from #{@from} to #{@to}"
  end

  def -(other_pos)
    x1, y1 = @to
    x2, y2 = other_pos
    [x1 - x2, y1 - y2]
  end

  def ==(other_move)
    from == other_move.from && to == other_move.to
  end
end
