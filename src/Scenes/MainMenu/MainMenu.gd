extends Node2D



func _ready():
	#warning-ignore: return_value_discarded
	Events.connect("newgame_button_preseed", self, "_start_new_game");

func _start_new_game():
	#warning-ignore: return_value_discarded
	get_tree().change_scene_to(Globals.select_mode_scene)
