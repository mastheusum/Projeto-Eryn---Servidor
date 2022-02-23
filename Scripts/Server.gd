extends Node2D

var player_instance = preload("res://Instantiable/PlayerInstance.tscn")
var game_scene = preload("res://Scene/Game.tscn")

var peer = null

var valid_tokens = []

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_peer_disconnected")
	
	DBManager.create_tables()

func start_server():
	$"Start Server".visible = false
	$"Control Server".visible = true
	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	peer.create_server( int($"Start Server/Port".text), int($"Start Server/Max Players".text) )
	
	get_tree().network_peer = null
	get_tree().network_peer = peer
	
	print("-- Server Online --")
	
	var game = game_scene.instance()
	get_node("/root").add_child(game)

func shutdown_server():
	get_tree().network_peer = null
	$"Start Server".visible = true
	$"Control Server".visible = false
	get_node("/root/Game").queue_free()
	print("** Server Offline **")

func _on_peer_connected(gateway_id):
	print(">> " + str(gateway_id) )
	pass

func _on_peer_disconnected(gateway_id):
	print("<< " + str(gateway_id) )
	pass

func create_player(character_id : int):
	var player = player_instance.instance()
	player.name = str(character_id)
	player.global_position = Vector2(randi() % 1024, randi() % 600)
	get_node("/root/Game/PlayerList").add_child(player)
	rpc("create_character", character_id, player.global_position)
	create_player_proxy(character_id)

func destroy_player(character_id):
	var player = get_node("/root/Game/PlayerList/"+ str(character_id))
	if player:
		player.queue_free()

func create_player_proxy(gateway_id):
	for player in get_node('/root/Game/PlayerList').get_children():
		rpc_id(gateway_id, "create_character", int(player.name), player.global_position)
		rpc_id(gateway_id, "set_character_name", int(player.name), player.get_node("Name").text)
		pass

# When a new Client connect to Server the Client will start login process
func start_client(gateway_id : int):
	rpc_id(gateway_id, "prepare_login")

remote func prepare_login():
	pass

# After client starts the login process it need authenticatee your account
# the result is false if it can not authenticate 
# or true + authenticate_token + the character list if it can
remote func authenticate_account(username : String, password : String):
	var token = null
	var result
	var gateway_id = get_tree().get_rpc_sender_id()
	
	var select_condition = "username = " + username
	var selected_row = DBManager.db.select_rows(
		"account", 
		select_condition, 
		['id', 'username', 'password']
		)[0]
	
	# the query condition return only on
	if not selected_row.has('username'):
		result = false
	# the client will send password hashed, so use sha256_text() is not necessary
	elif not selected_row['password'] == password:
		result = false
	else:
		randomize()
		var random_num = randi()
		var timestamp = str( OS.get_unix_time() )
		var hashed = str( random_num ).sha256_text()
		result = true
		token = hashed + timestamp
		# validates a token until the account signed out
		valid_tokens.append(token)
	rpc_id(
		gateway_id, "authentication_result", result, token,
		# select all characters in account
		DBManager.db.select_rows(
			"character", "account_id = " + str(selected_row['id']), ['id', 'creature_name'] 
			)
	)

remote func authentication_result(result:bool, tokenn:String, character_lis:Array):
	pass

# After show the character list the client will select a character
# 
# the character will be created here
remote func character_select(character_id : int, token : String):
	var gateway_id = get_tree().get_rpc_sender_id()
	if valid_tokens.has(token):
		# need a remake to create a character from database
		# the data of character will be parameters
		create_player(gateway_id)
	else:
		rpc_id(gateway_id, "unable_character_select")

remote func unable_character_select():
	pass

remote func create_character(gateway_id, pos):
	print(gateway_id)

remote func set_character_name(gateway_id : int, character_name):
	var player = get_node("/root/Game/PlayerList/"+ str(gateway_id))
	if player:
		player.get_node("Name").text = character_name
		for p in get_node('/root/Game/PlayerList').get_children():
			rpc_id(int(p.name), "set_character_name", gateway_id, character_name)

remote func set_charater_position(character_position : Vector2, character_direction : Vector2):
	var gateway_id = get_tree().get_rpc_sender_id()
	var player = get_node("/root/Game/PlayerList/"+ str(gateway_id))
	if player:
		player.global_position = character_position

