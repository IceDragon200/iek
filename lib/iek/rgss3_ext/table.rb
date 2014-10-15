class Table
  def to_a
    result = []
    if zsize > 1
      zsize.times do |z|
        ysize.times do |y|
          xsize.times do |x|
            result << self[x, y, z]
          end
        end
      end
    elsif ysize > 1
      ysize.times do |y|
        xsize.times do |x|
          result << self[x, y]
        end
      end
    else
      xsize.times do |x|
        result << self[x]
      end
    end
    result
  end
end
