class Rect
  ###
  # @return [Array<Integer>]
  ###
  def to_a
    return x, y, width, height
  end unless method_defined? :to_a

  ###
  # Returns the "right" coordinate of the Rect
  # @return [Integer]
  ###
  def x2
    x + width
  end

  def x2=(x2)
    self.x = x2 - width
  end

  ###
  # Returns the "bottom" coordinate of the Rect
  # @return [Integer]
  ###
  def y2
    y + height
  end

  def y2=(y2)
    self.y = y2 - height
  end

  def empty?
    return width == 0 || height == 0
  end

  ##
  # @param [Integer] dir | based on the NUMPAD directions
  # @param [Integer] n   | step count
  # @return [self]
  def step!(dir, n=1)
    case dir
    when 1 then step!(2, n).step!(4, n) # down-left
    when 3 then step!(2, n).step!(6, n) # down-right
    when 7 then step!(8, n).step!(4, n) # up-left
    when 9 then step!(8, n).step!(6, n) # up-right
    when 2 then self.y += self.height * n # down
    when 4 then self.x -= self.width  * n # left
    when 6 then self.x += self.width  * n # right
    when 8 then self.y -= self.height * n # up
    end
    self
  end

  ##
  # @param [Integer] dir | based on the NUMPAD directions
  # @param [Integer] n   | step count
  # @return [Rect]
  def step(dir, n=1)
    dup.step!(dir, n)
  end
end
