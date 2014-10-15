module Win32
  class LinkObject
    def func(dll, *args)
      Win32API.new(dll, *args)
    end
  end
end
