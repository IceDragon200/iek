$simport.r("iek/time_system/core_ext/integer", "1.0.0", "Integer extensions for time increments")

class Integer
  def seconds
    self
  end

  def minutes
    seconds * 60
  end

  def hours
    minutes * 60
  end

  def days
    hours * 24
  end

  def months
    days * 30
  end

  def years
    days * 365
  end
end
