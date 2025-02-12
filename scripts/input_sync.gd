extends MultiplayerSynchronizer


@export var move_input : float

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_physics_process(false)
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

@rpc("authority", "call_local")
func jump():
	if multiplayer.is_server():
		get_parent().jumping = true
	else:
		$"../Sprite2D".play("jump")

var disabled = false

func _physics_process(delta):
	if Global.chat_active:
		disabled = true
	if disabled:
		return
	move_input = Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	if Input.is_action_just_pressed("chat"):
		Global.chat_active = true
