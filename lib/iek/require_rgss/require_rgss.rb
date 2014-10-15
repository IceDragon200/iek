# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# IEK (https://github.com/IceDragon200/IEK)
# Require RGSS
#   by IceDragon (https://github.com/IceDragon200)
#   version 1.0.0
# Description
#   --
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
def top_binding
  self.send(:binding)
end

module RequireRGSS
  def self.load(name, options={})
    if data = $RGSS_SCRIPTS[name]
      eval(data[2], top_binding, name, 1)
    else
      raise LoadError, "RGSS_SCRIPT #{name} does not exists"
    end
  end
end

module Kernel
  def vixen_require(name, options={})
    RequireRGSS.load(name, options)
  end

  alias :require_rgss :vixen_require
end
