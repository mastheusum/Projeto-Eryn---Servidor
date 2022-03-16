extends Node

var game_node = preload("res://Scene/Game.tscn")

func _ready():
	var game = game_node.instance()
	get_node('/root').call_deferred( 'add_child', game )

# To sign in a character in Game:
# 1. GameManager will recover the character from DataBase
# 2. it will create a new character with add_character_from_game
# 3. it send this character to all conections via rpc
# 4. it send all other character to new character to sync
func create_character(character_id : int, gateway_owner : int):
	var character_info : Array = DBManager.read_character(character_id)
	if not character_info.empty():
		get_node("/root/Game").add_character_from_game(gateway_owner, character_info[0])
		var character_list : Dictionary = {}
		for child in get_node('/root/Game/PlayerList').get_children():
			if child.name != str(gateway_owner):
				character_list[child.name] = (child as Character).as_dict()
				print(character_list[child.name])
		ConnectionManager.rpc('response_sign_in', { str(gateway_owner) : character_info[0] })
		ConnectionManager.rpc_id(gateway_owner, 'response_sign_in', character_list)

func destroy_character(gateway_id):
	var character = get_node("/root/Game/PlayerList/"+str(gateway_id))
	if character:
		yield(DBManager.update_character(character as Character), 'completed')
		character.queue_free()
		ConnectionManager.rpc('response_sign_out', [gateway_id])

func get_character(gateway_id : int) -> KinematicBody2D:
	var list = get_node("/root/Game/PlayerList")
	var character = list.get_node(str(gateway_id))
	return character
