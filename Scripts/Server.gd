extends Node2D

var player_instance = preload("res://Instantiable/PlayerInstance.tscn")
var game_scene = preload("res://Scene/Game.tscn")

var peer = null

func start_server():
	$"Start Server".visible = false
	$"Control Server".visible = true
	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	peer.create_server( int($"Start Server/Port".text), int($"Start Server/Max Players".text) )
	
	get_tree().network_peer = null
	get_tree().network_peer = peer
	
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	print("-- Server Online --")
	
	var game = game_scene.instance()
	get_node("/root").add_child(game)

func shutdown_server():
	get_tree().network_peer = null
	$"Start Server".visible = true
	$"Control Server".visible = false
	get_node("/root/Game").queue_free()
	print("** Server Offline **")

func _on_player_connected(id):
	print(">> " + str(id) )
	create_player(id)
	pass

func _on_player_disconnected(id):
	print("<< " + str(id) )
	destroy_player(id)
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

func create_player_proxy(id):
	for player in get_node('/root/Game/PlayerList').get_children():
		rpc_id(id, "create_character", int(player.name), player.global_position)
		rpc_id(id, "set_character_name", int(player.name), player.get_node("Name").text)
		pass

remote func create_character(id, pos):
	print(id)

remote func set_character_name(character_name):
	var id = get_tree().get_rpc_sender_id()
	var player = get_node("/root/Game/PlayerList/"+ str(id))
	if player:
		player.get_node("Name").text = character_name
		for p in get_node('/root/Game/PlayerList').get_children():
			rpc_id(int(p.name), "set_character_name", id, character_name)

remote func set_charater_position(character_position, character_direction):
	var id = get_tree().get_rpc_sender_id()
	var player = get_node("/root/Game/PlayerList/"+ str(id))
	if player:
		player.global_positionn = character_position
