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
	player.attribute_points = character['attribute_points']
	player.global_position = Vector2(character['global_position_x'],character['global_position_y'])
	player.level = character['level']
	player.strength = character['strength']
	player.constitution = character['constitution']
	player.dexterity = character['dexterity']
	player.agility = character['agility']
	player.intelligence = character['intelligence']
	player.willpower = character['willpower']
	player.perception = character['perception']
	player.wisdom = character['wisdom']
	player.max_life = 5 * player.constitution
	player.life = character['life']
	player.max_mana = 5 * player.intelligence
	player.mana = character['mana']
	player._helmet = Item.new().dict_to(character['helmet'])
	player._armor = Item.new().dict_to(character['armor'])
	player._legs = Item.new().dict_to(character['legs'])
	player._boots = Item.new().dict_to(character['boots'])
	player._weapon1 = Item.new().dict_to(character['weapon1'])
	player._weapon2 = Item.new().dict_to(character['weapon2'])
	player._ring1 = Item.new().dict_to(character['ring1'])
	player._ring2 = Item.new().dict_to(character['ring2'])
	player.inventory = character['inventory']
	
	$PlayerList.call_deferred( 'add_child', player )

func remove_character_from_game(gateway_id : int):
	var character = $PlayerList.get_node( str( gateway_id ) )
	if character:
		character.queue_free()
