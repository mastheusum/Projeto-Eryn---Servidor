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
	
#	db.drop_table("account")
#	db.drop_table("character")
	
	db.query("CREATE TABLE IF NOT EXISTS account (id INTEGER PRIMARY KEY NOT NULL,username text NOT NULL UNIQUE,password text NOT NULL);")
	db.query("CREATE TABLE IF NOT EXISTS character (id INTEGER PRIMARY KEY NOT NULL,name text NOT NULL UNIQUE,global_position_x INTEGER NOT NULL,global_position_y INTEGER NOT NULL,max_life INTEGER NOT NULL,life INTEGER NOT NULL,max_mana INTEGER NOT NULL,mana INTEGER NOT NULL,level INTEGER NOT NULL,experience INTEGER NOT NULL, skin INTEGER NOT NULL, account_id INTEGER NOT NULL, FOREIGN KEY (account_id) REFERENCES account(id));")
	
	db.close_db()

func teste_insert():
	db.open_db()
	db.close_db()

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
	
	return character_list

func create_character(account_id : int, character : Character) -> String:
	var err = ""
	if account_id < 1:
		err = "Invalid Account ID."
	else:
		db.open_db()
		
		db.query("SELECT (id) FROM character ORDER BY id DESC LIMIT 1;");
		var id = db.query_result[0]['id'] if not db.query_result.empty() else 0
		
		var colluns : PoolStringArray = [
			"id",
			"name",
			"skin",
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
			str(character.sprite_index),
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
		db.query("INSERT INTO character(" + colluns.join(',') + ") VALUES(" + values.join(',') + ");")
		err = db.error_message
		
		db.close_db()
	return err

func read_character(character_id : int) -> Array:
	var character
	db.open_db()
	db.query("SELECT * FROM character WHERE id = "+str(character_id)+" LIMIT 1;")
	character = db.query_result
	db.close_db()
	
	return character

func update_character(character : Character) -> String:
	var set : PoolStringArray = [
		"skin = " + str(character.sprite_index),
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

	err = db.error_message
	
	db.close_db()
	return err

