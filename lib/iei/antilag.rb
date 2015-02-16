#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - AntiLag"
#-define HDR_GDC :dc=>"03/27/2012"
#-define HDR_GDM :dm=>"05/26/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"1.0"
#-inject gen_script_header HDR_TYP, HDR_GNM, HDR_GAUT, HDR_GDC, HDR_GDM, HDR_VER
($imported||={})['IEI::AntiLag'] = 0x01000

#-inject gen_module_header 'IEI::AntiLag'
module IEI
  module AntiLag

  end
end

#-inject gen_class_header 'Game::Character'
class Game::Character

  def on_screen?
    self.screen_x.between?(-32, Graphics.width + 32) and
     self.screen_y.between?(-32, Graphics.height + 32)
  end

end

#-inject gen_class_header 'Sprite::Character'
class Sprite::Character

  def update
    super
    if @character && @on_screen = @character.on_screen?
      update_bitmap
      update_src_rect
      update_position
      update_other
    elsif
      self.visible = false
    end
    update_balloon
    setup_new_effect
  end

end
