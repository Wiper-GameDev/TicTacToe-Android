extends Node2D


onready var anim_player := $AnimationPlayer;

var score: int;
var player: int;

func _ready():
	#warning-ignore: return_value_discarded
	anim_player.connect("animation_finished", self, "_on_animation_finished")
	anim_player.play("FadeOut")

func _on_animation_finished(anim_name):
	if anim_name == "FadeOut":
		Events.emit_signal("update_score_label", player, score)
		queue_free()
		
