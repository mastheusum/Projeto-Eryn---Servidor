extends PlayableCharacter

class_name Monster

var gateways_list  : Array = []
var search_range_list : Array = []

var _helmet : Item = Item.new()
var _armor : Item = Item.new()
var _legs : Item = Item.new()
var _boots : Item = Item.new()
var _weapon1 : Item = Item.new()
var _weapon2 : Item = Item.new()
var _ring1 : Item = Item.new()
var _ring2 : Item = Item.new()

var _dir : Vector2 = Vector2.ZERO
var _move_speed : int = 200

func _ready():
	$SearchRange.connect("body_entered", self, "_on_SearchRange_body_entered")
	$SearchRange.connect("body_exited", self, "_on_SearchRange_body_exited")
	$IDLE.connect("timeout", self, "_on_IDLE_timeout")
	$Attack.connect("timeout", self, "_on_Attack_timeout")
	
	set_network_master(1)

func set_new_gateway(gateway : int):
	gateways_list.append(gateway)

func remove_gateway(gateway : int):
	gateways_list.erase(gateway)

func as_dict():
	var dict = {}
	
	dict['world_id'] = get_parent().unique_area_name
	dict['id'] = id
	dict['name'] = creature_name
	dict['skin'] = sprite_index
	dict['global_position_x'] = int(global_position.x)
	dict['global_position_y'] = int(global_position.y)
	dict['level'] = level
	dict['strength'] = strength
	dict['constitution'] = constitution
	dict['dexterity'] = dexterity
	dict['agility'] = agility
	dict['intelligence'] = intelligence
	dict['willpower'] = willpower
	dict['perception'] = perception
	dict['wisdom'] = wisdom
	
	dict['life'] = life
	dict['mana'] = mana
	
	dict['move_speed'] = _move_speed
	
	dict['helmet'] = _helmet.id if _helmet else -1
	dict['armor'] = _armor.id if _armor else -1
	dict['legs'] = _legs.id if _legs else -1
	dict['boots'] = _boots.id if _boots else -1
	dict['weapon1'] = _weapon1.id if _weapon1 else -1
	dict['weapon2'] = _weapon2.id if _weapon2 else -1
	dict['ring1'] = _ring1.id if _ring1 else -1
	dict['ring2'] = _ring2.id if _ring2 else -1
	
	return dict

func proxy_as_dict():
	var dict = {}
	
	dict['world_id'] = get_parent().unique_area_name
	dict['id'] = id
	dict['name'] = creature_name
	dict['skin'] = sprite_index
	dict['global_position_x'] = global_position.x
	dict['global_position_y'] = global_position.y
	dict['life'] = life
	dict['mana'] = mana
	dict['level'] = level
	dict['move_speed'] = _move_speed
	dict['constitution'] = constitution
	
	return dict

func set_from_dict(dict : Dictionary):
	id = dict['id']
	creature_name = dict['name']
	sprite_index = dict['skin']

	level = dict['level']
	strength = dict['strength']
	constitution = dict['constitution'] 
	dexterity = dict['dexterity'] 
	agility = dict['agility'] 
	intelligence = dict['intelligence'] 
	willpower = dict['willpower'] 
	perception = dict['perception'] 
	wisdom = dict['wisdom']
	
	_move_speed = dict['move_speed']
	
	set_max_life()
	set_max_mana()
	
	life = max_life
	mana = max_mana
	
	_helmet = _helmet.set_from_dict( dict['helmet'] )
	_armor = _armor.set_from_dict( dict['armor'] )
	_legs = _legs.set_from_dict( dict['legs'] )
	_boots = _boots.set_from_dict( dict['boots'] )
	_weapon1 = _weapon1.set_from_dict( dict['weapon1'] )
	_weapon2 =  _weapon2.set_from_dict( dict['weapon2'] )
	_ring1 = _ring1.set_from_dict( dict['ring1'] ) 
	_ring2 = _ring2.set_from_dict( dict['ring2'] )
	
	return self

func receive_damage(value : int, type : int):
	var max_damage = 1 + ( value if value < life else life )
	randomize()
	var damage = (randi() % max_damage)
	life -= damage
	
	for gateway in gateways_list:
		ConnectionManager.rpc_id(gateway, 'get_status_alert', global_position, str(damage), 1)
		if life <= 0:
			for element in aggressor_list:
				GameManager.get_character(element).gain_experience( level * 10 )
			ConnectionManager.rpc_id(gateway, 'destroy_monster', get_parent().name)
			aggressor_list = []
			hide()
			get_parent().start_spawner()
		else:
			ConnectionManager.rpc_id(gateway, 'update_monster', get_parent().name, "life", life)

# need be better... is usefull only by melle monsters
func _process(delta):
	_behaviour(delta)

func _on_SearchRange_body_entered(body : Node):
	print(1)
	if body.is_in_group('Character'):
		search_range_list.append(body)
		print(2)

func _on_SearchRange_body_exited(body : Node):
	if body.is_in_group('Character'):
		search_range_list.erase(body)

func _on_IDLE_timeout():
	pass # Replace with function body.

func _on_Attack_timeout():
	pass # Replace with function body.

func _behaviour(delta):
	pass
#	if (not gateways_list.empty()) and visible:
#		if search_range_list.empty():
#			if $IDLE.is_stopped():
#				randomize()
#				_dir = Vector2(rand_range(-10, 10), rand_range(-10, 10)).normalized()
#				$IDLE.start(1)
#			else:
#				move_and_collide(_dir * _move_speed * delta / 2)
#		else:
#			_dir = (search_range_list[0].global_position - global_position).normalized()
#			move_and_collide(_dir * _move_speed * delta)
#		for element in gateways_list:
#			ConnectionManager.rpc_id(int(element), 'set_monster_position', get_parent().name, global_position, _dir)


