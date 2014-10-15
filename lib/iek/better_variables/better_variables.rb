$simport.r('better_switches', '1.0.0', 'Improves the functionality of default Game_Variables')

class Game_Variables
  include Enumerable

  SIZE = 1024

  ##
  # initialize
  def initialize
    @data = Array.new(SIZE, false)
  end

  ##
  #
  def each
    return to_enum(__method__) unless block_given?
    @data.each_with_index { |x, i| yield i, x }
  end

  ##
  # on_change
  def on_change(id)
    # variable set callback
    $game_map.need_refresh = true # default action
  end

  ##
  # [](Integer id)
  def [](id)
    @data[id]
  end

  ##
  # []=(Integer id, Integer n)
  def []=(id, n)
    @data[id] = n.to_i
    on_change(id)
  end

  ##
  # on?(Integer id)
  #   is the switch currently on?
  def zero?(id)
    self[id] == 0
  end

  ##
  # Retrieves the name of the variable at (id)
  # @param [Integer] id
  # @return [String]
  def name(id)
    $data_system.variables[id]
  end

  private :on_change
end
