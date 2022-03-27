extends Node

var monster_data = {}

func _ready():
	var monster_list : Array = DBManager.read_all_monster()
	for monster in monster_list:
		monster_data[ monster['name'].to_lower() ] = monster
