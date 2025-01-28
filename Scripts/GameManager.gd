class_name GameManager extends Control

enum GameState{
	MAIN_MENU, OPTIONS_MENU, PAUSE_MENU, GAME
}



@onready var hud = $HUD
@onready var gui = $GUI
@onready var main_scene = $Game
@onready var stamina_bar = $"HUD/Bubble Girl UI/TextureProgressBar"
@onready var main_menu = $GUI/MainMenu
@onready var pause_menu = $GUI/PauseMenu
@onready var options_menu = $GUI/OptionsMenu


var level_instance: Node2D
var game_paused = true
var curr_level
var retry_text = null
var level_menu_loaded = false
var name_tween
var current_state = GameState.MAIN_MENU

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.main_scene = self
	gui.show()
	hud.hide()
	main_menu.show()
	options_menu.hide()
	pause_menu.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"): 
		on_escape_pressed()

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

	if Global.level_counter <= Global.NUMBER_OF_LEVELS:
		load_level(next_level_name)
	else:
		unload_level()
		#quit_game()
		back_to_main_menu()

func start_game():
	current_state = GameState.GAME
	load_level("level_1")
	unpause_game()

func pause_game() -> void:
	current_state = GameState.PAUSE_MENU

	get_tree().paused = true
	game_paused = true
	main_scene.hide()
	hud.hide()
	main_menu.hide()
	pause_menu.show()
	gui.show()
	
	

func unpause_game() -> void:
	get_tree().paused = false
	game_paused = false
	main_scene.show()
	hud.show()
	gui.hide()
	current_state = GameState.GAME

func quit_game() -> void:
	get_tree().quit()


func game_over(death_text = "You died, I think?") -> void:
	reload_level(false)


func on_play_button_pressed() -> void:
	start_game()

func on_resume_button_pressed() -> void:
	unpause_game()

func open_options() -> void:
	main_menu.hide()
	options_menu.show()
	current_state = GameState.OPTIONS_MENU

func exit_options() -> void:
	options_menu.hide()
	main_menu.show()
	current_state = GameState.MAIN_MENU


func back_to_main_menu() -> void:
	current_state = GameState.MAIN_MENU
	pause_menu.hide()
	unload_level()
	main_menu.show()

func on_escape_pressed() -> void:
	if current_state == GameState.MAIN_MENU:
		quit_game()
	elif current_state == GameState.OPTIONS_MENU:
		exit_options()
	elif current_state == GameState.PAUSE_MENU:
		unpause_game()
	elif current_state == GameState.GAME:
		pause_game()
