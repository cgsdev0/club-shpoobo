extends MultiplayerSynchronizer


@export var move_input : float
@export var space_input : float
@export var jump_input : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_physics_process(false)
	else:
		Global.change_color.connect(change_color)
		Global.change_item.connect(change_item)
	Global.enable_controls.connect(on_enable)
	Global.chat.connect(on_chat)
	
func on_enable():
	disabled = false
	
func on_chat(msg):
	if is_physics_processing():
		var split = msg.split(" ")
		for i in split.size():
			var w = split[i]
			if w.length() < 2:
				continue
			var a = w[0]
			var b = w[1]
			# shoobify
			if b.to_lower() in vowels && a.to_lower() not in vowels && randi_range(1, 5) == 1:
				split[i] = "shp" + w.substr(1)
		msg = " ".join(split)
		chat.rpc(msg)

static var vowels = ["a", "e", "i", "o", "u"]

@rpc("authority", "call_local")
func chat(msg: String):
	get_parent().set_label(msg)

@rpc("authority")
func secret(up):
	Global.interact.emit(up, multiplayer.get_remote_sender_id())

func change_color(item, hue):
	match item:
		"hat":
			get_parent().head_hue = hue
			get_parent().save_game()
		"body":
			get_parent().player_hue = hue
			get_parent().save_game()
	
func change_item(item, incr):
	match item:
		"hat":
			get_parent().head_accessory += incr
			if get_parent().head_accessory < 0:
				get_parent().head_accessory = get_parent().accessories.size() - 1
			elif get_parent().head_accessory >= get_parent().accessories.size():
				get_parent().head_accessory = 0
			get_parent().save_game()
			if Global.in_space:
				Global.die_in_space.emit()
				get_parent().respawn()
		"body":
			get_parent().player_skin += incr
			if get_parent().player_skin < 0:
				get_parent().player_skin = get_parent().shpoobo_textures.size() - 1
			elif get_parent().player_skin >= get_parent().shpoobo_textures.size():
				get_parent().player_skin = 0
			get_parent().save_game()
	
var disabled = false

func _physics_process(delta):
	if Global.chat_active:
		move_input = 0.0
		jump_input = false
		disabled = true
	if disabled:
		return
	space_input = Input.get_axis("secret_up", "secret_down")
	move_input = Input.get_axis("move_left", "move_right")
	jump_input = Input.is_action_pressed("jump")
	if Input.is_action_just_pressed("chat"):
		Global.chat_active = true
	if Input.is_action_just_pressed("secret_up"):
		secret.rpc_id(1, true)
	if Input.is_action_just_pressed("secret_down"):
		secret.rpc_id(1, false)
