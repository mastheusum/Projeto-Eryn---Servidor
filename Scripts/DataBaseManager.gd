extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db

var db_location = "res://DATA"
var db_name = "eryn-development"

func _ready():
	db = SQLite.new()
	db.path = db_location + "/" + db_name
	db.verbose_mode = true

func create_tables():
	db.open_db()
	
	db.drop_table("account")
	db.drop_table("character")
	
	db.create_table("account", Account.new().class_dic())
	db.create_table("character", Character.new().class_dic())
	
	db.insert_rows(
		"account", [
			{'id':1,'username':'victor', 'password':'123456'.sha256_text(), 'logged_in':0},
			{'id':3,'username':'vi', 'password':'abcdef'.sha256_text(), 'logged_in':0},
			{'id':2,'username':'pedro', 'password':'654321'.sha256_text(), 'logged_in':0}
		]
	)
	
	db.insert_rows(
		"character", [
			{
				'id': 1,
				'creature_name':'Victor',
				'creature_position_x':0,
				'creature_position_y':0,
				'max_life':100,
				'life':75,
				'max_mana':50,
				'mana':0,
				'level':1,
				'experience':0,
				'account_id': 1
			},
			{
				'id': 2,
				'creature_name':'Matheus',
				'creature_position_x':0,
				'creature_position_y':0,
				'max_life':8753,
				'life':5700,
				'max_mana':4000,
				'mana':328,
				'level':100,
				'experience':999,
				'account_id': 1
			},
			{
				'id': 3,
				'creature_name':'Pedro',
				'creature_position_x':0,
				'creature_position_y':0,
				'max_life':100,
				'life':75,
				'max_mana':50,
				'mana':0,
				'level':1,
				'experience':0,
				'account_id': 2
			},
			{
				'id': 4,
				'creature_name':'Henrique',
				'creature_position_x':0,
				'creature_position_y':0,
				'max_life':8753,
				'life':5700,
				'max_mana':4000,
				'mana':328,
				'level':100,
				'experience':999,
				'account_id': 2
			},
		]
	)
	
	var select_condition = "username = 'victor'"
	var selected_array : Array = db.select_rows(
		"account", select_condition,
		['id', 'password']
	)
	
	get_node('/root/Lobby/Label').text = str(len(selected_array) )
	
	db.close_db()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
