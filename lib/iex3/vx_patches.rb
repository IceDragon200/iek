class Window_Item < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @data = []
    @column_max = 2
    @index = 0
    refresh
  end
end

class Scene_Skill
  alias :terminate_wo_viewport :terminate
  def terminate
    terminate_wo_viewport
    @viewport.dispose
  end
end
