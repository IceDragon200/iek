$simport.r('iek/rgss3_ext/sprite', '1.0.0', 'Extends Sprite Class')

class Sprite
  def to_rect
    Rect.new(x, y, width, height)
  end

  ##
  # width=(Integer new_width)
  def width=(new_width)
    self.src_rect.width = new_width
  end unless method_defined?(:width=)

  ##
  # height=(Integer new_height)
  def height=(new_height)
    self.src_rect.height = new_height
  end unless method_defined?(:height=)

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

  ##
  # @return [Void]
  def dispose_bitmap
    bitmap.dispose
  end

  ##
  # @return [Void]
  def dispose_bitmap_safe
    dispose_bitmap if bitmap && !bitmap.disposed?
  end

  ##
  # @return [Void]
  def dispose_all
    dispose_bitmap_safe
    dispose
  end
end
