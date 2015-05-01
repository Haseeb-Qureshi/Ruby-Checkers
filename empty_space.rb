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
