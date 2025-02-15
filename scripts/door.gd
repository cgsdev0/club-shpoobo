extends Sprite2D


func interact(up, interactee):
	if !up:
		return
	interactee.get_child(0).teleport.rpc_id(interactee.name.to_int(), $Marker2D.global_position)
	
