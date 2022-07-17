extends TextureButton

func _on_MainMenu_pressed():
	#warning-ignore: return_value_discarded
	get_tree().change_scene_to(Globals.main_menu_scene)
