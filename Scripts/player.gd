extends CharacterBody2D

enum JumpState {FALLING, JUMPING, FLOATING}

@export var SPEED = 400.0
@export var health = 1
@export var jump_power = 550
@export var coyote_time = 0.2
@export var jump_to_float_v = 100
@export var max_float_time = 1.5
@export var has_float = false
@export var gravity_dict = {
	JumpState.FALLING: 980,
	JumpState.JUMPING: 500,
	JumpState.FLOATING: -400,
}

var last_direction = 1
var time_since_grounded = 0
var time_since_jump = 0
var time_since_float = 0
var jump_state = JumpState.FALLING


@onready var main_sprite = $MainSprite

func _ready() -> void:
	Global.player = self

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		if last_direction != direction:
			main_sprite.scale.x *= -1
			last_direction *= -1

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if jump_state == JumpState.FLOATING:
		time_since_float += delta

	# Apply gravity.
	if not is_on_floor():
		time_since_grounded += delta
		var gravity = gravity_dict[jump_state]
		velocity.y += gravity * delta
	
	if is_on_floor():
		time_since_grounded = 0
	
	# Jump if jump button pressed.
	handle_jump()

	move_and_slide()


func handle_jump():
	var just_jumped = Input.is_action_just_pressed("jump") and time_since_grounded < coyote_time
	var stop_jump = Input.is_action_just_released('jump')
	
	if just_jumped: 
		time_since_grounded += 10
		jump_state = JumpState.JUMPING
		velocity.y = -1 * (jump_power)
	
	if stop_jump:
		jump_state = JumpState.FALLING
	
	if jump_state == JumpState.JUMPING:
		if velocity.y > -jump_to_float_v: 
			jump_state = JumpState.FLOATING

	if jump_state == JumpState.FLOATING:
		if time_since_float > max_float_time:
			jump_state = JumpState.FALLING
