extends CharacterBody2D

enum JumpState {FALLING, JUMPING, FLOATING}

@export var SPEED = 400.0
@export var health = 1
@export var jump_power = 550
@export var coyote_time = 0.2
@export var jump_to_fall_v = 100
@export var max_float_time = 1.5
@export var has_float = false
@export var gravity_dict = {
	JumpState.FALLING: 980,
	JumpState.JUMPING: 500,
	JumpState.FLOATING: -400,
}
@export var max_float_speed = 600
@export var float_recharge_speed = 2000

var last_direction = 1
var time_since_grounded = 0
var time_since_jump = 0
var time_since_float = 0
var jump_state = JumpState.FALLING
var float_left = max_float_time

@onready var main_sprite = $MainSprite
@onready var collider: Area2D = $Collider

func _ready() -> void:
	Global.player = self
	self.collider.body_entered.connect(func(_body): on_death(""))

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		main_sprite.flip_h = direction < 0

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

		
	# Apply gravity.
	if not is_on_floor():
		time_since_grounded += delta
		var gravity = gravity_dict[jump_state]
		velocity.y += gravity * delta
		if jump_state == JumpState.FLOATING:
			print(velocity.y)
			float_left -= delta
			if -velocity.y > max_float_speed:
				velocity.y -= gravity * delta * 2
		
		
	if is_on_floor():
		time_since_grounded = 0
		if float_left < max_float_time:
			float_left = min(float_left + float_recharge_speed*delta, max_float_time)
			
	
	
	# Jump if jump button pressed.
	handle_jump()

	move_and_slide()


func handle_jump():
	var just_jumped = Input.is_action_just_pressed("jump") and time_since_grounded < coyote_time
	var stop_jump = Input.is_action_just_released("jump")
	var just_floated = Input.is_action_just_pressed("float") 
	var stop_float = Input.is_action_just_released("float")

	if just_jumped: 
		time_since_grounded += 10
		jump_state = JumpState.JUMPING
		velocity.y = -1 * (jump_power)

	
	if just_floated:
		jump_state = JumpState.FLOATING
	
	if jump_state == JumpState.JUMPING:
		if stop_jump: 
			jump_state = JumpState.FALLING
		elif velocity.y > - jump_to_fall_v: 
			jump_state = JumpState.FALLING

	if jump_state == JumpState.FLOATING:
		if float_left < 0.0:
			jump_state = JumpState.FALLING


func on_death(message: String) -> void:
	Global.main_scene.game_over()
