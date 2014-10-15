class Numeric
  ###
  # Converts seconds to frames
  # @return [Integer]
  ###
  def to_frames
    Integer self * Graphics.frame_rate
  end
end
