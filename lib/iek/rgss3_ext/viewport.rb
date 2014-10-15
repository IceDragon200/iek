class Viewport
  def to_rect
    Rect.new(x, y, width, height)
  end

  ##
  # @return [Integer]
  def x
    rect.x
  end

  ##
  # @return [Integer]
  def y
    rect.y
  end

  ##
  # @return [Integer]
  def width
    rect.width
  end

  ##
  # @return [Integer]
  def height
    rect.height
  end

  ##
  # @param [Integer] n
  # @return [Void]
  def x=(n)
    rect.x = n
  end

  ##
  # @param [Integer] n
  # @return [Integer]
  def y=(n)
    rect.y = n
  end

  ##
  # @param [Integer] n
  # @return [Integer]
  def width=(n)
    rect.width = n
  end

  ##
  # @param [Integer] n
  # @return [Integer]
  def height=(n)
    rect.height = n
  end
end
