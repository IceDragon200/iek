#
# Kilim-BattleCore/lib/core-ext/tone.rb
#   by IceDragon
#   dc 08/06/2013
#   dm 08/06/2013
# vr 1.0.0
class Tone
  ##
  # to_a
  def to_a
    [red, green, blue, gray]
  end unless method_defined?(:to_a)

  ##
  # lerp!(Tone tone, Float rate)
  def lerp!(tone, rate)
    s, t, r = self.to_a, tone.to_a, [0,0,0,0] # // Self, Target, Result

    for i in 0...s.size
      r[i] = (s[i] - ((s[i] - t[i]) * rate)).clamp(s[i].min(t[i]), s[i].max(t[i]))
    end

    self.red   = r[0]
    self.green = r[1]
    self.blue  = r[2]
    self.gray  = r[3]

    return self
  end

  ##
  # lerp(Tone tone, Float rate)
  def lerp(tone, rate)
    dup.lerp!(tone, rate)
  end
end
