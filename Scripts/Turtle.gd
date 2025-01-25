extends CharacterBody2D

@export var current_direction = -1


const SPEED = 150.0

@onready var turn_collider: Area2D = $TurningCollider
@onready var sprite = $TurtleProto

func _ready() -> void:
	self.turn_collider.body_entered.connect(func(_body): turn())
	self.scale.x = - current_direction

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var veldif = current_direction * SPEED
	velocity.x = veldif

	move_and_slide()


func turn() -> void:
	current_direction *= -1
	self.scale.x *=  -1
