module Taggable
  attr_accessor :tags

  def tags
    @tags ||= []
  end

  def tag(name)
    tags << name
  end
end
