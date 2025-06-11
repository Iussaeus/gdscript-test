@static_unload
extends Node

@warning_ignore_start("unused_signal", "untyped_declaration")
signal added_var()
signal saved()
signal main_display_spawned(Node2D)
signal secondary_display_spawned(Node2D)
signal player_spawned(PlayerController)
signal board_spawned(Board)
signal bumper_spawned(Bumper)
signal laser_spawned(Laser)
signal thruster_spawned(Thruster)
signal puzzle_spawned(Puzzle)
signal start_spawned(Marker3D)
@warning_ignore_restore("unused_signal", "untyped_declaration")

var main_display: Node2D
var secondary_display: Node2D
var player: PlayerController
var board: Board
var laser: Laser
var bumper: Bumper
var puzzle: Puzzle 
var start: Marker3D 

var in_main_menu: bool

var cb_count_re: RegEx
var cb_name_re: RegEx

var current_level: String
var levels: Array = [
	"res://entities/main_world/scenes/main_staging.tscn",
	"res://entities/levels/scenes/level_1.tscn",
	"res://entities/levels/scenes/level_2.tscn",
	"res://entities/levels/scenes/level_3.tscn",
	"res://entities/levels/scenes/level_4.tscn",
	]

static var _code_block_count: int = -1

var code_block_count: int:
	get:
		_code_block_count += 1
		return _code_block_count

static var vars: Dictionary[String, VarBlock] = {}

func _enter_tree() -> void:
	@warning_ignore_start("untyped_declaration")
	main_display_spawned.connect(func(d): main_display = d)
	secondary_display_spawned.connect(func(d): secondary_display = d)
	player_spawned.connect(func(d): player = d)
	board_spawned.connect(func(d): board = d)
	laser_spawned.connect(func(d): laser = d)
	bumper_spawned.connect(func(d): bumper = d)
	start_spawned.connect(func(d):  start = d)
	@warning_ignore_restore("untyped_declaration")
	
	cb_count_re = RegEx.new()
	cb_name_re = RegEx.new()
	cb_count_re.compile("\\d+")
	cb_name_re.compile("\\D*")

func add_var(var_name: String, var_block: VarBlock) -> void:
	for key: String in vars.keys():
		if vars[key] == var_block:
			vars.erase(key)

	vars[var_name] = var_block

func save_eval_screen_state() -> void:
	if not DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_absolute("user://saves")
	
	var file := FileAccess.open("user://saves/eval_screen.data", FileAccess.WRITE)
	file.store_var(main_display.get_state())

func load_eval_screen_state() -> void:
	var file := FileAccess.open("user://saves/eval_screen.data", FileAccess.READ)
	var screen_state:Dictionary = file.get_var()
	
	main_display.load_state(screen_state.code_blocks, screen_state.connections)

func save_game() -> void:
	if not DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_absolute("user://saves")

	var file := FileAccess.open("user://saves/save.data", FileAccess.WRITE)

	file.store_var(main_display.get_state())
	file.store_var(player.get_state())
	file.store_var(laser.get_state()) 
	file.store_var(bumper.get_state()) 
	file.store_var(board.get_state()) 
	# print("INFO: saved %s level" % current_level)
	file.store_var(current_level) 
	print("INFO: saved game")
	file.close()

func load_game() -> void:
	var file := FileAccess.open("user://saves/save.data", FileAccess.READ)
	var screen_state:Dictionary = file.get_var()

	main_display.load_state(screen_state.code_blocks, screen_state.connections)
	player.load_state(file.get_var())
	laser.load_state(file.get_var())
	bumper.load_state(file.get_var())
	board.load_state(file.get_var())
	current_level = file.get_var()
	print("INFO: loaded game")
	file.close()
	
func current_saved_level() -> String:
	var file := FileAccess.open("user://saves/save.data", FileAccess.READ)
	var data: Variant = file.get_var() 

	while data is not String:
		data = file.get_var()
	
	return data

func open_menu() -> void:
	save_game()
	await get_tree().create_timer(1).timeout
	in_main_menu = true 
	PersistentStaging.instance.load_scene(PersistentStaging.instance.main_scene)

func close_menu() -> void:
	await get_tree().create_timer(1).timeout
	in_main_menu = false
	PersistentStaging.instance.load_scene(current_level, true)

func next_level() -> void:
	var next_level_idx := levels.find(current_level) + 1
	BlockManager.connections.clear()
	main_display = null
	secondary_display = null
	player = null
	board = null
	laser = null
	bumper = null
	puzzle = null
	_code_block_count = -1
	current_level = levels[next_level_idx]
	PersistentStaging.instance.load_scene(levels[next_level_idx])
