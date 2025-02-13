extends Sprite2D


func interact(up, interactee):
	if !up:
		return
	interactee.teleport($Marker2D.global_position)
