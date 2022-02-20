extends Node2D

var character_name = ""
var max_life = 100
var life = 100

func _ready():
	$Name.text = character_name
