extends PlayableCharacter

class_name Character

enum Jobs {
	KNIGHT,
	ARCHER,
	SORCERER,
	DRUID
}

var account_id : int
var experience : int
var attribute_points : int # to distribute among attributes when leveling up
var job : int # Type ENUM Jobs

var inventory : Array = []

var _helmet : Item = null
var _armor : Item = null
var _legs : Item = null
var _boots : Item = null
var _weapon1 : Item = null
var _weapon2 : Item = null
var _ring1 : Item = null
var _ring2 : Item = null

class Slot:
	var item : Item
	var amount : int

func _ready():
	print(inventory)

func set_attribute(attribute : String, value : int):
	var status_accessor : PoolStringArray = [
		"life",
		"mana"
	]
	var attribute_accessor : PoolStringArray = [
		"strength",
		"constitution",
		"dexterity",
		"agility",
		"intelligence",
		"willpower",
		"perception",
		"wisdom"
	]
	if attribute in status_accessor:
		if attribute == 'life':
			if life <= 0:
				global_position = Vector2.ZERO
				life = max_life
				mana = max_mana
				for gateway in aggressor_list:
					GameManager.get_character(gateway).gain_experience( level * 10 )
				GameManager.destroy_character(int(name))
	if attribute_points > 0 and attribute in attribute_accessor:
		attribute_points -= 1
		var val : int = 0
		match attribute:
			"strength":
				strength += 1
				val = strength
			"constitution":
				constitution += 1
				val = constitution
			"dexterity":
				dexterity += 1
				val = dexterity
			"agility":
				agility += 1
				val = agility
			"intelligence":
				intelligence += 1
				val = intelligence
			"willpower":
				willpower += 1
				val = willpower
			"perception":
				perception += 1
				val = perception
			"wisdom":
				wisdom += 1
				val = wisdom
		ConnectionManager.rpc_id(int(name), "update_status", int(name), attribute, val)
		ConnectionManager.rpc_id(int(name), "update_status", int(name), "attribute_points", attribute_points)
		if attribute == "constitution":
			max_life = 5 * constitution
			ConnectionManager.rpc("update_status", int(name), "max_life", max_life)
		elif attribute == "intelligence":
			max_mana = 5 * intelligence
			ConnectionManager.rpc("update_status", int(name), "max_mana", max_mana)

func gain_experience(value : int):
	experience += value
	ConnectionManager.rpc_id(int(name), 'update_status', int(name), 'experience', experience)
	calculate_current_level()

# based on character's experience calculates his level
func calculate_current_level():
	var old = level
	level = 1 + int(sqrt(experience as float) / 10)
	if old < level:
		attribute_points += 3
		ConnectionManager.rpc_id(int(name), 'update_status', int(name), 'attribute_points', attribute_points)
		ConnectionManager.rpc('update_status', int(name), 'level', level)

func as_dict():
	var dict = {}
	
	dict['id'] = id
	dict['name'] = creature_name
	dict['skin'] = sprite_index
	dict['global_position_x'] = global_position.x
	dict['global_position_y'] = global_position.y
	dict['life'] = life
	dict['mana'] = mana
	dict['level'] = level
	dict['strength'] = strength
	dict['constitution'] = constitution
	dict['dexterity'] = dexterity
	dict['agility'] = agility
	dict['intelligence'] = intelligence
	dict['willpower'] = willpower
	dict['perception'] = perception
	dict['wisdom'] = wisdom
	dict['job'] = job
	dict['experience'] = experience
	dict['attribute_points'] = attribute_points
	dict['inventory'] = inventory
	dict['helmet'] = _helmet.id if _helmet else -1
	dict['armor'] = _armor.id if _armor else -1
	dict['legs'] = _legs.id if _legs else -1
	dict['boots'] = _boots.id if _boots else -1
	dict['weapon1'] = _weapon1.id if _weapon1 else -1
	dict['weapon2'] = _weapon2.id if _weapon2 else -1
	dict['ring1'] = _ring1.id if _ring1 else -1
	dict['ring2'] = _ring2.id if _ring2 else -1
	
	return dict

func set_equipment(equipment_name : String, item_info : Dictionary):
	print('**',equipment_name, '\n', Item.new().dict_to(item_info))
	set(equipment_name, Item.new().dict_to(item_info))

func set_inventory(item_list : Array):
	inventory = item_list
