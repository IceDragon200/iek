class Plane
  ##
  # @return [Void]
  def dispose_bitmap
    self.bitmap.dispose
  end

  ##
  # @return [Void]
  def dispose_bitmap_safe
    dispose_bitmap if self.bitmap && !self.bitmap.disposed?
  end

  ##
  # @return [Void]
  def dispose_all
    dispose_bitmap_safe
    dispose
  end
end
