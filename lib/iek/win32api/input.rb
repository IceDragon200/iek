module Win32
  module Input
    class << self
      # @return [Integer] Pointer to the Window Handle
      attr_reader :client_id
    end

    ##
    # Initialize the Win32 Module
    def self.init
      set_client
    end

    ##
    # Sets the Window client
    def self.set_client
      game_name = "\0" * 256 # create a 256 NULL byte Array
      get_private_profile_string_a('Game', ' Title', '', game_name, 256, ".\\Game.ini" )
      game_name.delete!("\0") # remove NULL bytes
      @client_id = find_window_a('RGSS Player', game_name)
    end

    ##
    # :nodoc:
    def self.get_async_key_state(key_code)
      (@get_async_key_state ||= Win32API.new("user32", "GetAsyncKeyState", "i", "i")).call(key_code)
    end

    ##
    # :nodoc:
    def self.get_key_state(key_code)
      (@get_key_state ||= Win32API.new("user32", "GetKeyState", "i", "i")).call(key_code)
    end

    ##
    # :nodoc:
    def self.get_keyboard_state(byte_ary256)
      (@get_keyboard_state ||= Win32API.new("user32", "GetKeyboardState", "p", "i")).call(byte_ary256)
    end

    ##
    # :nodoc:
    def self.get_private_profile_string_a(p1, p2, p3, p4, buffer_size, p6)
      (@get_private_profile_string_a ||= Win32API.new( "kernel32", "GetPrivateProfileStringA", "pppplp", "l")).call(p1, p2, p3, p4, buffer_size, p6)
    end

    ##
    # :nodoc:
    def self.get_cursor_pos(long_ary2_pnt)
      (@get_cursor_pos ||= Win32API.new("user32", "GetCursorPos", "p" , "i")).call(long_ary2_pnt)
    end

    ##
    # :nodoc:
    def self.set_cursor_pos(x, y)
      (@set_cursor_pos ||= Win32API.new("user32", "SetCursorPos", "ll" , "i")).call(x, y)
    end

    ##
    # :nodoc:
    def self.screen_to_client(client_id, pnt)
      (@screen_to_client ||= Win32API.new("user32", "ScreenToClient", "lp", "i")).call(client_id, pnt)
    end

    ##
    # :nodoc:
    def self.client_to_screen(client_id, pnt)
      (@client_to_screen ||= Win32API.new("user32", "ClientToScreen", "lp", "i")).call(client_id, pnt)
    end

    ##
    # :nodoc:
    def self.get_client_rect(client_id, pnt)
      (@get_client_rect ||= Win32API.new("user32", "GetClientRect", "lp", "i")).call(client_id, pnt)
    end

    ##
    # :nodoc:
    def self.find_window_a(pnt1, pnt2)
      (@find_window_a ||= Win32API.new("user32", "FindWindowA", "pp", "l")).call(pnt1, pnt2)
    end

    class << self
      private :set_client
    end

    init
  end
end
