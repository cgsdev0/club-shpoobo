extends Sprite2D

func interact(up, interactee):
	if !up:
		return
	if !multiplayer.is_server():
		return
	var let_the_bodies_hit_the_floor: Array = $CheckZone.get_overlapping_bodies()
	if let_the_bodies_hit_the_floor.size() < 2:
		return
	if !let_the_bodies_hit_the_floor.all(func(who): 
		if !is_instance_valid(who):
			return true
		return who.head_accessory == 12
		):
		return
	for who in let_the_bodies_hit_the_floor:
		who.teleport.rpc_id(who.get_parent().name.to_int(), %OuterSpace/Marker2D.global_position, true)
	
