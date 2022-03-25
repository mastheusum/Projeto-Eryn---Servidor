extends Node2D

func _ready():
	$"CanvasLayer/DB Comannds/SEED Itens".emit_signal("pressed")
	$"CanvasLayer/Start Server/StartServerBtn".emit_signal("pressed")

func _on_StartServerBtn_pressed():
	$"CanvasLayer/Start Server".visible = false
	$"CanvasLayer/Control Server".visible = true
	
	var port = int($"CanvasLayer/Start Server/Port".text)
	var max_players = int($"CanvasLayer/Start Server/Max Players".text)
	ConnectionManager.start_server(port, max_players)

func _on_ShutdownServerBtn_pressed():
	$"CanvasLayer/Start Server".visible = true
	$"CanvasLayer/Control Server".visible = false
	
	ConnectionManager.shutdown_server()

func _on_ButtonTesteDB_pressed():
	var result = DBManager.teste_insert()
