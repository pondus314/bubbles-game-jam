extends Area2D

@export var extra_weight_given = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(func(_x): self.collect()) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func collect():
	Global.player.on_pickup_collect(extra_weight_given)
	self.queue_free()
