extends CharacterBody2D

@export var speed = 182
@export var jump_speed = -983
@export var gravity = 3600
@export_range(0.0, 1.0) var friction = 0.5
@export_range(0.0 , 1.0) var acceleration = 0.5
@export var on_ground = false

@export var player_hue = 0.0
@export var head_hue = 0.0
@export var head_accessory = 0
@export var player_skin = 0

@export var last_y = 180.0

@onready var input = $InputSync

@onready var start_position = position

var owned = false
func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var data = {
		"player_hue": player_hue,
		"head_hue": head_hue,
		"head_accessory": head_accessory,
		"player_skin": player_skin
	}
	# JSON provides a static method to serialized JSON string.
	var json_string = JSON.stringify(data)
	# Store the save dictionary as a new line in the save file.
	save_file.store_line(json_string)
		
func load_save():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		var data: Dictionary = json.data
		player_hue = data.get("player_hue", 0.0)
		head_hue = data.get("head_hue", 0.0)
		player_skin = data.get("player_skin", 0)
		head_accessory = data.get("head_accessory", 0)
		
func _enter_tree():
	set_multiplayer_authority(get_parent().name.to_int())
	if get_parent().name.to_int() != multiplayer.get_unique_id():
		z_index = 4
		$Label.z_index = 6
		$CameraTarget.queue_free()
	else:
		load_save()
		$AudioListener2D.current = true
		owned = true
		$Label.z_index = 3
		z_index = 5
		var cam = get_viewport().get_camera_2d()
		cam.reparent($CameraTarget)
		cam.position = Vector2.ZERO

func update_texture(what, texture: Texture, y_offset = 0):
	if !texture:
		what.hide()
		return
	else:
		what.show()
	var key = str(y_offset) + texture.resource_path
	if anim_cache.has(key):
		what.sprite_frames = anim_cache[key]
		return
	var reference_frames: SpriteFrames = what.sprite_frames
	var updated_frames = SpriteFrames.new()
	
	for animation in reference_frames.get_animation_names():
		if animation != "default":
			updated_frames.add_animation(animation)
			updated_frames.set_animation_speed(animation, reference_frames.get_animation_speed(animation))
			updated_frames.set_animation_loop(animation, reference_frames.get_animation_loop(animation))
	
		for i in reference_frames.get_frame_count(animation):
			var updated_texture: AtlasTexture = reference_frames.get_frame_texture(animation, i).duplicate()
			updated_texture.atlas = texture
			updated_texture.region.position.y = y_offset
			updated_frames.add_frame(animation, updated_texture)

	updated_frames.remove_animation("default")
	anim_cache[key] = updated_frames
	what.sprite_frames = updated_frames

static var anim_cache = {}

static var shpoobo_textures = [
	preload("res://sprites/shpoobo/scpoobo_1.png"),
	preload("res://sprites/shpoobo/scpoobo_2.png"),
	preload("res://sprites/shpoobo/scpoobo_3.png"),
	preload("res://sprites/shpoobo/scpoobo_4.png"),
	preload("res://sprites/shpoobo/scpoobo_5.png")
]

static var accessories = [
	null,
	preload("res://sprites/head_accessories/head_accessory_1.png"),
	preload("res://sprites/head_accessories/head_accessory_2.png"),
	preload("res://sprites/head_accessories/head_accessory_3.png"),
	preload("res://sprites/head_accessories/head_accessory_4.png"),
	preload("res://sprites/head_accessories/head_accessory_5.png"),
	preload("res://sprites/head_accessories/head_accessory_6.png"),
	preload("res://sprites/head_accessories/head_accessory_7.png"),
	preload("res://sprites/head_accessories/head_accessory_8.png"),
	preload("res://sprites/head_accessories/head_accessory_9.png"),
	preload("res://sprites/head_accessories/head_accessory_10.png"),
	preload("res://sprites/head_accessories/head_accessory_11.png"),
	preload("res://sprites/head_accessories/head_accessory_12.png"),
]

@onready var body_material: ShaderMaterial = $Sprite2D.material
@onready var hat_material: ShaderMaterial = $HeadFront.material
func _ready():
	# set_label("""shpoobo""")
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

func play_animation(anim):
	$HeadBack.play(anim)
	$Sprite2D.play(anim)
	$HeadFront.play(anim)
	
func _physics_process(delta):
	hat_material.set_shader_parameter("hue", head_hue)
	body_material.set_shader_parameter("hue", player_hue)
	update_texture($Sprite2D, shpoobo_textures[fposmod(player_skin, shpoobo_textures.size())])
	var acc = accessories[fposmod(head_accessory, accessories.size())]
	update_texture($HeadFront, acc)
	update_texture($HeadBack, acc, 32)
	#if get_multiplayer_authority() == multiplayer.get_unique_id():
	_move(delta)

var was_on_ground = true
var locked = false
func _process(delta):
	if owned:
		var space_state = get_viewport().get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = global_position
		query.collision_mask = 8 # layer 3
		query.collide_with_areas = true  # Ensure we're checking against areas, not just physics bodies
		var result = space_state.intersect_point(query)
		if result.size() > 0:
			locked = true
			$CameraTarget.position = result[0].collider.global_position
		else:
			locked = false
	if input.move_input < 0.0:
		$Sprite2D.flip_h = true
		$HeadFront.flip_h = true
		$HeadBack.flip_h = true
	elif input.move_input > 0.0:
		$Sprite2D.flip_h = false
		$HeadFront.flip_h = false
		$HeadBack.flip_h = false
	if !on_ground && was_on_ground:
		play_animation("jump")
		$JumpSound.play()
	elif $Sprite2D.animation != "jump" || !$Sprite2D.is_playing():
		if input.move_input != 0.0:
			play_animation("walk")
		else:
			play_animation("idle")
	was_on_ground = on_ground

func respawn():
	position = start_position
	last_y = global_position.y
	
@rpc("any_peer")
func teleport(pos, space = false):
	if multiplayer.get_remote_sender_id() == 1:
		last_y = pos.y
		global_position = pos
		if space:
			Global.go_to_space.emit()
		
func _move(delta):
	var in_space = false
	var space_state = get_viewport().get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position
	query.collision_mask = 16 # layer 3
	query.collide_with_areas = true  # Ensure we're checking against areas, not just physics bodies
	var result = space_state.intersect_point(query)
	if result.size() > 0:
		in_space = true
	if in_space:
		var dir = Vector2(input.move_input, input.space_input)
		velocity += dir * delta * 20.0
		velocity.limit_length(80.0)
		if input.jump_input:
			velocity = velocity.limit_length(velocity.length() * (1 - delta))
		move_and_shpoob(delta, true)
	else:
		velocity.y += gravity * delta
		var dir = input.move_input
		if dir != 0:
			velocity.x = lerp(velocity.x, dir * speed, acceleration)
		else:
			velocity.x = lerp(velocity.x, 0.0, friction)
			
		move_and_shpoob(delta)
		if input.jump_input and is_on_floor():
			velocity.y = jump_speed
		on_ground = is_on_floor()
		if on_ground:
			last_y = global_position.y























































# teehee
func move_and_shpoob(delta, bounce = false):
	if bounce:
		var collision = move_and_collide(velocity * delta)
		if collision:
			$JumpSound.play()
			velocity = velocity.bounce(collision.get_normal())
	else:
		move_and_slide()
