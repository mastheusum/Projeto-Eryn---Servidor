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
