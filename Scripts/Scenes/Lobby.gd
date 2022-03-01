extends Node2D

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
#	$CanvasLayer/ResultTesteDB.text = str( result )
