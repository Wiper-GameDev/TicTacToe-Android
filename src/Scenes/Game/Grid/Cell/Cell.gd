extends Area2D

class_name Cell

export var cell: Vector2;
onready var pivot := $Pivot;
	

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		Events.emit_signal("grid_cell_clicked", self)
