extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.go_to_space.connect(on_space)
	Global.die_in_space.connect(reset)

func on_space():
	Global.in_space = true
	Global.tv_enabled = false
	Global.current_tv = 1
	show()
	$AnimationPlayer.play("fly")
	await $AnimationPlayer.animation_finished
	hide()
	Global.tv_enabled = true
	
func reset():
	Global.in_space = false
	Global.current_tv = 0
	$AnimationPlayer.play("RESET")
