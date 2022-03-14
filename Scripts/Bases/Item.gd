extends TextureRect

class_name Item

enum Types {
	HELMET,
	ARMOR,
	LEGS,
	BOOTS,
	WEAPON,
	RING
}

var id : int
var item_name : String
var texture_path : String
var type : int
var attack : int
var attack_range : int
var defense : int
var critical : int
var two_handed : int

func as_dict():
	var dict = {}
	
	dict['id'] = id
	dict['name'] = item_name
	dict['texture_path'] = texture_path
	dict['type'] = type
	dict['attack'] = attack
	dict['attack_range'] = attack_range
	dict['defense'] = defense
	dict['critical'] = critical
	dict['two_handed'] = two_handed
	
	return dict

func dict_to(dict : Dictionary):
	if not dict.empty():
		id = dict['id']
		item_name = dict['item_name']
		texture_path = dict['texture_path']
		type = dict['type']
		attack = dict['attack']
		attack_range = dict['attack_range']
		defense = dict['defense']
		critical = dict['critical']
		two_handed = dict['two_handed']
		
		return self
	else:
		return null
