extends CharacterBody2D

const SPEED = 100.0
const DASH_SPEED = 600.0
var DIR_DASHING = false
var DIR_DASH_CD = false
	
func _physics_process(delta: float) -> void:
	get_input(delta)

	# Add the gravity.
	if (!is_on_floor() and !DIR_DASHING):
		velocity.y += get_gravity().y/2 * delta

	if (!DIR_DASHING):
		velocity.x = move_toward(velocity.x, 0, 20) # Also would affect the speed of acceleration

	move_and_slide()

func get_input(delta : float) -> void:
	# Ground movement
	if (is_on_floor()):
		if Input.is_action_pressed("key_right"): 
			velocity.x = SPEED
		if Input.is_action_pressed("key_left"): 
			velocity.x = -SPEED
		if Input.is_action_just_pressed("key_up"): 
			velocity.y -= DASH_SPEED/3
			$DirectionDashTimer.start()
			DIR_DASHING = true

	# Small dash
	elif (!DIR_DASHING and !DIR_DASH_CD and !is_on_floor()):
		var small_dash_dir = Vector2.ZERO
		if Input.is_action_just_pressed("key_up"): small_dash_dir.y = -1
		if Input.is_action_just_pressed("key_down"): small_dash_dir.y = 1
		if Input.is_action_just_pressed("key_right"): small_dash_dir.x = 1
		if Input.is_action_just_pressed("key_left"): small_dash_dir.x = -1

		if (small_dash_dir != Vector2.ZERO):
			velocity = small_dash_dir * DASH_SPEED/2
			$DirectionDashTimer.start()
			DIR_DASHING = true

	# Mouse Dash
	var mouse_pos = get_viewport().get_mouse_position()
	var player_pos = get_global_transform_with_canvas().get_origin() + Vector2($Sprite2D.texture.get_width()/2, $Sprite2D.texture.get_height()/2)
	if Input.is_action_just_pressed("mouse_left"):
		var difference = mouse_pos - player_pos
		# Roughly a length of 300 from player to top/ bottom of screen, and a length of roughly 500 from either side of the screen
		velocity = (difference).normalized() * (DASH_SPEED * clamp(difference.length(), 50, 200)/200) # Now speeda is determine be mouse distance from player

	# Cancel all movement with space
	if Input.is_action_just_pressed("key_space"):
		velocity = Vector2.ZERO	

func _on_direction_dash_timer_timeout():
	DIR_DASHING = false
	$DirectionDashCooldownTimer.start()
	DIR_DASH_CD = true

func _on_direction_dash_cooldown_timer_timeout() -> void:
	DIR_DASH_CD = false
