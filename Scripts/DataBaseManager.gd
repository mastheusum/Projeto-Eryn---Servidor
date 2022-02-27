extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db

var db_location = "res://DATA"
var db_name = "eryn-development"

func _ready():
	db = SQLite.new()
	db.path = db_location + "/" + db_name
	db.verbose_mode = true
	db.foreign_keys = true
	
	create_tables()

func create_tables():
	db.open_db()
	
	db.drop_table("account")
	db.drop_table("character")
	
#	db.create_table("account", Account.new().class_dic())
	db.query("CREATE TABLE IF NOT EXISTS character (id INTEGER PRIMARY KEY NOT NULL,name text NOT NULL UNIQUE,global_position_x INTEGER NOT NULL,global_position_y INTEGER NOT NULL,max_life INTEGER NOT NULL,life INTEGER NOT NULL,max_mana INTEGER NOT NULL,mana INTEGER NOT NULL,level INTEGER NOT NULL,experience INTEGER NOT NULL,account_id INTEGER NOT NULL, FOREIGN KEY (account_id) REFERENCES account(id));")
	db.query("CREATE TABLE IF NOT EXISTS account (id INTEGER PRIMARY KEY NOT NULL,username text NOT NULL UNIQUE,password text NOT NULL);")
	
	db.close_db()
	pass

func teste_insert():
	db.open_db()
#	db.insert_rows(
#		"account", [
#			{'id':1, 'username':'victor', 'password':'123456'.sha256_text()},
#			{'id':3, 'username':'vi', 'password':'abcdef'.sha256_text()},
#			{'id':2, 'username':'pedro', 'password':'654321'.sha256_text()}
#		]
#	)
	
#	db.insert_rows(
#		"character", [
#			{
#				'id': 1,
#				'name':'Victor',
#				'global_position_x':0,
#				'global_position_y':0,
#				'max_life':100,
#				'life':75,
#				'max_mana':50,
#				'mana':0,
#				'level':1,
#				'experience':0,
#				'account_id': 1
#			},
##			{
##				'id': 2,
##				'name':'Matheus',
##				'global_position_x':0,
##				'global_position_y':0,
##				'max_life':8753,
##				'life':5700,
##				'max_mana':4000,
##				'mana':328,
##				'level':100,
##				'experience':999,
##				'account_id': 1
##			},
##			{
##				'id': 3,
##				'name':'Pedro',
##				'global_position_x':0,
##				'global_position_y':0,
##				'max_life':100,
##				'life':75,
##				'max_mana':50,
##				'mana':0,
##				'level':1,
##				'experience':0,
##				'account_id': 2
##			},
##			{
##				'id': 4,
##				'name':'Henrique',
##				'global_position_x':0,
##				'global_position_y':0,
##				'max_life':8753,
##				'life':5700,
##				'max_mana':4000,
##				'mana':328,
##				'level':100,
##				'experience':999,
##				'account_id': 2
##			},
#		]
#	)
	
	var select_condition = ""
	var selected_array : Array = db.select_rows(
		"character", select_condition,
		['*']
	)
	db.close_db()
	
#	var obj = Character.new()
#	obj.creature_name = "Victor"
#	obj.global_position.x = 0
#	obj.global_position.y = 0
#	obj.max_life = 100
#	obj.life = 75
#	obj.max_mana = 50
#	obj.mana = 0
#	obj.level = 1
#	obj.experience = 0
#	create_character(1, obj)
	
	return selected_array

func authenticate_account(username : String, password : String) -> int:
	var result
	var query_result : Array
	db.open_db()
	db.query('SELECT * FROM account WHERE username = "'+username+'";')
	query_result = db.query_result
	db.close_db()
	
	if query_result.empty():
		result = false
	elif query_result[0]['password'] == password:
		result = true

	if result:
		return query_result[0]['id']
	else:
		return -1

func get_account_characters(account_id : int) -> Array:
	var character_list : Array = []
	
	db.open_db()
	db.query('SELECT id, name, level FROM character WHERE account_id = ' + str(account_id) + ';')
	character_list = db.query_result
	db.close_db()
	print(character_list)
	
	return character_list

func create_character(account_id : int, character : Character):
	print("*****"+str(account_id))
	var err = OK
	if account_id < 1:
		err = 1
		return err
	db.open_db()
	
	db.query("SELECT (id) FROM character ORDER BY id DESC LIMIT 1;");
	var id = db.query_result[0]['id'] if not db.query_result.empty() else 0
	var colluns : PoolStringArray = [
		"id",
		"name",
		"global_position_x",
		"global_position_y",
		"max_life",
		"life",
		"max_mana",
		"mana",
		"level",
		"experience",
		"account_id"
	]
	var values : PoolStringArray = [
		str(id + 1),
		'"'+character.creature_name+'"',
		str(character.global_position.x),
		str(character.global_position.y),
		str(character.max_life),
		str(character.life),
		str(character.max_mana),
		str(character.mana),
		str(character.level),
		str(character.experience),
		str(account_id)
	]
	print("INSERT INTO character(" + colluns.join(',') + ") VALUES(" + values.join(',') + ");")
	db.query("INSERT INTO character(" + colluns.join(',') + ") VALUES(" + values.join(',') + ");")
	
	if 'UNIQUE constraint failed' in db.error_message:
		err = 2 
	db.close_db()
	return err

func read_character(character_id : int):
	var char_dict
	db.open_db()
	db.query("SELECT * FROM character WHERE id = "+str(character_id)+" LIMIT 1;")
	char_dict = db.query_result[0]
	db.close_db()
	var character = Character.new()
	character.id = char_dict['id']
	character.creature_name = char_dict['name']
	character.global_position.x = char_dict['global_position_x']
	character.global_position.y = char_dict['global_position_y']
	character.max_life = char_dict['max_life']
	character.life = char_dict['life']
	character.max_mana = char_dict['max_mana']
	character.mana = char_dict['mana']
	character.level = char_dict['level']
	character.experience = char_dict['experience']
	
	return character

func update_character(character : Character):
	var set : PoolStringArray = [
		"max_life = " + str(character.max_life),
		"life = " + str(character.life),
		"max_mana = " + str(character.max_mana),
		"mana = " + str(character.mana),
		"level = " + str(character.level),
		"experience = " + str(character.experience),
		"global_position_x = " + str(character.global_position.x),
		"global_position_y = " + str(character.global_position.y)
	]
	db.open_db()
	db.query("UPDATE character SET " + set.join(',') + " WHERE id = " + str(character.id)+";")
	db.close_db()
	return db.error_message

func create_account(account : Account):
	var err = OK
	db.open_db()
	db.query("SELECT (id) FROM account ORDER BY id DESC LIMIT 1;")
	var id = db.query_result[0]['id'] if not db.query_result.empty() else 0
	db.query("INSERT INTO account(id, username, password) VALUES ("+str(id+1)+",'"+str(account.username)+"','"+str(account.password)+"');")
	print(db.error_message)
	if 'UNIQUE constraint failed' in db.error_message:
		err = 2
	db.close_db()
	return err

