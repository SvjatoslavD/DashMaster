extends CharacterBody2D

const accel = 800 # currently unused as velocity is set to target within one frame
const decel = 400
const max_speed = 2600
# kdash is the keyboard dash; vdash is the mouse dash
const kdash_speed_mult = 2.5
const mdash_speed_mult = 5

var key_press_input = Vector2.ZERO
var key_held_input = Vector2.ZERO
var mouse_press_input = Vector2.ZERO
# only one type of dash can be active at a time
var kdashing = false
var mdashing = false
var kdash_cd = false
var running = false

func _physics_process(delta: float) -> void:
	player_movement(delta)
	apply_physics(delta)
	move_and_slide()

func player_movement(delta: float) -> void:
	get_key_press_input()
	get_key_held_input()
	get_mouse_press_input()
	
	# handles dashes
	if (mouse_press_input != Vector2.ZERO and !mdashing and !kdashing):
		mdashing = true
		$MDashTimer.start()
		handle_dashing(delta)

	elif (key_press_input != Vector2.ZERO and !kdashing and !mdashing and !kdash_cd):
		kdashing = true
		$KDashTimer.start()
		handle_dashing(delta)
		
	# handles walking
	if (running and !mdashing and !kdashing):
		if (key_held_input.x == 0): running = false
		else: velocity.x = key_held_input.x * max_speed * delta
	

func apply_physics(delta: float) -> void:
	if (key_press_input == Vector2.ZERO and !kdashing and !mdashing):
		# set gravity to 500px/s from 980px/s
		velocity += get_gravity() * delta
		velocity.x = move_toward(velocity.x, 0, decel * delta)

func get_key_press_input() -> void:
	key_press_input.x = int(Input.is_action_just_pressed("key_right")) - int(Input.is_action_just_pressed("key_left"))
	key_press_input.y = int(Input.is_action_just_pressed("key_down")) - int(Input.is_action_just_pressed("key_up"))
	if (key_press_input != Vector2.ZERO): key_press_input.normalized()

func get_key_held_input() -> void:
	key_held_input.x = int(Input.is_action_pressed("key_right")) - int(Input.is_action_pressed("key_left"))
	key_held_input.y = int(Input.is_action_pressed("key_down")) - int(Input.is_action_pressed("key_up"))
	if (key_held_input != Vector2.ZERO): key_held_input.normalized()

func get_mouse_press_input() -> void:
	if Input.is_action_just_pressed("mouse_left"):
		var mouse_pos = get_viewport().get_mouse_position()
		var player_pos = get_global_transform_with_canvas().get_origin() + Vector2($Sprite2D.texture.get_width()/2, $Sprite2D.texture.get_height()/2)
		mouse_press_input = mouse_pos - player_pos # if you normalize the value here, you can't use it to determine mdash speed

func handle_dashing(delta: float) -> void:
	if (kdashing):
		# the kdash timer handles the duration 
		# speed change should be gradual
		velocity = (key_held_input * max_speed * kdash_speed_mult * delta)
	elif (mdashing):
		# the mdash only has a duration handled by the mdash timer
		# roughly a length of 300 from player to top/ bottom of screen, and a length of roughly 500 from either side of the screen
		# speed is determined by the mouse distance from player
		velocity = mouse_press_input.normalized() * (max_speed * mdash_speed_mult * (clamp(mouse_press_input.length(), 50, 200)/200) * delta) 

func _on_m_dash_timer_timeout() -> void:
	mdashing = false
	mouse_press_input = Vector2.ZERO

func _on_k_dash_timer_timeout() -> void:
	kdashing = false
	kdash_cd = true
	$KDashCdTimer.start()
	if (key_held_input.x != 0):
		running = true

func _on_k_dash_cd_timer_timeout() -> void:
	kdash_cd = false
