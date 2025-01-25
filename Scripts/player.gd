class_name Player extends CharacterBody2D

enum JumpState {FALLING, JUMPING, FLOATING}

@export var SPEED = 400.0
@export var health = 1
@export var jump_power = 550
@export var coyote_time = 0.2
@export var jump_to_fall_v = 100
@export var max_float_time = 1.5
@export var gravity_dict = {
	JumpState.FALLING: 980,
	JumpState.JUMPING: 500,
	JumpState.FLOATING: -400,
}
@export var max_float_speed = 600
@export var float_recharge_speed = 2000
@export var float_braking = 1000
@export var heavy_gravity_multiplier = 2.0
@export var heavy_movement_accel = 200
@export var heavy_max_speed = 800.0

var last_direction = 1
var time_since_grounded = 0
var time_since_jump = 0
var time_since_float = 0
var jump_state = JumpState.FALLING
var float_left = max_float_time
var extra_weight = 0.0

@onready var main_sprite:AnimatedSprite2D = $MainSprite
@onready var collider: Area2D = $Collider

func _ready() -> void:
	Global.player = self
	self.collider.body_entered.connect(func(_body): on_death(""))

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		if extra_weight > 0.001:
			velocity.x = move_toward(velocity.x, direction*heavy_max_speed, heavy_movement_accel*delta)
			if sign(velocity.x) != sign(direction):
				velocity.x = move_toward(velocity.x, direction*heavy_max_speed, heavy_movement_accel*delta)

		else:
			velocity.x = direction * SPEED
		main_sprite.flip_h = direction < 0
		
	else:
		if extra_weight > 0.001:
			velocity.x = move_toward(velocity.x, 0, heavy_movement_accel*delta*2)
				

		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		
	# Apply gravity.
	#if not is_on_floor():
	time_since_grounded += delta
	var gravity = gravity_dict[jump_state]
	if extra_weight > 0.001:
		velocity.y += gravity * delta * heavy_gravity_multiplier
	else:
		velocity.y += gravity * delta
	
	if jump_state == JumpState.FLOATING:
		float_left -= delta
		if abs(velocity.y) > max_float_speed:
			if velocity.y < 0:
				velocity.y += float_braking  * delta
			else: 
				velocity.y -= float_braking * delta
	

	if is_on_floor():
		time_since_grounded = 0
		if not extra_weight > 0.001:
			if float_left < max_float_time:
				float_left = min(float_left + float_recharge_speed*delta, max_float_time)



	# Jump if jump button pressed.
	handle_jump()

	move_and_slide()


func handle_jump():
	var just_jumped = Input.is_action_just_pressed("jump") and time_since_grounded < coyote_time
	var stop_jump = Input.is_action_just_released("jump")
	var just_floated = Input.is_action_just_pressed("float") and not extra_weight > 0.001
	var stop_float = Input.is_action_just_released("float")

	if just_jumped: 
		time_since_grounded += 10
		jump_state = JumpState.JUMPING
		velocity.y = -1 * (jump_power)

	
	if just_floated:
		jump_state = JumpState.FLOATING
		main_sprite.play("inflating")
	
		
	if jump_state == JumpState.JUMPING:
		if stop_jump: 
			jump_state = JumpState.FALLING
			
			
		elif velocity.y > - jump_to_fall_v: 
			jump_state = JumpState.FALLING
			
			

	if jump_state == JumpState.FLOATING:
		if stop_float or float_left < 0.0:
			jump_state = JumpState.FALLING
			
			


func on_death(message: String) -> void:
	Global.main_scene.game_over()


func on_pickup_collect(weight_gained):
	self.extra_weight += weight_gained
	
 
func _on_main_sprite_animation_finished():
	if jump_state == JumpState.FLOATING:
		main_sprite.play("looping")
		
	if jump_state == JumpState.FALLING:
		main_sprite.play("inflating", 0.5, true)
	else:
		main_sprite.stop()
	
	pass 
