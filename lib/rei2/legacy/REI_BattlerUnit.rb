class REI::BattlerUnit
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :name                     # 名前
  attr_accessor :nickname                 # 二つ名
  attr_reader   :character_name           # 歩行グラフィック ファイル名
  attr_reader   :character_index          # 歩行グラフィック インデックス
  attr_reader   :character_hue
  attr_reader   :face_name                # 顔グラフィック ファイル名
  attr_reader   :face_index               # 顔グラフィック インデックス
  attr_reader   :class_id                 # 職業 ID
  attr_reader   :level                    # レベル
  attr_reader   :action_input_index       # 入力中の戦闘行動番号
  attr_reader   :last_skill               # カーソル記憶用 : スキル
  attr_reader   :inventory
  attr_reader   :_ai
  attr_reader   :_hot_keys
  def initialize
    super
  end
  def pre_init_members
    super
    @last_skill = Game::BaseItem.new
    @inventory  = Game::Inventory.new self # // . x .
    @_ai        = Game::AI.new self        # // . x .
    @_hot_keys  = Game::HotKeys.new self   # // . x .
    init_equipped_skills
    @step_anime = true
    @tweener_stack = []
    @character_hue = 0
  end
  def init_members
    super
  end
  def post_init_members
    super
    reset_add_xy
    setup_equipped_skills
  end
  def _map
    return $game.rogue
  end
  def subject?
    return _map.subject == self
  end
  def set_id( new_id )
    @id = new_id
    make_ref_code
    return self
  end
  def make_ref_code
    @ref_code = [@id, @battler_id, self.battler_symbol]
    @hash_code = @ref_code.hash
    return self
  end
  def get_hash_code
    return @hash_code
  end
  def reset_add_xy
    @add_x, @add_y = 0, 0
    self
  end
  def add_x
    return @add_x
  end
  def add_y
    return @add_y
  end
  def mm_x
    self.real_x + (@add_x / 32.0)
  end
  def mm_y
    self.real_y + (@add_y / 32.0)
  end
  def mm_bobbing?
    return subject?
  end
  def mm_bob_amount
    return 6
  end
  def clear_tweener_stack
    @tweener_stack.clear ; reset_add_xy
  end
  def create_tweener( sx, sy, tx, ty, time, easer=:linear )
    return MACL::Tween.new([sx, sy], [tx, ty], easer, MACL::Tween.frames_to_tt( time ))
  end
  def add_tweener( sx, sy, tx, ty, time, easer=:linear )
    @tweener_stack << create_tweener( sx, sy, tx, ty, time, easer )
  end
  def update
    super
    update_tweener
  end
  def update_tweener
    unless @tweener_stack.empty?
      @tweener = @tweener_stack.shift
    else
      reset_add_xy
    end unless @tweener
    if @tweener
      @tweener.update
      @add_x, @add_y = *@tweener.values
      if @tweener.done?
        @tweener = nil
      end
    end
  end
  def battler
  end
  #--------------------------------------------------------------------------
  # ● グラフィックの初期化
  #--------------------------------------------------------------------------
  def init_graphics
    @character_name  = battler.character_name
    @character_index = battler.character_index
    @character_hue   = 0
    @face_name       = battler.face_name
    @face_index      = battler.face_index
  end
  #--------------------------------------------------------------------------
  # ● 指定レベルに上がるのに必要な累計経験値の取得
  #--------------------------------------------------------------------------
  def exp_for_level(level)
    self.class.exp_for_level(level)
  end
  #--------------------------------------------------------------------------
  # ● 経験値の初期化
  #--------------------------------------------------------------------------
  def init_exp
    @exp[@class_id] = current_level_exp
  end
  #--------------------------------------------------------------------------
  # ● 経験値の取得
  #--------------------------------------------------------------------------
  def exp
    @exp[@class_id]
  end
  #--------------------------------------------------------------------------
  # ● 現在のレベルの最低経験値を取得
  #--------------------------------------------------------------------------
  def current_level_exp
    exp_for_level(@level)Includes
  end
  #--------------------------------------------------------------------------
  # ● 次のレベルの経験値を取得
  #--------------------------------------------------------------------------
  def next_level_exp
    exp_for_level( @level + 1 )
  end
  def max_level_exp
    exp_for_level( max_level-1 )
  end
  #--------------------------------------------------------------------------
  # ● 最大レベル
  #--------------------------------------------------------------------------
  def max_level
    battler.max_level
  end
  #--------------------------------------------------------------------------
  # ● 最大レベル判定
  #--------------------------------------------------------------------------
  def max_level?
    @level >= max_level
  end
  #--------------------------------------------------------------------------
  # ● スキルの初期化
  #--------------------------------------------------------------------------
  def init_skills
    @skills = []
    self.class.learnings.each do |learning|
      learn_skill(learning.skill_id) if learning.level <= @level
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備品の初期化
  #     equips : 初期装備の配列
  #--------------------------------------------------------------------------
  def init_equips(equips)
    @equips = Array.new(equip_slots.size) { Game::EquipItem.new }#Game::BaseItem.new }
    equips.each_with_index do |item_id, i|
      etype_id = index_to_etype_id(i)
      slot_id = empty_slot(etype_id)
      @equips[slot_id].set_equip(etype_id == 0, item_id) if slot_id
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # ● エディタで設定されたインデックスを装備タイプ ID に変換
  #--------------------------------------------------------------------------
  def index_to_etype_id(index)
    equip_slots[index] # // O_O EB Why the hell did I have to fix this?
    #index == 1 && dual_wield? ? 0 : index
  end
  #--------------------------------------------------------------------------
  # ● 装備タイプからスロット ID のリストに変換
  #--------------------------------------------------------------------------
  def slot_list(etype_id)
    result = []
    equip_slots.each_with_index {|e, i| result.push(i) if e == etype_id }
    result
  end
  #--------------------------------------------------------------------------
  # ● 装備タイプからスロット ID に変換（空きを優先）
  #--------------------------------------------------------------------------
  def empty_slot(etype_id)
    list = slot_list(etype_id)
    list.find {|i| @equips[i].is_nil? } || list[0]
  end
  #--------------------------------------------------------------------------
  # ● 装備スロットの配列を取得
  #--------------------------------------------------------------------------
  def equip_slots
    return [0,0,2,3,5,6,4,7] if dual_wield?       # 二刀流
    return [0,1,2,3,5,6,4,7]                      # 通常
  end
  #--------------------------------------------------------------------------
  # ● 武器オブジェクトの配列取得
  #--------------------------------------------------------------------------
  def weapons
    @equips.select {|item| item.is_weapon? }.map {|item| item.object }
  end
  #--------------------------------------------------------------------------
  # ● 防具オブジェクトの配列取得
  #--------------------------------------------------------------------------
  def armors
    @equips.select {|item| item.is_armor? }.map {|item| item.object }
  end
  #--------------------------------------------------------------------------
  # ● 装備品オブジェクトの配列取得
  #--------------------------------------------------------------------------
  def equips
    @equips.map {|item| item.object }
  end
  #--------------------------------------------------------------------------
  # ● 装備変更の可能判定
  #     slot_id : 装備スロット ID
  #--------------------------------------------------------------------------
  def equip_change_ok?(slot_id)
    return false if equip_type_fixed?(equip_slots[slot_id])
    return false if equip_type_sealed?(equip_slots[slot_id])
    return true
  end
  #--------------------------------------------------------------------------
  # ● 装備の変更
  #     slot_id : 装備スロット ID
  #     item    : 武器／防具（nil なら装備解除）
  #--------------------------------------------------------------------------
  def change_equip(slot_id, item)
    return unless trade_item_with_party(item, equips[slot_id])
    return if item && equip_slots[slot_id] != item.etype_id
    @equips[slot_id].object = item
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 装備の強制変更
  #     slot_id : 装備スロット ID
  #     item    : 武器／防具（nil なら装備解除）
  #--------------------------------------------------------------------------
  def force_change_equip(slot_id, item)
    @equips[slot_id].object = item
    release_unequippable_items(false)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● パーティとアイテムを交換する
  #     new_item : パーティから取り出すアイテム
  #     old_item : パーティに返すアイテム
  #--------------------------------------------------------------------------
  def trade_item_with_party(new_item, old_item)
    return false if new_item && !self.inventory.has_item?(new_item)
    self.inventory.gain_item(old_item, 1)
    self.inventory.lose_item(new_item, 1)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 装備の変更（ID で指定）
  #     slot_id : 装備スロット ID
  #     item_id : 武器／防具 ID
  #--------------------------------------------------------------------------
  def change_equip_by_id(slot_id, item_id)
    if equip_slots[slot_id] == 0
      change_equip(slot_id, $data_weapons[item_id])
    else
      change_equip(slot_id, $data_armors[item_id])
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備の破棄
  #     item : 破棄する武器／防具
  #--------------------------------------------------------------------------
  def discard_equip(item)
    slot_id = equips.index(item)
    @equips[slot_id].object = nil if slot_id
  end
  #--------------------------------------------------------------------------
  # ● 装備できない装備品を外す
  #     item_gain : 外した装備品をパーティに戻す
  #--------------------------------------------------------------------------
  def release_unequippable_items(item_gain = true)
    @equips.each_with_index do |item, i|
      if !equippable?(item.object) || item.object.etype_id != equip_slots[i]
        trade_item_with_party(nil, item.object) if item_gain
        item.object = nil
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備を全て外す
  #--------------------------------------------------------------------------
  def clear_equipments
    equip_slots.size.times do |i|
      change_equip(i, nil) if equip_change_ok?(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 最強装備
  #--------------------------------------------------------------------------
  def optimize_equipments
    clear_equipments
    equip_slots.size.times do |i|
      next if !equip_change_ok?(i)
      items = $game.party.equip_items.select do |item|
        item.etype_id == equip_slots[i] &&
        equippable?(item) && item.performance >= 0
      end
      change_equip(i, items.max_by {|item| item.performance })
    end
  end
  #--------------------------------------------------------------------------
  # ● スキルの必要武器を装備しているか
  #--------------------------------------------------------------------------
  def skill_wtype_ok?(skill)
    wtype_id1 = skill.required_wtype_id1
    wtype_id2 = skill.required_wtype_id2
    return true if wtype_id1 == 0 && wtype_id2 == 0
    return true if wtype_id1 > 0 && wtype_equipped?(wtype_id1)
    return true if wtype_id2 > 0 && wtype_equipped?(wtype_id2)
    return false
  end
  #--------------------------------------------------------------------------
  # ● 特定のタイプの武器を装備しているか
  #--------------------------------------------------------------------------
  def wtype_equipped?(wtype_id)
    weapons.any? {|weapon| weapon.wtype_id == wtype_id }
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    release_unequippable_items
    super
  end
  #--------------------------------------------------------------------------
  # ● アクターか否かの判定
  #--------------------------------------------------------------------------
  def battler?
    return true
  end
  #--------------------------------------------------------------------------
  # ● 味方ユニットを取得
  #--------------------------------------------------------------------------
  def friends_unit
    $game.party
  end
  #--------------------------------------------------------------------------
  # ● 敵ユニットを取得
  #--------------------------------------------------------------------------
  def opponents_unit
    $game.troop
  end
  #--------------------------------------------------------------------------
  # ● アクター ID 取得
  #--------------------------------------------------------------------------
  def id
    @battler_id
  end
  #--------------------------------------------------------------------------
  # ● インデックス取得
  #--------------------------------------------------------------------------
  def index
    0#$game.party.members.index(self)
  end
  #--------------------------------------------------------------------------
  # ● バトルメンバー判定
  #--------------------------------------------------------------------------
  def battle_member?
    true#$game.party.battle_members.include?(self)
  end
  #--------------------------------------------------------------------------
  # ● 職業オブジェクト取得
  #--------------------------------------------------------------------------
  def class
    $data_classes[@class_id]
  end
  #--------------------------------------------------------------------------
  # ● スキルオブジェクトの配列取得
  #--------------------------------------------------------------------------
  def skills
    (@skills | added_skills).sort.map {|id| $data_skills[id] }
  end
  #--------------------------------------------------------------------------
  # ● 現在使用できるスキルの配列取得
  #--------------------------------------------------------------------------
  def usable_skills
    skills.select {|skill| usable?(skill) }
  end
  #--------------------------------------------------------------------------
  # ● 特徴を保持する全オブジェクトの配列取得
  #--------------------------------------------------------------------------
  def feature_objects
    super + [battler] + [self.class] + equips.compact
  end
  #--------------------------------------------------------------------------
  # ● 攻撃時属性の取得
  #--------------------------------------------------------------------------
  def atk_elements
    set = super
    set |= [1] if weapons.compact.empty?  # 素手：物理属性
    return set
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の最大値取得
  #--------------------------------------------------------------------------
  def param_max(param_id)
    return 9999 if param_id == 0  # MHP
    return super
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の基本値取得
  #--------------------------------------------------------------------------
  def param_base(param_id)
    self.class.params[param_id, @level]
  end
  #--------------------------------------------------------------------------
  # ● 通常能力値の加算値取得
  #--------------------------------------------------------------------------
  def param_plus(param_id)
    equips.compact.inject(super) {|r, item| r += item.params[param_id] }
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃 アニメーション ID の取得
  #--------------------------------------------------------------------------
  def atk_animation_id1
    if dual_wield?
      return weapons[0].animation_id if weapons[0]
      return weapons[1] ? 0 : 1
    else
      return weapons[0] ? weapons[0].animation_id : 1
    end
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃 アニメーション ID の取得（二刀流：武器２）
  #--------------------------------------------------------------------------
  def atk_animation_id2
    if dual_wield?
      return weapons[1] ? weapons[1].animation_id : 0
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 経験値の変更
  #     show : レベルアップ表示フラグ
  #--------------------------------------------------------------------------
  def change_exp(exp, show)
    @exp[@class_id] = [exp, 0].max
    last_level = @level
    last_skills = skills
    level_up while !max_level? && self.exp >= next_level_exp
    level_down while self.exp < current_level_exp
    display_level_up(skills - last_skills) if show && @level > last_level
    refresh
  end
  #--------------------------------------------------------------------------
  # ● レベルアップ
  #--------------------------------------------------------------------------
  def level_up
    @level += 1
    self.class.learnings.each do |learning|
      learn_skill(learning.skill_id) if learning.level == @level
    end
  end
  #--------------------------------------------------------------------------
  # ● レベルダウン
  #--------------------------------------------------------------------------
  def level_down
    @level -= 1
  end
  #--------------------------------------------------------------------------
  # ● レベルアップメッセージの表示
  #     new_skills : 新しく習得したスキルの配列
  #--------------------------------------------------------------------------
  def display_level_up(new_skills)
    #$game.message.new_page
    #$game.message.add(sprintf(Vocab::LevelUp, @name, Vocab::level, @level))
    #new_skills.each do |skill|
    #  $game.message.add(sprintf(Vocab::ObtainSkill, skill.name))
    #end
  end
  #--------------------------------------------------------------------------
  # ● 経験値の獲得（経験獲得率を考慮）
  #--------------------------------------------------------------------------
  def gain_exp(exp)
    change_exp(self.exp + (exp * final_exp_rate).to_i, true)
  end
  #--------------------------------------------------------------------------
  # ● 最終的な経験獲得率の計算
  #--------------------------------------------------------------------------
  def final_exp_rate
    exr * (battle_member? ? 1 : reserve_members_exp_rate)
  end
  #--------------------------------------------------------------------------
  # ● 控えメンバーの経験獲得率を取得
  #--------------------------------------------------------------------------
  def reserve_members_exp_rate
    $data_system.opt_extra_exp ? 1 : 0
  end
  #--------------------------------------------------------------------------
  # ● レベルの変更
  #     show : レベルアップ表示フラグ
  #--------------------------------------------------------------------------
  def change_level(level, show)
    level = [[level, max_level].min, 1].max
    change_exp(exp_for_level(level), show)
  end
  #--------------------------------------------------------------------------
  # ● スキルを覚える
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    unless skill_learn?($data_skills[skill_id])
      @skills.push(skill_id)
      @skills.sort!
    end
  end
  #--------------------------------------------------------------------------
  # ● スキルを忘れる
  #--------------------------------------------------------------------------
  def forget_skill(skill_id)
    @skills.delete(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● スキルの習得済み判定
  #--------------------------------------------------------------------------
  def skill_learn?(skill)
    skill.is_a?(RPG::Skill) && @skills.include?(skill.id)
  end
  #--------------------------------------------------------------------------
  # ● 説明の取得
  #--------------------------------------------------------------------------
  def description
    battler.description
  end
  #--------------------------------------------------------------------------
  # ● 職業の変更
  #     keep_exp : 経験値を引き継ぐ
  #--------------------------------------------------------------------------
  def change_class(class_id, keep_exp = false)
    @exp[class_id] = exp if keep_exp
    @class_id = class_id
    change_exp(@exp[@class_id] || 0, false)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● グラフィックの変更
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index, face_name, face_index)
    @character_name = character_name
    @character_index = character_index
    @face_name = face_name
    @face_index = face_index
  end
  #--------------------------------------------------------------------------
  # ● スプライトを使うか？
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  #--------------------------------------------------------------------------
  # ● ダメージ効果の実行
  #--------------------------------------------------------------------------
  def perform_damage_effect
    _map.screen.start_shake(5, 5, 10)
    set_sprite_effect_type( :blink )
    Sound.play_battler_damage
  end
  #--------------------------------------------------------------------------
  # ● コラプス効果の実行
  #--------------------------------------------------------------------------
  def perform_collapse_effect
    #if $game.party.in_battle
      set_sprite_effect_type( :collapse )
      Sound.play_battler_collapse
    #end
  end
  #--------------------------------------------------------------------------
  # ● 自動戦闘用の行動候補リストを作成
  #--------------------------------------------------------------------------
  def make_action_list
    list = []
    list.push(Game::Action.new(self).set_attack.evaluate)
    usable_skills.each do |skill|
      list.push(Game::Action.new(self).set_skill(skill.id).evaluate)
    end
    list
  end
  #--------------------------------------------------------------------------
  # ● 自動戦闘時の戦闘行動を作成
  #--------------------------------------------------------------------------
  def make_auto_battle_actions
    @actions.size.times do |i|
      @actions[i] = make_action_list.max {|action| action.value }
    end
  end
  #--------------------------------------------------------------------------
  # ● 混乱時の戦闘行動を作成
  #--------------------------------------------------------------------------
  def make_confusion_actions
    @actions.size.times do |i|
      @actions[i].set_confusion
    end
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の作成
  #--------------------------------------------------------------------------
  def make_actions
    super
    if auto_battle?
      make_auto_battle_actions
    elsif confusion?
      make_confusion_actions
    end
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーが 1 歩動いたときの処理
  #--------------------------------------------------------------------------
  def on_player_walk
    @result.clear
    check_floor_effect
    if $game.player.normal_walk?
      turn_end_on_map
      states.each {|state| update_state_steps(state) }
      show_added_states
      show_removed_states
    end
  end
  #--------------------------------------------------------------------------
  # ● ステートの歩数カウントを更新
  #--------------------------------------------------------------------------
  def update_state_steps(state)
    if state.remove_by_walking
      @state_steps[state.id] -= 1 if @state_steps[state.id] > 0
      remove_state(state.id) if @state_steps[state.id] == 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 付加されたステートの表示
  #--------------------------------------------------------------------------
  def show_added_states
    @result.added_state_objects.each do |state|
      $game.message.add(name + state.message1) unless state.message1.empty?
    end
  end
  #--------------------------------------------------------------------------
  # ● 解除されたステートの表示
  #--------------------------------------------------------------------------
  def show_removed_states
    @result.removed_state_objects.each do |state|
      $game.message.add(name + state.message4) unless state.message4.empty?
    end
  end
  #--------------------------------------------------------------------------
  # ● 何歩歩いたときに戦闘中の 1 ターン相当とみなすか
  #--------------------------------------------------------------------------
  def steps_for_turn
    return 20
  end
  #--------------------------------------------------------------------------
  # ● マップ画面上でのターン終了処理
  #--------------------------------------------------------------------------
  def turn_end_on_map
    if $game.party.steps % steps_for_turn == 0
      on_turn_end
      perform_map_damage_effect if @result.hp_damage > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 床効果判定
  #--------------------------------------------------------------------------
  def check_floor_effect
    execute_floor_damage if $game.player.on_damage_floor?
  end
  #--------------------------------------------------------------------------
  # ● 床ダメージの処理
  #--------------------------------------------------------------------------
  def execute_floor_damage
    damage = (basic_floor_damage * fdr).to_i
    self.hp -= [damage, max_floor_damage].min
    perform_map_damage_effect if damage > 0
  end
  #--------------------------------------------------------------------------
  # ● 床ダメージの基本値を取得
  #--------------------------------------------------------------------------
  def basic_floor_damage
    return 10
  end
  #--------------------------------------------------------------------------
  # ● 床ダメージの最大値を取得
  #--------------------------------------------------------------------------
  def max_floor_damage
    $data_system.opt_floor_death ? hp : [hp - 1, 0].max
  end
  #--------------------------------------------------------------------------
  # ● マップ上でのダメージ効果の実行
  #--------------------------------------------------------------------------
  def perform_map_damage_effect
    _map.screen.start_flash_for_damage
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動のクリア
  #--------------------------------------------------------------------------
  def clear_actions
    super
    @action_input_index = 0
  end
  #--------------------------------------------------------------------------
  # ● 入力中の戦闘行動を取得
  #--------------------------------------------------------------------------
  def input
    @actions[@action_input_index]
  end
  #--------------------------------------------------------------------------
  # ● 次のコマンド入力へ
  #--------------------------------------------------------------------------
  def next_command
    return false if @action_input_index >= @actions.size - 1
    @action_input_index += 1
    return true
  end
  #--------------------------------------------------------------------------
  # ● 前のコマンド入力へ
  #--------------------------------------------------------------------------
  def prior_command
    return false if @action_input_index <= 0
    @action_input_index -= 1
    return true
  end
end
