extends CenterContainer

@onready var save_list_node = $LoadGame/SaveList
var save_list : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_pane(1)

	# Get our list of save games
	if PersistentWorld.instance:
		save_list = PersistentWorld.instance.list_saves()

		save_list_node.clear()
		for entry in save_list:
			save_list_node.add_item(entry)

	if GameState.in_main_menu:
		$MainMenu/SaveButton.visible = true 
		$MainMenu/new_mainBtn.visible = false
# $MainMenu/LoadGameBtn.disabled = save_list.size() == 0

func _set_pane(p_no):
	$MainMenu.visible = p_no == 1
	$NewGame.visible = p_no == 2
	$LoadGame.visible = p_no == 3
	$Options.visible = p_no == 4

# Main menu
func _on_new_game_btn_pressed():
	_set_pane(2)

func _on_options_btn_pressed():
	_set_pane(4)

func _on_exit_btn_pressed():
	get_tree().quit()

func _on_new_main_btn_pressed() -> void:
	GameState.current_level = "res://entities/main_world/scenes/main_staging.tscn"
	PersistentStaging.instance.load_scene(GameState.current_level)

func _on_load_game_btn_pressed() -> void:
	PersistentStaging.instance.load_scene(GameState.current_saved_level(), true)
	GameState.in_main_menu = false

# New game
func _on_easy_btn_pressed():
	GameStatePersistent.instance.new_game(GameStatePersistent.GameDifficulty.GAME_EASY)

func _on_normal_btn_pressed():
	GameStatePersistent.instance.new_game(GameStatePersistent.GameDifficulty.GAME_NORMAL)

func _on_hard_btn_pressed():
	GameStatePersistent.instance.new_game(GameStatePersistent.GameDifficulty.GAME_HARD)

func _on_back_btn_pressed():
	_set_pane(1)

# Load game

func _on_start_button_pressed():
	var selected_items = save_list_node.get_selected_items()
	if selected_items.size() == 1:
		# Should be only one!
		var selected_item = selected_items[0]
		print("Selected item: ", selected_item)

		var save_name = save_list[selected_item]
		print("Loading save: ", save_name)
		GameStatePersistent.instance.load_game(save_name)
