class Computer < Player
  def make_move
    sleep(0.3 + 0.1 * rand(2))
    my_moves = @board.valid_moves(@color)
    best_move(my_moves)
  end

  def move_further(from)
    sleep(0.2)
    my_moves = @board.valid_moves(@color).select { |move| move.from == from }
    best_move(my_moves)
  end

  def best_move(my_moves)
    if my_moves.none? { |move| move.captured.any? }
      @board.move(my_moves.sample)
    else
      @board.move(my_moves.max_by { |move| move.captured.size } )
    end
  end

end
