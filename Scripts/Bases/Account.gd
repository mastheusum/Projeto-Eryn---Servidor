extends Object

class_name Account

var account_id : int
var username : String
var password : String

func class_dic():
	var dic = Dictionary()
	dic['id'] = {
		'data_type' : 'int',
		'primary_key' : true,
		'not_null' : true
	}
	dic['username'] = {
		'data_type' : 'text',
		'not_null' : true,
		'unique' : true
	}
	dic['password'] = {
		'data_type' : 'text',
		'not_null' : true
	}
	return dic

func to_dict():
	var dict : Dictionary = {}
	dict['id'] = account_id
	dict['username'] = username
	dict['password'] = password
	return dict

func set_from_dict(dict : Dictionary):
	
	account_id = dict['id']
	username = dict['username']
	password = dict['password']
	
	return self
