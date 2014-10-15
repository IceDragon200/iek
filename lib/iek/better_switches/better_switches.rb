$simport.r('better_switches', '1.0.0', 'Improves the functionality of default Game_Switches')

class Game_Switches
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
    # switch set callback
    $game_map.need_refresh = true # default action
  end

  ##
  # [](Integer id)
  def [](id)
    @data[id]
  end

  ##
  # []=(Integer id, Boolean n)
  def []=(id, n)
    @data[id] = !!n
    on_change(id)
  end

  ##
  # is switch (id) currently on?
  # @param [Integer] id
  # @return [Boolean]
  def on?(id)
    self[id] == true
  end

  ##
  # is switch (id) currently off?
  # @param [Integer] id
  # @return [Boolean]
  def off?(id)
    self[id] == false
  end

  ##
  # toggle(Integer id)
  #   toggle the switch state
  def toggle(id)
    self[id] = !self[id]
  end

  ##
  # Retrieves the name of the switch at (id)
  # @param [Integer] id
  # @return [String]
  def name(id)
    $data_system.switches[id]
  end

  private :on_change
end
