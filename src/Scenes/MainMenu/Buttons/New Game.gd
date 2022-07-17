extends TextureButton



func _on_New_Game_pressed():
	Events.emit_signal("newgame_button_preseed")
