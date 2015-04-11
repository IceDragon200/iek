$simport.r 'iei/arts', '0.1.0', 'IEI Arts System'

class IEI::Art < RPG::BaseItem
  def all_tags
    super + ['art']
  end
end

module IEI
  module ArtsSystem
    module Mixin
    end

    Art = IEI::Art # // Don't tamper with this >_____>

    @arts = []     # // Don't touch this either >_____>

    Feature = RPG::BaseItem::Feature # // >_>... You know the drill

    # // And this +____+
    def self.arts
      @arts
    end

    def self.new_art(id)
      art = IEI::Art.new
      art.id = id
      @arts[id] = art
    end

    def self.seed_database
      # // How to create a new art? Look below
      # // Does nothing . x .
      art = new_art(0)
      art.icon.index = 0
      art.name = '----------'
      art.description = 'Does Absolutely Nothing'
      art.features.push(Feature.new(0, 0, 0.0))
      # // And finally you can start making your own arts here
      # // If your having difficulty with the Features try getting the Features4Dummies XD
      # // >_> Now if your smart you'll figure out a way to manage your 'arts'
    end

    def self.create_database
      @arts = []
      seed_database
      @arts
    end
  end
end

DataManager.add_callback(:load_user_database) do
  $data_arts = IEI::ArtsSystem.create_database
end

module IEI::ArtsSystem::Mixin::Battler
  def pre_init_iei
    super
    @arts = [] # // Error Prevention ? D: : =3=
  end

  def init_iei
    super
    init_arts
    flush_arts
  end

  def post_init_iei
    super
    # // Something else .x .
  end

  # //
  def init_arts # // . x . You add custom things here
    @arts = []
  end

  def all_arts # // .x. Returns all present arts on this character
    init_arts unless @arts
    @arts.map{|i|$data_arts[i]}
  end

  def arts # // .x. You can filter certain arts here
    all_arts
  end

  def arts_features # // . x . If you need all the features it adds
    arts.inject([]){|r,obj|r+obj.features}
  end

  def feature_objects
    super + arts
  end

  # // Usage Stuff
  def remove_art art_id
    @arts.delete art_id
  end

  def set_art art_id,index
    @arts[index] = art_id
  end

  def set_art_wf art_id,index  # // Set Art, With Flush . x .
    set_art art_id,index
    flush_arts
  end

  def swap_art_order index1, index2
    @arts[index1], @arts[index2] = @arts[index2], @arts[index1]
  end

  def change_equip_art art_id,index
    set_art art_id,index  if allowed_art? art_id
  end

  def equip_art art,index
    change_equip_art(art ? art.id : 0, index)
  end

  def equip_arts *arts
    (0...arts_equip_size).each do |i|
      equip_art(arts.shift, i) if @arts[i].nil? || @arts[i].zero?
    end
  end

  def unequip_arts
    (0...arts_equip_size).each do |i| change_equip_art(0, i) end
  end

  def has_art? id
    @arts.include? id
  end

  # //
  def flush_arts
    @arts.select!{|a|allowed_art?(a)}
    @arts.pad!(arts_equip_size,0)
  end

  # // Settings
  def allowed_art? id
    true
  end

  def arts_equip_size # // Try to keep it reasonable >_>
    3
  end

  def arts_point_limit # // NYI (Not yet Implemented)
    50
  end
end

module IEI::ArtsSystem::Mixin::Party
  def pre_init_iei
    super
    @arts = {}
  end

  def init_iei
    super
  end

  def post_init_iei
    super
  end

  def gain_art(art_id, n)
    return unless $data_arts[art_id]
    @arts[art_id] ||= 0
    @arts[art_id] = (@arts[art_id] + n).max(0)
    @arts.delete(art_id) if @arts[art_id] == 0
  end

  def lose_art art_id,n
    gain_art art_id,-n
  end

  def art_number art_id
    @arts[art_id] || 0
  end

  def arts
    @arts.keys.sort.select{|k|art_number(k)>0}.map{|k|$data_arts[k]}
  end

  def has_art? art_id
    return art_number art_id  > 0
  end
end

class Window::ArtsStatus < Window::SkillStatus
  #
end

class Window::ArtsList < Window::Selectable
  include Mixin::UnitHost

  def initialize(x, y, width=window_width, height=window_height)
    @list = []
    super
    select 0
  end

  def on_unit_change
    refresh
    #select_last
  end

  def make_item_list
    case @unit
    when Game::PartyBase
      @list = @unit.arts
    else
      @list = @unit ? @unit.entity.arts : []
    end
  end

  def refresh
    make_item_list
    create_contents
    draw_all_items
    call_update_help

    # cursor fix
    old_index = @index
    @index = -1
    select(@index); select(old_index)
  end

  def item_max
    @list.size
  end

  def col_max
    2
  end

  def spacing
    0
  end

  def window_width
    (col_max * 96) + standard_padding * 2
  end

  def window_height
    (item_height * 4) + standard_padding * 2
  end

  def item_width
    (self.width - standard_padding * 2) / col_max
  end

  def item_height
    28#36
  end

  def item(index=self.index)
    @list[index]
  end

  def draw_item(index)
    entity = @unit.is_a?(Game::PartyBase) ? @unit : @unit.entity
    rect = item_rect(index).contract(anchor: 5, amount: 2)
    art  =  @list[index]
    artist.draw_art(entity, art, rect, true)
  end

  def current_item=(item)
    return unless @unit
    @unit.entity.equip_art(item, self.index)
    refresh
  end

  def update_help
    @help_window.set_item item
  end

  def active_fading?
    true
  end
