extends CharacterBody2D

const SPEED = 300.0
const DASH_SPEED = 600.0
var DASHING = false
	
func _physics_process(delta: float) -> void:
	get_input(delta)

	# Add the gravity.
	if !is_on_floor() and !DASHING:
		velocity += get_gravity() * delta

	if (!DASHING):
		pass
		#velocity.y = clamp(velocity.y, -1000, 1000)
		#velocity.x = clamp(velocity.x, -1000, 1000)
		#velocity.x = move_toward(velocity.x, 0, 10) # Also would affect the speed of acceleration

	move_and_slide()

func _on_direction_dash_timer_timeout():
	DASHING = false
		
func get_input(delta : float) -> void:
	# Ground movement
	if (is_on_floor()):
		if Input.is_action_pressed("key_right"): 
			velocity.x += SPEED * delta
		if Input.is_action_pressed("key_left"): 
			velocity.x -= SPEED * delta
		if Input.is_action_just_pressed("key_up"): 
			velocity.y -= DASH_SPEED * delta
			$DirectionDashTimer.start()
			DASHING = true
		
	# Small dash
	elif (!DASHING and !is_on_floor()):
		var small_dash_dir = Vector2.ZERO
		if Input.is_action_just_pressed("key_up"): small_dash_dir.y = -1
		if Input.is_action_just_pressed("key_down"): small_dash_dir.y = 1
		if Input.is_action_just_pressed("key_right"): small_dash_dir.x = 1
		if Input.is_action_just_pressed("key_left"): small_dash_dir.x = -1
		
		if (small_dash_dir != Vector2.ZERO):
			velocity = small_dash_dir * DASH_SPEED/2
			$DirectionDashTimer.start()
			DASHING = true
			
	# Mouse Dash
	var mouse_pos = get_viewport().get_mouse_position()
	var player_pos = get_global_transform_with_canvas().get_origin() + Vector2($Sprite2D.texture.get_width()/2, $Sprite2D.texture.get_height()/2)
	if Input.is_action_just_pressed("mouse_left"): 
		velocity = (mouse_pos - player_pos).normalized() * DASH_SPEED
		
	# Cancel all movement with space
	if Input.is_action_just_pressed("key_space"):
		velocity = Vector2.ZERO
	
	
