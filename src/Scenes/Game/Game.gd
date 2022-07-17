extends Node2D

const cross_scene = preload("res://src/Scenes/Game/Cross/Cross.tscn");
const nought_scene = preload("res://src/Scenes/Game/Nought/Nought.tscn");

var data = [
	[0, 0, 0], 
	[0, 0, 0], 
	[0, 0, 0]
]

var move_counter = 0
var thread = Thread.new()
var current_turn = -1;
var winner: int = Constants.None
var score = {
	Constants.X: 0,
	Constants.O: 0,
}

var rng = RandomNumberGenerator.new()

# TODO: Implement this properly
var mode = Constants.PVP;
var human = Constants.X;
var ai = Constants.O;


onready var cells: Array = get_node("Grid/Cells").get_children();
onready var moves : Node2D = get_node("Moves");


func _ready():
	rng.randomize()
	self.mode = Globals.mode
	var turn = [Constants.X, Constants.O][rng.randi() % 2]
	change_turn(turn)
	print(turn)

	#warning-ignore: return_value_discarded
	Events.connect("grid_cell_clicked", self, "_on_Grid_cell_clicked")
	#warning-ignore: return_value_discarded
	Events.connect("restart_button_preseed", self, "_Restart_button_pressed")

func change_turn(turn = null):
	if turn == null:
		if current_turn == Constants.X:
			current_turn = Constants.O
		elif current_turn == Constants.O:
			current_turn = Constants.X
	else:
		current_turn = turn

	if mode == Constants.PVC and current_turn == ai:
		_start_ai_move_thread()

func check_winner():
	var value: int;

	# Horizontal
	for y in range(3):
		value = data[y][0] + data[y][1] + data[y][2]
		if value == Constants.X_WIN_CONDITION:
			return Constants.X
		elif value == Constants.O_WIN_CONDITION:
			return Constants.O

	# Verticle
	for x in range(3):
		value = data[0][x] + data[1][x] + data[2][x]
		if value == Constants.X_WIN_CONDITION:
			return Constants.X
		elif value == Constants.O_WIN_CONDITION:
			return Constants.O

	# Diagonal \
	value = data[0][0] + data[1][1] + data[2][2]
	if value == Constants.X_WIN_CONDITION:
		return Constants.X
	elif value == Constants.O_WIN_CONDITION:
		return Constants.O

	# Diagonal /
	value = data[0][2] + data[1][1] + data[2][0]
	if value == Constants.X_WIN_CONDITION:
		return Constants.X
	elif value == Constants.O_WIN_CONDITION:
		return Constants.O

	for row in data:
		for v in row:
			if v == Constants.Blank:
				return Constants.None

	return Constants.Tie

	
func place_move(grid_cell: Cell):
	var scene: PackedScene;
	if current_turn == Constants.X:
		scene = cross_scene
	elif current_turn == Constants.O:
		scene = nought_scene
	
	var sprite = scene.instance()
	sprite.global_position = grid_cell.pivot.global_position;
	moves.add_child(sprite)


func _Restart_button_pressed():
	# Reset Winner
	winner = Constants.None

	# Remove all placed moves
	for m in moves.get_children():
		moves.remove_child(m)
		m.queue_free()

	# Resseting Data Values
	for y in range(3):
		for x in range(3):
			data[y][x] = Constants.Blank

	# Reset Move Counter
	move_counter = 0

	change_turn()
	
func increment_score():
	if winner != Constants.Tie:
		score[winner] += 1

	Events.emit_signal("score_updated", score)

func _handle_move(grid_cell: Cell):
	if winner != Constants.None:
		return

	
	var cell = grid_cell.cell;
	
	if data[cell.y][cell.x] != Constants.Blank:
		return

	move_counter += 1

	data[cell.y][cell.x] = current_turn;
	place_move(grid_cell)

	winner = check_winner()

	if winner == Constants.None:
		return change_turn()

	# Handle if the winner is not none
	increment_score()

func _on_Grid_cell_clicked(grid_cell: Cell):
	if mode == Constants.PVC and current_turn == ai:
		return
	_handle_move(grid_cell)
	
	

func _map_player_to_score(state: int):
	if state == ai:
		return 10
	elif state == Constants.Tie:
		return 0
	elif state == human:
		return -10


func pick_best_move(board: Array):
	if move_counter == 0:
		return cells[rng.randi() % 9]

	var best_score = -INF;
	var best_cell = null;
	for cell in cells:
		var x = cell.cell.y;
		var y = cell.cell.x;
		if board[x][y] == Constants.Blank:
			board[x][y] = ai
			var current_score = minimax(board, false)
			board[x][y] = Constants.Blank
			if current_score > best_score:
				best_score = current_score
				best_cell = cell

	return best_cell;


func minimax(board, is_maximizing):
	var result = check_winner()
	
	if result != Constants.None:
		return _map_player_to_score(result)
	
	if is_maximizing:
		var best_score = -INF;
		for cell in cells:
			var x = cell.cell.y;
			var y = cell.cell.x;
			if board[x][y] == Constants.Blank:
				board[x][y] = ai
				var current_score = minimax(board, false)
				board[x][y] = Constants.Blank
				best_score = max(current_score, best_score)

		return best_score

	else:
		var best_score = INF;
		for cell in cells:
			var x = cell.cell.y;
			var y = cell.cell.x;
			if board[x][y] == Constants.Blank:
				board[x][y] = human
				var current_score = minimax(board, true)
				board[x][y] = Constants.Blank
				best_score = min(best_score, current_score)

		return best_score

func _ai_move_thread():
	var cell = pick_best_move(data)
	call_deferred("_ai_move_thread_done")
	return cell


func _start_ai_move_thread():
	thread.start(self, "_ai_move_thread")

func _ai_move_thread_done():
	var cell = thread.wait_to_finish()
	_handle_move(cell)