end

#-inject gen_class_header 'Window::ArtsCommand'
class Window::ArtsCommand < Window::Command

  include Mixin::UnitHost

  def window_width
    return 160
  end

  def make_command_list
    add_command("Equip"   , :equip)
    add_command("Unequip" , :unequip)
    add_command("Clear"   , :clear)
    add_command("List"    , :list)
  end

  def on_unit_change
    refresh
  end

end

#-inject gen_class_header 'Scene::Arts'
class Scene::Arts < Scene::MenuUnitBase

  def start
    super
    create_all_windows
  end

  def create_all_windows
    super
    create_command_window
    create_status_window
    create_equip_window
    create_item_window
  end
    #x = @canvas.x
    #y = @canvas.y
    #w = @canvas.width
    #h = @canvas.height - @help_window.height - @title_window.height
  def create_command_window

    @command_window = Window::ArtsCommand.new(@canvas.x, @canvas.y)
    @command_window.help_window = @help_window
    @command_window.set_unit(@unit)
    @command_window.set_handler :equip   , method(:command_equip)
    @command_window.set_handler :unequip , method(:command_unequip)
    @command_window.set_handler :clear   , method(:command_clear)
    @command_window.set_handler :list    , method(:command_list)
    @command_window.set_handler :cancel  , method(:return_scene)
    @command_window.set_handler :pagedown, method(:next_unit)
    @command_window.set_handler :pageup  , method(:prev_unit)

    window_manager.add(@command_window)
  end

  def create_status_window
    @status_window = Window::ArtsStatus.new(@command_window.x2, @canvas.y,
                                            @help_window.width-@command_window.width)
    @status_window.set_unit(@unit)

    window_manager.add(@status_window)
  end

  def create_equip_window
    @equip_window = Window::ArtsList.new(
      @help_window.x, @status_window.y2, @canvas.width/2)
    @equip_window.set_unit(@unit)
    @equip_window.help_window = @help_window

    window_manager.add(@equip_window)
  end

  def create_item_window
    @item_window = Window::ArtsList.new(
      @equip_window.x2, @status_window.y2, @equip_window.width)
    @item_window.set_unit($game.party)
    @item_window.help_window = @help_window
    @item_window.height = @canvas.y2-@item_window.y

    window_manager.add(@item_window)
  end

  def command_equip
    @item_window.set_handler :ok, method(:equip_current_item)
    @item_window.set_handler :cancel, method(:end_item_selection)
    #@item_window.set_handler :pageup, method(:pred_element)
    #@item_window.set_handler :pagedown, method(:succ_element)
    @equip_window.set_handler :ok,method(:start_item_selection)
    @equip_window.set_handler :cancel,method(:end_equip_selection)
    @equip_window.activate
  end

  def command_unequip
    @equip_window.set_handler :ok,method(:unequip_current_item)
    @equip_window.set_handler :cancel,method(:end_equip_selection)
    @equip_window.activate
  end

  def command_clear
    @unit.entity.unequip_arts
    @help_window.clear
    @equip_window.refresh
    @item_window.refresh
    @status_window.refresh
    @command_window.refresh
    @command_window.activate
  end

  def command_list
    @item_window.set_handler(:ok, method(:show_item_full_info))
    @item_window.set_handler(:cancel, method(:end_item_list))
    @item_window.activate

    # eye candy
    @item_window.start_close
    @equip_window.start_close
    wait_for_windows(@item_window)
    @item_window.x = @canvas.x
    @item_window.width = @canvas.width
    @item_window.refresh
    @item_window.start_open
  end

  def start_item_selection
    @item_window.activate
  end

  def end_item_selection
    @equip_window.activate
  end

  def equip_current_item
    @equip_window.current_item = @item_window.item
    @equip_window.activate
    @status_window.refresh
  end

  def unequip_current_item
    @equip_window.current_item = nil
    @equip_window.activate
    @status_window.refresh
  end

  def end_equip_selection
    @command_window.activate
  end

  def show_item_full_info
  end

  def end_item_list
    @command_window.activate
    @item_window.start_close
    wait_for_windows(@item_window)
    @item_window.x     = @equip_window.x2
    @item_window.width = @canvas.width/2
    @item_window.refresh
    @equip_window.start_open
    @item_window.start_open
  end

  def update
    super
  end

  def on_unit_change
    @command_window.set_unit(@unit)
    @status_window.set_unit(@unit)
    @equip_window.set_unit(@unit)
    @command_window.activate
  end

end
#-inject gen_script_footer

