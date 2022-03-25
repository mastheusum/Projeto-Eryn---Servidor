extends Node2D

var character_node = preload("res://Instantiable/Character.tscn")

func add_character_from_game(gateway_id : int, character : Dictionary):
	var player = character_node.instance()
	
	player.name = str(gateway_id)
	player = (player as Character).set_from_dict( character )
	
	$PlayerList.call_deferred( 'add_child', player )

func remove_character_from_game(gateway_id : int):
	var character = $PlayerList.get_node( str( gateway_id ) )
	if character:
		character.queue_free()

