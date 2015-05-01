class Move
  attr_reader :from, :to, :piece, :captured

  def initialize(from, to, piece = nil, captured = [])
    @from, @to, @piece = from, to, piece
    @captured = captured
  end

  def inspect
    "#{@piece}: from #{@from} to #{@to}"
  end

  def ==(other_move)
    from == other_move.from && to == other_move.to
  end
end
