extends Node2D

onready var scoreX = get_node("Cross")
onready var score_x_label = scoreX.get_node("Texture/VBoxContainer/Label");
onready var score_x_pivot = scoreX.get_node("IncrementPivot")

onready var scoreO = get_node("Nought")
onready var score_o_label = scoreO.get_node("Texture/VBoxContainer/Label");
onready var score_o_pivot = scoreO.get_node("IncrementPivot")


onready var increment_animation_scene = preload("res://src/Scenes/Game/Scores/IncrementAnimation.tscn")


func _ready():
	#warning-ignore: return_value_discarded
	Events.connect("score_updated", self, "_score_updated")

	#warning-ignore: return_value_discarded
	Events.connect("update_score_label", self, "_update_score_label")

var last_score = {
	Constants.X: 0,
	Constants.O: 0,
};

func do_score_animation(changes, pivot, player, score):
	var increment_animation: Node2D = increment_animation_scene.instance()
	increment_animation.player = player
	increment_animation.score = score
	increment_animation.get_node("Label").text = "+%s" % changes;
	increment_animation.global_position = pivot.global_position
	get_tree().root.add_child(increment_animation)


func _score_updated(score):
	var x = score[Constants.X] - last_score[Constants.X]
	var o = score[Constants.O] - last_score[Constants.O]
	last_score[Constants.X] = score[Constants.X] 
	last_score[Constants.O] = score[Constants.O]
	do_score_animation(x, score_x_pivot, Constants.X, score[Constants.X])
	do_score_animation(o, score_o_pivot, Constants.O, score[Constants.O])


func get_label_text(score):
	if score == 0:
		return "-"
	return "%s" % score

func _update_score_label(player, score):
	if player == Constants.X:
		score_x_label.text = get_label_text(score)
	elif player == Constants.O:
		score_o_label.text = get_label_text(score)
	



