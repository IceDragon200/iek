##
# Windows compliant Mouse module for RPG Maker VX Ace
# Provides a bare minimal API
module Win32
  module Mouse
    class Point2
      def initialize(x = 0, y = 0)
        @x = x
        @y = y
      end

      def set(x, y)
        @x = x
        @y = y
      end
    end

    ##
    # Defines a Hash with all mouse VK_* key codes by lower cased Symbol(s)
    # [Hash<Symbol, Integer>] SYMBOL_TO_KEY
    SYMBOL_TO_KEY = {
      lbutton: Mouse::Button::LBUTTON,
      rbutton: Mouse::Button::RBUTTON,
      mbutton: Mouse::Button::MBUTTON,
      xbutton1: Mouse::Button::XBUTTON1,
      xbutton2: Mouse::Button::XBUTTON2
    }

    ##
    # Initialize Mouse module
    def self.init
      @button_state = Array.new(7, false)
      @screen_point = Point2.new(-1, -1)
      @client_point = Point2.new(-1, -1)
    end

    ##
    # @return [Integer] Mouse x position in client
    def self.x
      @client_point.x
    end

    ##
    # @return [Integer] Mouse y position in client
    def self.y
      @client_point.y
    end

    ##
    # Converts given obj to a valid VK key code
    # @overload convert_button(str)
    #   @param [String, Symbol] str Name of key
    #   @raise [KeyError] in case that the key cannot be found
    # @overload convert_button(key_id)
    #   @param [Integer] key_id VK_* code
    # @return [Integer]
    def self.convert_button(obj)
      case obj
      when String, Symbol then return SYMBOL_TO_KEY.fetch(obj.to_sym)
      when Integer        then return obj
      else                     raise TypeError, "wrong argument type #{obj.class} (expected String, Symbol or Integer)"
      end
    end

    ##
    # Checks whether or not the button was pressed?
    # @param [String, Symbol, Integer] obj
    # @return [Boolean]
    def self.press?(obj)
      button = convert_button(obj)
      return @button_state[button]
    end

    ##
    # Updates the Mouse @button_state Array
    # Due to some quirks in Windows, we can get the Mouse button states from the
    # Keyboard module
    # @return [Void]
    def self.update_button_state
      @button_state[Mouse::Button::LBUTTON] = Keyboard.press?(Mouse::Button::LBUTTON)
      @button_state[Mouse::Button::RBUTTON] = Keyboard.press?(Mouse::Button::RBUTTON)
      @button_state[Mouse::Button::MBUTTON] = Keyboard.press?(Mouse::Button::MBUTTON)
    end

    ##
    # Updates the Mouse @*_point(s)
    # @return [Void]
    def self.update_points
      pos = [0, 0].pack('l2')
      if Win32::Input.get_cursor_pos(pos) > 0
        @screen_point.set(*pos.unpack('l2'))
      end
      pos = [@screen_point.x, @screen_point.y].pack('l2')
      if Win32::Input.screen_to_client(Win32::Input.client_id, pos)
        @client_point.set(*pos.unpack('l2'))
      end
    end

    ##
    # Mouse update function
    # @return [Void]
    def self.update
      update_button_state
      update_points
    end

    class << self
      private :convert_button
      private :update_button_state
      private :update_points
    end

    init
  end
end
