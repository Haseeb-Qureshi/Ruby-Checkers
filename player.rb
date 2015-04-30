class Player
  KEYMAP = {
    'w' => [-1, 0],
    'a' => [0, -1],
    's' => [1, 0],
    'd' => [0, 1],
    '\r' => [0, 0]
  }

  def initialize(game, board, color)
    @game, @board, @color = game, board, color
  end

  def make_move
    from = get_from_input

    # make check for whether it's valid to select that piece

    to = get_to_input

    @board.move(from, to)
  end

  private

  def get_from_input
    @game.cursor.zip(get_input).map { |pair| pair.reduce(:+) }
  end

  def get_to_input
    @game.cursor.zip(get_input).map { |pair| pair.reduce(:+) }
  end

  def get_input
    enter = false
    until enter
      puts "Navigate using W-A-S-D, and select with Enter."

      selection = false
      until selection
        input = $stdin.getch.downcase
        selection = true if valid_input?(input)
        sleep(0.5)
      end

      KEYMAP[input] == [0, 0] ? enter = true : @game.move_cursor(KEYMAP[input])
    end
    KEYMAP[input]
  end

  def valid_input?(input)
    return false unless KEYMAP[input]
    return false if overflow?(KEYMAP[input])
    true
  end

  def overflow?(movement)
    x, y = @game.cursor
    dx, dy = movement
    [x + dx, y + dy].all? { |dist| dist.between?(0, 7) }
  end
end


#Add error handling later
