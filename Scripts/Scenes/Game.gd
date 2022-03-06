extends Node2D

var character_node = preload("res://Instantiable/Character.tscn")

func add_character_from_game(gateway_id : int, character : Dictionary):
	var player = character_node.instance()
	
	player.name = str(gateway_id)
	player.set_network_master(gateway_id)
	player.id = character['id']
	player.sprite_index = character['skin']
	player.creature_name = character['name']
	player.experience = character['experience']
	player.global_position = Vector2(character['global_position_x'],character['global_position_y'])
	player.max_life = character['max_life']
	player.life = character['life']
	player.max_mana = character['max_mana']
	player.mana = character['mana']
	player.level = character['level']
	
	$PlayerList.call_deferred( 'add_child', player )

func remove_character_from_game(gateway_id : int):
	var character = $PlayerList.get_node( str( gateway_id ) )
	if character:
		character.queue_free()
