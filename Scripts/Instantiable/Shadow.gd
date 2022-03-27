extends Monster

export var monster_name : String = ''

func _ready():
	set_from_dict(MonsterPreload.monster_data[monster_name.to_lower()])

func _behaviour(delta):
	if (not gateways_list.empty()) and visible:
		if search_range_list.empty():
			if $IDLE.is_stopped():
				randomize()
				_dir = Vector2(rand_range(-10, 10), rand_range(-10, 10)).normalized()
				$IDLE.start(1)
			else:
				move_and_collide(_dir * _move_speed * delta / 2)
		else:
			_dir = (search_range_list[0].global_position - global_position).normalized()
			var distance = search_range_list[0].global_position.distance_to(self.global_position)
			attack(search_range_list[0], distance)
			if distance > 64:
				move_and_collide(_dir * _move_speed * delta)
		for element in gateways_list:
			ConnectionManager.rpc_id(int(element), 'set_monster_position', get_parent().name, global_position, _dir)

func attack(target : KinematicBody2D, distance : float):
	if not $Attack.time_left > 0:
		var max_distance = 0
		var power = strength
		var critical = dexterity
		if _weapon1.id > 0:
			power += _weapon1.attack
			critical += _weapon1.critical
			max_distance = _weapon1.attack_range
		if _weapon2.id > 0:
			power += _weapon2.attack
			critical += _weapon2.critical
			if _weapon2.attack_range > max_distance:
				max_distance = _weapon2.attack_range
		randomize()
		power *= 1.5 if randi() % 100 < critical else 1
		if distance <= max_distance:
			ConnectionManager.rpc_id(int(target.name), 'attack_character', power, 1)
			$Attack.start(1.5)
