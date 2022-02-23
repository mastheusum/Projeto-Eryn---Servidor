extends Creature

class_name NoPlayableCharacter

func class_dic():
	var dic = {}
	dic['creature_id'] = {
		'data_type' : 'int',
		'primary_key' : true,
		'not_null' : true
	}
	dic['creature_name'] = {
		'data_type' : 'char(30)',
		'not_null' : true
	}
	dic['creature_position_x'] = {
		'data_type' : 'int',
		'not_null' : true
	}
	dic['creature_position_y'] = {
		'data_type' : 'int',
		'not_null' : true
	}
	return dic

func send_message(message : String):
	pass
