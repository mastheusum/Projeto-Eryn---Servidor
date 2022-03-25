extends Area2D

class_name MonsterAreaLimit

var monster_dict = {}
export var unique_area_name : String = ""
export var db_creature_id : int = 0

func _ready():
	name = unique_area_name
	
	if db_creature_id > 0:
		monster_dict = DBManager.read_monster(db_creature_id)[0]
		print(monster_dict)
		start_spawner()
	print('---->> ',name)

func _on_AreaLimit_body_entered(body : Node):
	if body.is_in_group('Characters'):
		$Monster.set_new_gateway( int(body.name) )
		if $Monster.visible:
			print('->>', $Monster.as_dict())
			ConnectionManager.rpc_id(int(body.name), 'create_monster', $Monster.as_dict())

func _on_AreaLimit_body_exited(body : Node):
	if body.is_in_group('Characters'):
		$Monster.remove_gateway( int(body.name) )
		ConnectionManager.rpc_id(int(body.name), 'destroy_monster', name)
	elif get_child_count() > 2:
		if body == $Monster:
			$Monster.position = Vector2.ZERO

func _spawn_monster():
	randomize()
	$Monster.set_from_dict(monster_dict)
	$Monster.position = Vector2(-50 + randi() % 100, -50 + randi() % 100)
	$Monster.show()
	print('-> ' ,$Monster.gateways_list, ' - ', $Monster.global_position)
	for element in $Monster.gateways_list:
		ConnectionManager.rpc_id(int(element), 'create_monster', $Monster.as_dict())

func start_spawner():
	if not $Monster.visible:
		$Spawner.start(2)

func get_monster():
	if $Monster.visible:
		return $Monster
	return null
