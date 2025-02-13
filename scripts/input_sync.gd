extends MultiplayerSynchronizer


@export var move_input : float
@export var jump_input : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_physics_process(false)
	else:
		Global.change_color.connect(change_color.rpc_id)
		Global.change_item.connect(change_item.rpc_id)
	Global.enable_controls.connect(on_enable)
	Global.chat.connect(on_chat)
	
func on_enable():
	disabled = false
	
func on_chat(msg):
	if is_physics_processing():
		chat.rpc(msg)
	
@rpc("authority", "call_local")
func chat(msg):
	get_parent().set_label(msg)

@rpc("authority")
func secret(up):
	Global.interact.emit(up, multiplayer.get_remote_sender_id())

@rpc("authority")
func change_color(item, hue):
	match item:
		"hat":
			get_parent().head_hue = hue
		"body":
			get_parent().player_hue = hue
	
@rpc("authority")
func change_item(item, incr):
	match item:
		"hat":
			get_parent().head_accessory += incr
			if get_parent().head_accessory < 0:
				get_parent().head_accessory = get_parent().accessories.size() - 1
			elif get_parent().head_accessory >= get_parent().accessories.size():
				get_parent().head_accessory = 0
		"body":
			get_parent().player_skin += incr
			if get_parent().player_skin < 0:
				get_parent().player_skin = get_parent().shpoobo_textures.size() - 1
			elif get_parent().player_skin >= get_parent().shpoobo_textures.size():
				get_parent().player_skin = 0
	
var disabled = false

func _physics_process(delta):
	if Global.chat_active:
		move_input = 0.0
		jump_input = false
		disabled = true
	if disabled:
		return
	move_input = Input.get_axis("move_left", "move_right")
	jump_input = Input.is_action_pressed("jump")
	if Input.is_action_just_pressed("chat"):
		Global.chat_active = true
	if Input.is_action_just_pressed("secret_up"):
		secret.rpc_id(1, true)
	if Input.is_action_just_pressed("secret_down"):
		secret.rpc_id(1, false)
