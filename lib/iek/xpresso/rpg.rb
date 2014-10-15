module RPG
  class BaseItem
    def kind_id
      0
    end

    def to_mix_key
      [kind_id, id]
    end
  end
  class Item
    def kind_id
      1
    end
  end
  class Weapon
    def kind_id
      2
    end
  end
  class Armor
    def kind_id
      3
    end
  end
  class Skill
    def kind_id
      4
    end
  end
end
