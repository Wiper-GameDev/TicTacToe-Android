extends TextureButton



func _on_Restart_pressed():
	Events.emit_signal("restart_button_preseed")
