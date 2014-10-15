module Eventable
  def init_eventable
    @__events__ = {}
  end

  def on(symbol, &block)
    (@__events__[symbol] ||= []).push(block)
  end

  def trigger(symbol, context)
    @__events__[symbol].try(:call, context)
  end
end
