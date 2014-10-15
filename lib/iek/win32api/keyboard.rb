##
# Windows compliant Keyboard module for RPG Maker VX Ace
# Provides a bare minimal API
module Win32
  module Keyboard
    ##
    # Defines a Hash with all the VK_* key codes by lower cased Symbol(s)
    # [Hash<Symbol, Integer>] SYMBOL_TO_KEY
    SYMBOL_TO_KEY = Hash[Keyboard::Key.constants.map { |k|
                         [k.to_s.downcase.to_sym, Keyboard::Key.const_get(k)] }]


    ##
    # Converts given obj to a valid VK key code
    # @overload convert_key(str)
    #   @param [String, Symbol] str Name of key
    #   @raise [KeyError] in case that the key cannot be found
    # @overload convert_key(key_id)
    #   @param [Integer] key_id VK_* code
    # @return [Integer]
    def self.convert_key(obj)
      case obj
      when String, Symbol then return SYMBOL_TO_KEY.fetch(obj.to_sym)
      when Integer        then return obj
      else                     raise TypeError, "wrong argument type #{obj.class} (expected String, Symbol or Integer)"
      end
    end

    ##
    # Initialize Keyboard module
    def self.init
      @key_state = Array.new(256, false)
    end

    ##
    # Checks whether or not the key was pressed?
    # @param [String, Symbol, Integer] obj
    # @return [Boolean]
    def self.press?(obj)
      key = convert_key(obj)
      return @key_state[key]
    end

    ##
    # Updates the @key_state Array by grabbing the values from the OS
    # @return [Boolean] Whether or not the array was updated sucessfully
    def self.update_key_state
      byte_array = "\0" * 256
      if Win32::Input.get_keyboard_state(byte_array) > 0
        byte_array.each_byte.each_with_index do |byte, i|
          @key_state[i] = (byte >> 7) == 1
        end
        true
      end
    end

    ##
    # Keyboard update function
    # @return [Void]
    def self.update
      update_key_state
    end

    class << self
      private :convert_key
      private :update_key_state
    end

    init
  end
end
