extends PlayableCharacter

class_name Character

var account_id : int
var experience : int

func send_message(message : String):
	pass

func gain_experience(value : int):
	experience += value
	calculate_current_level()
	pass

# based on character's experience calculates his level
func calculate_current_level():
	if experience >= 1000:
		level += 1
		gain_experience( -1000 )

# need remake. This will recover a percent of max life over time
func recover_life():
	life = max_life

# need remake. This will recover a percent of max man over time
func recover_mana():
	mana = max_mana

func class_dic():
	var dic = {}
	dic['id'] = {
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
	dic['max_life'] = {
		'data_type' : 'int',
		'not_null' : true
	}
	dic['life'] = {
		'data_type' : 'int',
		'not_null' : true
	}
	dic['max_mana'] = {
		'data_type' : 'int',
		'not_null' : true
	}
	dic['mana'] = {
		'data_type' : 'int',
		'not_null' : true
	}
	dic['level'] = {
		'data_type' : 'int',
		'not_null' : true
	}
	dic['experience'] = {
		'data_type' : 'int',
		'not_null' : true
	}
	dic['account_id'] = {
		'data_type' : 'int',
		'foreign_key' : 'account.id',
		'not_null' : true
	}
	return dic
