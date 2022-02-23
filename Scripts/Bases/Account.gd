extends Object

class_name Account

var account_id : int
var username : String
var password : String
var logged_in : bool

func class_dic():
	var dic = Dictionary()
	dic['id'] = {
		'data_type' : 'int',
		'primary_key' : true,
		'not_null' : true
	}
	dic['username'] = {
		'data_type' : 'char(30)',
		'unique' : true,
		'not_null' : true
	}
	dic['password'] = {
		'data_type' : 'char(30)',
		'not_null' : true
	}
	dic['logged_in'] = {
		'data_type' : 'int',
		'not_null' : true
	}
	return dic
