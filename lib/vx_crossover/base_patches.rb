class Game_Map
  def setup(map_id)
    @map_id = map_id
    @map = DataCache.load_map_by_id(@map_id)
    @display_x = 0
    @display_y = 0
    @passages = $data_system.passages
    referesh_vehicles
    setup_events
    setup_scroll
    setup_parallax
    @need_refresh = false
  end
end
