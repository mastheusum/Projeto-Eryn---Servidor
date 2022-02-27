extends Node2D

var player_instance = preload("res://Instantiable/PlayerInstance.tscn")
var game_scene = preload("res://Scene/Game.tscn")

var peer = null

var valid_tokens = []

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
	pass

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
		print( DBManager.read_character(character_id) )
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


# ----
# Game Play
# ----
remote func set_charater_position(character_position : Vector2, character_direction : Vector2):
	pass

# For a list of player in range of message the player will send the message
remote func send_message(message : String, gateway_list : Array):
	for gateway_id in gateway_list:
		rpc_id(gateway_id, 'receive_message', message)

remote func receive_message(messaage : String):
	pass
