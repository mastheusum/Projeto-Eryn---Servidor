extends Node2D

var player_instance = preload("res://Instantiable/Character.tscn")
var game_scene = preload("res://Scene/Game.tscn")

var peer = null

var valid_tokens = {}

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")

func start_server(port:int, max_players:int):
	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	peer.create_server(port , max_players)
	
	get_tree().network_peer = null
	get_tree().network_peer = peer
	
	print("-- Server Online --")

func shutdown_server():
	get_tree().network_peer = null
	print("** Server Offline **")

func _on_peer_connected(gateway_id):
	print(">> " + str(gateway_id) )
	pass

func _on_peer_disconnected(gateway_id):
	print("<< " + str(gateway_id) )
	GameManager.destroy_character(gateway_id)
	for key in valid_tokens.keys():
		if valid_tokens[key]['gateway_id'] == gateway_id:
			valid_tokens.erase(key)
			break
	pass

# REQUESTS
remote func request_login(username : String, password : String):
	var gateway_id = get_tree().get_rpc_sender_id()
	var account_id = DBManager.authenticate_account(username, password)
	
	var token : String = ""
	
	for key in valid_tokens.keys():
		if valid_tokens[key]['account_id'] == account_id:
			account_id = -1
			break
	
	if account_id != -1:
		randomize()
		var number = randi()
		var timestamp = OS.get_unix_time()
		token = str(number).sha256_text() + str(timestamp)
		
		valid_tokens[token] = { 
			'account_id' : account_id, 
			'gateway_id' : gateway_id 
			}
	rpc_id(gateway_id, 'response_login', account_id, token)

remote func request_logout(token : String):
	var gateway_id = get_tree().get_rpc_sender_id()
	valid_tokens.erase(token)
	rpc_id(gateway_id, 'response_logout')

remote func request_new_account(username : String, password : String ):
	var gateway_id = get_tree().get_rpc_sender_id()
	
	var account = Account.new()
	account.username = username
	account.password = password
	
	var err = DBManager.create_account(account)
	print(err)
	rpc_id(gateway_id, 'response_new_account', err)

remote func request_character_list(token : String):
	var gateway_id = get_tree().get_rpc_sender_id()
	var character_list : Array = []
	
	if valid_tokens.has(token):
		character_list = DBManager.get_account_characters(
			valid_tokens[token]['account_id']
		)
		
	rpc_id(gateway_id, 'response_character_list', character_list)

remote func request_create_new_character(token : String, character : Dictionary):
	if valid_tokens.has(token):
		var gateway_id = get_tree().get_rpc_sender_id()
		
		var new_character = Character.new()
		new_character.creature_name = character["name"]
		new_character.sprite_index = character["skin"]
		new_character.job = character['job']
		new_character.global_position = Vector2.ZERO
		new_character.level = 1
		new_character.attribute_points = 5
		new_character.strength = 5
		new_character.constitution = 5
		new_character.dexterity = 5
		new_character.agility = 5
		new_character.intelligence = 5
		new_character.willpower = 5
		new_character.perception = 5
		new_character.wisdom = 5
		new_character.max_life = 5 * new_character.constitution
		new_character.life = int(new_character.max_life * 0.8)
		new_character.max_mana = 5 * new_character.intelligence
		new_character.mana = int(new_character.max_mana * 0.8)
		
		var account_id = valid_tokens[token]['account_id']
		
		var err = DBManager.create_character(account_id, new_character)
		
		rpc_id(gateway_id, 'response_create_new_character', err)

remote func request_sign_in_character(token : String, character_id : int):
	var gateway_id = get_tree().get_rpc_sender_id()
	if valid_tokens.has(token):
		GameManager.create_character(character_id, gateway_id)

remote func request_sign_out_character(token : String):
	var gateway_id = get_tree().get_rpc_sender_id()
	if valid_tokens.has(token):
		GameManager.destroy_character(gateway_id)

# RESPONSES
remote func response_login(account_id : int, token : String):
	pass

remote func response_logout():
	pass

remote func response_new_account( error : String ):
	pass

remote func response_character_list(character_list : Array):
	pass

remote func response_create_new_character(error : String):
	pass

remote func response_sign_in(character_list : Dictionary):
	pass

remote func response_sign_out(character_list : Array):
	pass

# ----
# Game Play
# ----
remote func set_charater_position(character_position : Vector2, character_direction : Vector2):
	var gateway_id = get_tree().get_rpc_sender_id()
	var character = get_node('/root/Game/PlayerList').get_node( str(gateway_id) )
	if character:
		character.global_position = character_position
#		character._animate(character_direction, character_direction != Vector2.ZERO)

remotesync func get_message(message : String):
	pass

# This function is called when player receive a damage
# then this damage is send to al another players connecteds
remotesync func get_status_alert(message : String, type : int):
	pass

# used by player to receive damage by other players
remote func attack_character(power : int, type : int):
	pass

remote func set_aggressor_list(aggressor_id : int):
	var gateway_id = get_tree().get_rpc_sender_id()
	(GameManager.get_character(gateway_id) as Character).set_aggressor(aggressor_id)

# ussed to update CharacterProxyes's life and mana 
remote func update_status(gateway_id : int, status : String, value : int):
	if gateway_id != 1:
		(GameManager.get_character(gateway_id) as Character).set_attribute(status, value)

remote func set_character_equipment(equipment : String, item : Dictionary):
	var gateway_id = get_tree().get_rpc_sender_id()
	(GameManager.get_character(gateway_id) as Character).set_equipment(equipment, item)

remote func set_character_inventory(equipment_list : Array):
	var gateway_id = get_tree().get_rpc_sender_id()
#	print("**"+ str(equipment_list))
	(GameManager.get_character(gateway_id) as Character).set_inventory(equipment_list)
