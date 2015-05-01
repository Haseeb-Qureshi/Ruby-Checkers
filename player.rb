class Player
  attr_reader :color
  KEYMAP = {
    "w" => [-1, 0],
    "a" => [0, -1],
    "s" => [1, 0],
    "d" => [0, 1],
    "\r" => [0, 0]
  }

  FUNCTIONS = {
    'q' => :quit,
    'v' => :save
  }

  def initialize(game, board, color)
    @game, @board, @color = game, board, color
  end

  def make_move
    from = get_selection
    raise SelectionError if !@board.my_color?(from, @color)
    select_movement(from)

  rescue SelectionError
    puts "You can't select that."
    rerender_game
    retry
  rescue InvalidMoveError
    puts "You can't move there."
    rerender_game
    retry
  end

  def select_movement(from)
    @game.select!
    to = get_to_input
    @game.deselect!

    my_move = @board.build_move(from, to, @color)
    if my_move.nil?
      raise @game.moving_more_than_once? ? MustJumpError : InvalidMoveError
    end
    piece = @board.move(my_move)
  end

  def move_further(from)
    select_movement(from)
  rescue MustJumpError
    puts "You have to make another jump."
    @game.reset_render
    retry
  end

  def to_s
    @color == :b ? "Blue" : "Red"
  end

  private

  def get_selection
    prompt = "Navigate using W-A-S-D, and select with Enter.\n"\
             "Press Q to quit, and V to save."
    navigate!(prompt)
    @game.cursor
  end

  def get_to_input
    prompt = "Where do you want to move?"
    navigate!(prompt)
    @game.cursor
  end

  def navigate!(prompt)
    made_selection = false
    until made_selection
      puts prompt

      selection = false
      until selection
        input = $stdin.getch.downcase
        do_function!(input) if FUNCTIONS[input]
        selection = true if valid_input?(input)
      end

      @game.move_cursor_by!(KEYMAP[input])
      made_selection = true if KEYMAP[input] == [0, 0]
    end
    nil
  end

  def valid_input?(input)
    return false unless KEYMAP[input]
    return false if overflow?(KEYMAP[input])
    true
  end

  def do_function!(input)
    case FUNCTIONS[input]
    when :quit then exit
    when :save then @game.save_game
    end
  end

  def overflow?(movement)
    x, y = @game.cursor
    dx, dy = movement
    !Board.on?([x + dx, y + dy])
  end

  def rerender_game
    @game.reset_render
    @game.deselect!
  end
end

class InvalidMoveError < StandardError
end

class SelectionError < StandardError
end

class MustJumpError < StandardError
end
