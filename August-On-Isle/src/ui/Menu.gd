extends Control


onready var main_menu = $MainMenu
onready var fader = $Fader
onready var options_menu = $OptionsMenu
onready var new_game_button = $MainMenu/VBoxContainer/NewGameButton
onready var continue_game_button = $MainMenu/VBoxContainer/ContinueGameButton
onready var options_button = $MainMenu/VBoxContainer/OptionsButton
onready var exit_button = $MainMenu/VBoxContainer/ExitButton
onready var from_options_back_button = $OptionsMenu/VBoxContainer/BackButton
onready var new_game_confirm = $MainMenu/NewGameConfirm

func _ready():
	new_game_button.connect("pressed", self, "on_new_game_button_pressed")
	continue_game_button.connect("pressed", self, "on_continue_game_button_pressed")
	options_button.connect("pressed", self, "on_options_button_pressed")
	exit_button.connect("pressed", self, "on_exit_button_pressed")
	from_options_back_button.connect("pressed", self, "on_from_options_back_button_pressed")
	new_game_confirm.connect("confirmed", self, "on_new_game_confirmed")
	fader.connect("fade_finished", self, "on_fade_finished")

	if not GameSaver.save_file_exists(1):
		continue_game_button.disabled = true

func on_new_game_confirmed():
	fader.visible = true
	fader.fade_out("new_flag")
	
func on_new_game_button_pressed():
	new_game_confirm.popup()
	
func on_continue_game_button_pressed():
	fader.visible = true
	fader.fade_out("load_flag")
	

func on_fade_finished(fade_flag):	
	match fade_flag:
		"load_flag":
			get_parent().load_game()
		"new_flag":
			get_parent().new_game()
	
func on_options_button_pressed():
	main_menu.visible = false
	options_menu.visible = true
	
func on_exit_button_pressed():
	get_tree().quit()
	
func on_from_options_back_button_pressed():
	options_menu.visible = false
	main_menu.visible = true