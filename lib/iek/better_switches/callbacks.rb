$simport.r('better_switches/callbacks', '1.0.0', 'Utilizes iek callbacks for better_switches') do |h|
  h.depend('better_switches', '>= 1.0.0')
  h.depend!('iek/callbacks', '>= 1.0.0')
end

class Game_Switches
  include Mixin::Callback

  def on_change(id)
    $game_map.need_refresh = true
    try_callback(:on_change, id)
  end
end
