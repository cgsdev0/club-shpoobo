extends CharacterBody2D

@export var speed = 182
@export var jump_speed = -990
@export var gravity = 3600
@export_range(0.0, 1.0) var friction = 0.5
@export_range(0.0 , 1.0) var acceleration = 0.5
@export var on_ground = false

@onready var input = $InputSync

@onready var start_position = position

func _enter_tree():
	$InputSync.set_multiplayer_authority(name.to_int())
	if name.to_int() != multiplayer.get_unique_id():
		collision_layer = 2
		$CameraTarget.queue_free()
	else:
		z_index = 2
		var cam = get_viewport().get_camera_2d()
		cam.reparent($CameraTarget)
		cam.position = Vector2.ZERO

var jumping = false

func update_texture(texture: Texture):
	var reference_frames: SpriteFrames = $Sprite2D.sprite_frames
	var updated_frames = SpriteFrames.new()
	
	for animation in reference_frames.get_animation_names():
		if animation != "default":
			updated_frames.add_animation(animation)
			updated_frames.set_animation_speed(animation, reference_frames.get_animation_speed(animation))
			updated_frames.set_animation_loop(animation, reference_frames.get_animation_loop(animation))
	
		for i in reference_frames.get_frame_count(animation):
			var updated_texture: AtlasTexture = reference_frames.get_frame_texture(animation, i).duplicate()
			updated_texture.atlas = texture
			updated_frames.add_frame(animation, updated_texture)

	updated_frames.remove_animation("default")

	$Sprite2D.sprite_frames = updated_frames
	
func _ready():
	# set_label("""shpoobo""")
	# update_texture(load("res://sprites/scpoobo_dog.png"))
	$ChatTimer.timeout.connect(hide_text)
	pass

func hide_text():
	$Label.hide()
func set_label(text):
	$ChatTimer.start(5.0)
	$Label.show()
	$Label.size.x = 132
	$Label.text = text
	var width = 0
	for i in $Label.get_total_character_count():
		width += $Label.get_character_bounds(i).size.x
	$Label.size.x = min(132, width + 12)
	$Label.position.x = -$Label.size.x / 2.0
	$Label.size.y = min(44, $Label.get_line_count() * 18 + 4)
	$Label.position.y = -26 - $Label.size.y
		
func _physics_process(delta):
	if multiplayer.is_server():
		_move(delta)

func _process(delta):
	if $Sprite2D.animation != "jump" || !$Sprite2D.is_playing():
		if input.move_input != 0.0:
			$Sprite2D.play("walk")
		else:
			$Sprite2D.play("idle")

@rpc("authority")
func respawn():
	position = start_position
		
func _move(delta):
	velocity.y += gravity * delta
	var dir = input.move_input
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)

	if dir < 0.0:
		$Sprite2D.flip_h = true
	elif dir > 0.0:
		$Sprite2D.flip_h = false
		
	move_and_slide()
	if jumping and is_on_floor():
		velocity.y = jump_speed
	on_ground = is_on_floor()
	jumping = false
