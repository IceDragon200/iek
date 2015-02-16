$simport.r('iex3/data_cache', '1.0.0', 'Data Caching for RMVX')

module DataCache
  def self.data_extname
    '.rvdata'
  end

  def self.init
    @cache = {}
  end

  def self.clear
    @cache.clear
  end

  def self.load(filename)
    @cache[filename] ||= begin
      map = load_data(filename)
      yield map if block_given?
      map
    end
  end

  def self.load_map(filename)
    load(filename) do |map|
      if map.data.zsize != 4
        STDERR.puts "[DataCache] Repairing broken map data (filename: #{filename})"
        map.data.resize(map.data.xsize, map.data.ysize, 4)
      end
    end
  end

  def self.load_map_by_id(map_id)
    load_map(sprintf('Data/Map%03d%s', map_id, data_extname))
  end

  init
end
