extends Node2D


func _start_game(mode):
	Globals.mode = mode
	#warning-ignore: return_value_discarded
	get_tree().change_scene_to(Globals.game_scene)


func _on_PvP_pressed():
	_start_game(Constants.PVP)
	



func _on_PvC_pressed():
	_start_game(Constants.PVC)
