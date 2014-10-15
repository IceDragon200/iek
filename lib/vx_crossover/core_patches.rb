class Tilemap
  attr_accessor :passages

  alias :set_map_data :map_data=
  def map_data=(map_data)
    if map_data && map_data.zsize != 4
      raise ArgumentError, "wrong map_data#zsize #{map_data.zsize} (expected 4)"
    end
    set_map_data(map_data)
  end
end
