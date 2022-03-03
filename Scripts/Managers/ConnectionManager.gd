extends Node2D

var player_instance = preload("res://Instantiable/PlayerInstance.tscn")
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
	pass

# REQUESTS
remote func request_login(username : String, password : String):
	var gateway_id = get_tree().get_rpc_sender_id()
	var account_id = DBManager.authenticate_account(username, password)
	
	var token : String = ""
	
	if account_id != -1:
		randomize()
		var number = randi()
		var timestamp = OS.get_unix_time()
		token = str(number).sha256_text() + str(timestamp)
		
		valid_tokens[token] = account_id
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
			valid_tokens[token]
		)
		
	rpc_id(gateway_id, 'response_character_list', character_list)

remote func request_create_new_character(token : String, character_name : String):
	var gateway_id = get_tree().get_rpc_sender_id()
	
	var character = Character.new()
	character.creature_name = character_name
	character.global_position = Vector2.ZERO
	character.max_life = 100
	character.life = 75
	character.max_mana = 50
	character.mana = 25
	character.level = 1
	character.experience = 0
	
	var account_id = valid_tokens[token]
	
	var err = DBManager.create_character(account_id, character)
	
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

# ussed to update CharacterProxyes's life and mana 
remote func update_status(gateway_id : int, life : int, mana : int):
	if gateway_id != get_tree().get_network_unique_id() and gateway_id != 1:
		GameManager.get_character(gateway_id).update_status(life, mana)

