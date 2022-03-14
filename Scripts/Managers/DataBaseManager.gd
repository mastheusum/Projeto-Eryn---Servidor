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
	var account_columns : PoolStringArray = [
		"id INTEGER PRIMARY KEY NOT NULL",
		"username text NOT NULL UNIQUE",
		"password text NOT NULL"
		]
	
	var character_columns : PoolStringArray = [
			"id INTEGER PRIMARY KEY NOT NULL",
			"name TEXT NOT NULL UNIQUE",
			"global_position_x INTEGER NOT NULL",
			"global_position_y INTEGER NOT NULL",
			"life INTEGER NOT NULL",
			"mana INTEGER NOT NULL",
			"level INTEGER NOT NULL",
			"experience INTEGER NOT NULL",
			"attribute_points INTEGER NOT NULL",
			"strength INTEGER NOT NULL",
			"constitution INTEGER NOT NULL",
			"dexterity INTEGER NOT NULL",
			"agility INTEGER NOT NULL",
			"intelligence INTEGER NOT NULL",
			"willpower INTEGER NOT NULL",
			"perception INTEGER NOT NULL",
			"wisdom INTEGER NOT NULL",
			"job INTEGER NOT NULL",
			"skin INTEGER NOT NULL",
			"helmet INTEGER NOT NULL",
			"armor INTEGER NOT NULL",
			"legs INTEGER NOT NULL",
			"boots INTEGER NOT NULL",
			"weapon1 INTEGER NOT NULL",
			"weapon2 INTEGER NOT NULL",
			"ring1 INTEGER NOT NULL",
			"ring2 INTEGER NOT NULL",
			"account_id INTEGER NOT NULL",
			"FOREIGN KEY (account_id) REFERENCES account(id)"
		]
	
	var item_columns : PoolStringArray = [
		"id INTEGER PRIMARY KEY NOT NULL",
		"item_name TEXT NOT NULL UNIQUE",
		"texture_path TEXT NOT NULL",
		"type INTEGER NOT NULL",
		"attack INTEGER NOT NULL",
		"attack_range INTEGER NOT NULL",
		"defense INTEGER NOT NULL",
		"critical INTEGER NOT NULL",
		"two_handed INTEGER NOT NULL"
		]
	
	var inventory_columns : PoolStringArray = [
		"character_id INTEGER NOT NULL",
		"item_id INTEGER NOT NULL",
		"amount INTEGER NOT NULL",
		"FOREIGN KEY (character_id) REFERENCES character(id)",
		"FOREIGN KEY (item_id) REFERENCES item(id)",
		"PRIMARY KEY (character_id, item_id)"
		]
	db.open_db()
	
#	db.drop_table("inventory")
#	db.drop_table("item")
#	db.drop_table("character")
#	db.drop_table("account")
	
	db.query("CREATE TABLE IF NOT EXISTS account ("+account_columns.join(',')+");")
	db.query("CREATE TABLE IF NOT EXISTS character ("+character_columns.join(',')+");")
	db.query("CREATE TABLE IF NOT EXISTS item ("+item_columns.join(',')+");")
	db.query("CREATE TABLE IF NOT EXISTS inventory ("+inventory_columns.join(',')+");")
	
	db.close_db()

func seed_itens():
	db.open_db()
	var columns : PoolStringArray = [
		"id",
		"item_name",
		"texture_path",
		"type",
		"attack",
		"attack_range",
		"defense",
		"critical",
		"two_handed"
	]
	var bow : PoolStringArray = [
		'1',
		'"Bow"',
		'"res://Sprites/Weapon Icons/Bow01.png"',
		'4',
		'5',
		'400',
		'0',
		'25',
		'1'
	]
	var sword : PoolStringArray = [
		'2',
		'"Sword"',
		'"res://Sprites/Weapon Icons/Sword01.png"',
		'4',
		'5',
		'100',
		'5',
		'10',
		'0'
	]
	db.query('INSERT INTO item('+columns.join(',')+') VALUES ('+bow.join(',')+');')
	db.query('INSERT INTO item('+columns.join(',')+') VALUES ('+sword.join(',')+');')
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
		
		var columns : PoolStringArray = [
			"id",
			"name",
			"skin",
			"global_position_x",
			"global_position_y",
			"life",
			"mana",
			"level",
			"experience",
			"attribute_points",
			"strength",
			"constitution",
			"dexterity",
			"agility",
			"intelligence",
			"willpower",
			"perception",
			"wisdom",
			"job",
			"account_id",
			"helmet",
			"armor",
			"legs",
			"boots",
			"weapon1",
			"weapon2",
			"ring1",
			"ring2",
		]
		var values : PoolStringArray = [
			str(id + 1),
			'"'+character.creature_name+'"',
			str(character.sprite_index),
			str(character.global_position.x),
			str(character.global_position.y),
			str(character.life),
			str(character.mana),
			str(character.level),
			str(character.experience),
			str(character.attribute_points),
			str(character.strength),
			str(character.constitution),
			str(character.dexterity),
			str(character.agility),
			str(character.intelligence),
			str(character.willpower),
			str(character.perception),
			str(character.wisdom),
			str(character.job),
			str(account_id),
			str(-1),
			str(-1),
			str(-1),
			str(-1),
			str(-1),
			str(-1),
			str(-1),
			str(-1),
		]
		db.query("INSERT INTO character(" + columns.join(',') + ") VALUES(" + values.join(',') + ");")
		err = db.error_message
		
		db.close_db()
	return err

