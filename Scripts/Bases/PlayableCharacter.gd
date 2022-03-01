extends Creature

class_name PlayableCharacter

var max_life : int
var life : int
var max_mana : int
var mana : int
var level : int
var attack_range : float

func _ready():
	$HUD/CharacterName.text = creature_name
	$HUD/LifeBar.max_value = max_life
	$HUD/LifeBar.value = life
	$HUD/ManaBar.max_value = max_mana
	$HUD/ManaBar.value = mana

func receive_damage(value : int):
	if life <= 0:
		_on_dead()
	pass

func attack(target_id : int, max_range : float, power : int):
	pass

func _on_dead():
	pass
