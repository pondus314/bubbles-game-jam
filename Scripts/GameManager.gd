class_name GameManager extends Control

@export var level_count = 1

@onready var hud = $HUD
@onready var gui = $GUI
@onready var main_scene = $Game

var level_instance: Node2D
var game_paused = true
var curr_level
var retry_text = null
var level_menu_loaded = false
var name_tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.main_scene = self
	start_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func unload_level() -> void:
	
	if is_instance_valid(level_instance):
		level_instance.queue_free()
	Global.player = null
	level_instance = null

func load_level(level_name: String) -> void:
	unload_level()

	var level_path = "res://Scenes/%s.tscn" % level_name
	var level_resource = load(level_path)
	if (level_resource): 
		curr_level = level_name
		level_instance = level_resource.instantiate()
		main_scene.add_child.call_deferred(level_instance)
	#load_menu(MenuType.PAUSE)
	unpause_game()

func reload_level(use_checkpoint: bool) -> void:
	load_level(curr_level)

func finish_level():
	pause_game()
	next_level()
	
func next_level():
	Global.level_counter += 1
	var next_level_name = "level_%s" % Global.level_counter 

	if Global.level_counter < Global.NUMBER_OF_LEVELS:
		load_level(next_level_name)
	else:
		unload_level()
		quit_game()
		#load_menu(MenuType.MAIN)

func start_game():
	#load_menu(MenuType.PAUSE)
	load_level("level_1")
	unpause_game()

func pause_game() -> void:
	get_tree().paused = true
	game_paused = true

	hud.hide()
	gui.show()

func unpause_game() -> void:
	get_tree().paused = false
	game_paused = false
	main_scene.show()
	#hud.show()
	gui.hide()

func quit_game() -> void:
	get_tree().quit()


func game_over(death_text = "You died, I think?") -> void:
	reload_level(false)
