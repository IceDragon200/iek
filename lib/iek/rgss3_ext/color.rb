#
#
#
class Color
  ##
  # to_a
  def to_a
    return red, green, blue, alpha
  end unless method_defined?(:to_a)

  ##
  # lerp!(Color color, Float rate)
  def lerp!(color, rate)
    s, t, r = self.to_a, color.to_a, self.to_a # // Self, Target, Result

    for i in 0...s.size
      r[i] = (s[i] - ((s[i] - t[i]) * rate)).clamp(s[i].min(t[i]), s[i].max(t[i]))
    end

    self.red   = r[0]
    self.green = r[1]
    self.blue  = r[2]
    self.alpha = r[3]

    return self
  end

  ##
  # lerp(Color color, Float rate)
  def lerp(color, rate)
    dup.lerp!(color, rate)
  end

  ##
  # @return [Color]
  def self.random
    new(rand(0x100), rand(0x100), rand(0x100), 0xFF)
  end
end
