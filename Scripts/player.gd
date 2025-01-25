extends CharacterBody2D


@export var SPEED = 400.0
@export var health = 1
@export var jump_power = 550
@export var jump_gravity = 500
@export var fall_gravity = 980
@export var coyote_time = 0.2
@export var jump_to_fall_v = 100

var last_direction = 1
var time_since_grounded = 0
var time_since_jump = 0
var jumping = false
var falling = true


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

	move_and_slide()

	# Apply gravity.
	if not is_on_floor():
		time_since_grounded += delta
		if jumping: 
			velocity.y += jump_gravity * delta
		else:
			velocity.y += fall_gravity * delta
	
	if is_on_floor():
		time_since_grounded = 0
	
	# Jump if jump button pressed.
	handle_jump()


func handle_jump():
	var just_jumped = Input.is_action_just_pressed("jump") and time_since_grounded < coyote_time
	var stop_jump = Input.is_action_just_released('jump')
	
	if just_jumped: 
		time_since_grounded += 10
		jumping = true
		velocity.y = -1 * (jump_power)
	
	if stop_jump:
		jumping = false
	
	if jumping:
		if velocity.y > -jump_to_fall_v: 
			jumping = false
