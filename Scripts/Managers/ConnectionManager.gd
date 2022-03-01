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

# ---------------------
func create_player(gateway_id : int, character : Dictionary):
	pass

func destroy_player(gateway_id):
	pass

func create_player_proxy(gateway_id):
	pass

# ----
# Client Menu
# ----
remote func create_new_account(username : String, password : String):
	var gateway_id = get_tree().get_rpc_sender_id()
	if username != '' and password != '':
		var account = Account.new()
		account.username = username
		account.password = password
		var err = DBManager.create_account(account)
		rpc_id(gateway_id, 'result_new_account', err)
	pass

remote func result_new_account(err : int):
	pass

# After client starts the login process it need authenticate your account
# the result is false if it can not authenticate 
# or true + list of characters if it can authenticate
remote func authenticate_account(username : String, password : String):
	var token = ""
	var result = false
	
	var gateway_id = get_tree().get_rpc_sender_id()
	var account_id = DBManager.authenticate_account(username, password)
	
	if account_id != -1:
		result = true
		randomize()
		var number = randi()
		var timestamp = OS.get_unix_time()
		token = str(number).sha256_text() + str(timestamp)
		
		valid_tokens.append(token)
	
	rpc_id(gateway_id, 'authentication_result', result, account_id, token)

# Used by client to grant connection
remote func authentication_result(result : bool, account_id : int, token : String):
	pass

remote func sign_out(token : String):
	if valid_tokens.has(token):
		valid_tokens.erase(token)

remote func get_characters_list(account_id : int, token : String):
	var gateway_id = get_tree().get_rpc_sender_id()
	var character_list : Array = []
	if valid_tokens.has(token):
		character_list = DBManager.get_account_characters(account_id)
	rpc_id(gateway_id, 'set_characters_list', character_list)

remote func set_character_list(character_list : Array):
	pass

remote func character_selected(character_id : int, token : String):
	if valid_tokens.has(token):
		var character = DBManager.read_character(character_id)
		print(character)
		var id = get_tree().get_rpc_sender_id()
		GameManager.create_character(character, id)
		pass
	pass

remote func create_new_character(account_id : int, token : String, character : Dictionary):
	var gateway_id = get_tree().get_rpc_sender_id()
	if character.has('name') and valid_tokens.has(token):
		var obj = Character.new()
		obj.creature_name = character['name']
		obj.global_position.x = 0
		obj.global_position.y = 0
		obj.max_life = 100
		obj.life = 75
		obj.max_mana = 50
		obj.mana = 0
		obj.level = 1
		obj.experience = 0
		var err = DBManager.create_character(account_id, obj)
		rpc_id(gateway_id, 'result_new_character', err)

remote func result_new_character(error_code : int):
	pass

remote func enter_in_game(character : Character, gateway_owner : int):
	pass

remote func exit_from_game(gateway_id):
	GameManager.destroy_character(gateway_id)

# ----
# Game Play
# ----
remote func set_charater_position(character_position : Vector2, character_direction : Vector2):
	var gateway_id = get_tree().get_rpc_sender_id()
	var character = get_node('/root/Game/PlayerList').get_node( str(gateway_id) )
	if character:
		character.global_position = character_position
#		character._animate(character_direction, character_direction != Vector2.ZERO)

# For a list of player in range of message the player will send the message
remote func send_message(message : String, gateway_list : Array):
	for gateway_id in gateway_list:
		rpc_id(gateway_id, 'receive_message', message)

remote func receive_message(messaage : String):
	pass
