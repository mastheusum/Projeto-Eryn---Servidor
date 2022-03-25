extends Creature

class_name PlayableCharacter

var max_life : int
var life : int
var max_mana : int
var mana : int
var level : int
var attack_range : float
var strength : int # physical damage
var constitution : int # max life
var dexterity : int # physical critical hit
var agility : int # attack speed
var intelligence : int # max mana
var willpower : int # resistance to crowd controls
var perception : int # magic critical hit
var wisdom : int # magic damage 

var aggressor_list : Array = []

func _ready():
	$HUD/CharacterName.text = creature_name
	$HUD/LifeBar.max_value = max_life
	$HUD/LifeBar.value = life
	$HUD/ManaBar.max_value = max_mana
	$HUD/ManaBar.value = mana
	
	(get_node('AggressorList') as Timer).connect('timeout', self, 'aggressor_timeout')

func set_aggressor(id : int):
	if not aggressor_list.has(id):
		aggressor_list.append(id)
		get_node('AggressorList').start(10)

func aggressor_timeout():
	aggressor_list = []

func set_max_life():
	self.max_life = 50 + 5 * constitution

func set_max_mana():
	self.max_mana = 15 + 5 * intelligence
