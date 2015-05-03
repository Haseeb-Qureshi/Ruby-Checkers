class Computer < Player
  def hard_mode
    advanced_ai
  end

  def make_move
    sleep(0.3 + 0.1 * rand(2))
    my_moves = @board.valid_moves(@color)
    make_best_move!(my_moves)
  end

  def move_further(from)
    sleep(0.2)
    my_moves = @board.valid_moves(@color).select { |move| move.from == from }
    make_best_move!(my_moves)
  end

  def make_best_move!(my_moves)
    if my_moves.none? { |move| move.captured.any? }
      @board.move(my_moves.sample)
    else
      @board.move(my_moves.max_by { |move| move.captured.size } )
    end
  end

  def advanced_ai
    # just kidding.
  end
end
