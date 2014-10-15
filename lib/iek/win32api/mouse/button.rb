module Win32
  module Mouse
  ##
  # A list of the mouse related VK_* key codes from the Windows library
  #   http://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
    module Button
      ###
      #NULL                      = 0x00 # <NULL>
      LBUTTON                   = 0x01 # Left mouse button
      RBUTTON                   = 0x02 # Right mouse button
      #CANCEL                    = 0x03 # Control-break processing
      MBUTTON                   = 0x04 # Middle mouse button (three-button mouse)
      XBUTTON1                  = 0x05 # X1 mouse button
      XBUTTON2                  = 0x06 # X2 mouse button
    end
  end
end