func read_character(character_id : int) -> Array:
	var character : Array = []
	db.open_db()
	db.query("SELECT * FROM character WHERE id = "+str(character_id)+" LIMIT 1;")
	character = db.query_result.duplicate()
	
	db.query('SELECT * FROM item WHERE id = '+str(character[0]['helmet'])+' LIMIT 1;')
	character[0]['helmet'] = db.query_result[0] if not db.query_result.empty() else {}
	
	db.query('SELECT * FROM item WHERE id = '+str(character[0]['armor'])+' LIMIT 1;')
	character[0]['armor'] = db.query_result[0] if not db.query_result.empty() else {}
	
	db.query('SELECT * FROM item WHERE id = '+str(character[0]['legs'])+' LIMIT 1;')
	character[0]['legs'] = db.query_result[0] if not db.query_result.empty() else {}
	
	db.query('SELECT * FROM item WHERE id = '+str(character[0]['boots'])+' LIMIT 1;')
	character[0]['boots'] = db.query_result[0] if not db.query_result.empty() else {}
	
	db.query('SELECT * FROM item WHERE id = '+str(character[0]['weapon1'])+' LIMIT 1;')
	character[0]['weapon1'] = db.query_result[0] if not db.query_result.empty() else {}
	
	db.query('SELECT * FROM item WHERE id = '+str(character[0]['weapon2'])+' LIMIT 1;')
	character[0]['weapon2'] = db.query_result[0] if not db.query_result.empty() else {}
	
	db.query('SELECT * FROM item WHERE id = '+str(character[0]['ring1'])+' LIMIT 1;')
	character[0]['ring1'] = db.query_result[0] if not db.query_result.empty() else {}
	
	db.query('SELECT * FROM item WHERE id = '+str(character[0]['ring2'])+' LIMIT 1;')
	character[0]['ring2'] = db.query_result[0] if not db.query_result.empty() else {}
	
	db.query("SELECT item.*, inventory.amount FROM item JOIN inventory on item.id = inventory.item_id WHERE inventory.character_id = "+str(character_id)+";")
	character[0]['inventory'] = db.query_result
	db.close_db()
	
	return character

func update_character(character : Character) -> String:
	var set : PoolStringArray = [
		"skin = " + str(character.sprite_index),
		"life = " + str(character.life),
		"mana = " + str(character.mana),
		"level = " + str(character.level),
		"experience = " + str(character.experience),
		"attribute_points = " + str(character.attribute_points),
		"strength = " + str(character.strength),
		"constitution = " + str(character.constitution),
		"dexterity = " + str(character.dexterity),
		"agility = " + str(character.agility),
		"intelligence = " + str(character.intelligence),
		"willpower = " + str(character.willpower),
		"perception = " + str(character.perception),
		"wisdom = " + str(character.wisdom),
		"job = " + str(character.job),
		"global_position_x = " + str(character.global_position.x),
		"global_position_y = " + str(character.global_position.y),
		"weapon1 = " + str(-1 if character._weapon1 else character._weapon1.id),
		"weapon2 = " + str(-1 if character._weapon2 else character._weapon2.id),
		"ring1 = " + str(-1 if character._ring1 else character._ring1.id),
		"ring2 = " + str(-1 if character._ring2 else character._ring2.id),
		"helmet = " + str(-1 if character._helmet else character._helmet.id),
		"armor = " + str(-1 if character._armor else character._armor.id),
		"legs = " + str(-1 if character._legs else character._legs.id),
		"boots = " + str(-1 if character._boots else character._boots.id)
	]
	var err : String = ""
	
	db.open_db()
	
	db.query("UPDATE character SET " + set.join(',') + " WHERE id = " + str(character.id)+";")
	err += " " + db.error_message
	
	db.query('DELETE FROM inventory WHERE character_id = "'+str(character.id)+'";')
	err += " " + db.error_message
	
	for slot in character.inventory:
		db.query('INSERT INTO inventory(character_id, item_id, amount) VALUES ('+str(character.id)+','+str(slot.item.id)+','+str(slot.amount)+');')
		err += " " + db.error_message
	db.close_db()
	return err

func create_account(account : Account):
	db.open_db()
	
	db.query("SELECT (id) FROM account ORDER BY id DESC LIMIT 1;")
	var id = db.query_result[0]['id'] if not db.query_result.empty() else 0
	
	var err = OK
	
	var columns : PoolStringArray = [
		"id",
		"username",
		"password"
	]
	var values : PoolStringArray = [
		str(id + 1),
		"'"+ str(account.username) +"'",
		"'"+str(account.password)+"'"
	]
	
	db.query("INSERT INTO account("+columns.join(',')+") VALUES ("+values.join(',')+");")
	
	err = db.error_message
	
	db.close_db()
	return err

