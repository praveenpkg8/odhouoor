extends Node2D

@onready var behaviour_ai: Node = $BehaviourAi
var black_board: BlackBoard
var result: BehaviourTreeResult
var player: CharacterBody2D
var attacking_force = 300

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	black_board = BlackBoard.new()
	black_board.data["is_player_near_by"] = false
	black_board.data["is_in_follow_thorugh_range"] = false
	black_board.data["is_attacking"] = false
	
	result = BehaviourTreeResult.new()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player:
		global_position = move_towards_player(
			global_position,
			player,
			delta
		)
	behaviour_ai.tick(black_board, result)
	

func move_towards_player(
	global_position: Vector2,
	player: CharacterBody2D,
	delta: float
):

	var direction = global_position.direction_to(player.global_position)
	#var distance = global_position.distance_to(player.global_postion)
	var attacking_velocity = direction * attacking_force
	global_position += attacking_velocity * delta
	# Returns position of the player
	return global_position
	pass



func _on_follow_through_area_body_entered(body: Node2D) -> void:
	player = body
	black_board.data["is_in_follow_thorugh_range"] = true
	print("player in enemy zone")
	pass # Replace with function body.


func _on_attack_area_body_entered(body: Node2D) -> void:
	black_board.data["is_player_near_by"] = true
	print("player attack zone")
	pass # Replace with function body.


func _on_follow_through_area_body_exited(body: Node2D) -> void:
	player = null
	black_board.data["is_attacking"] = false
	black_board.data["is_in_follow_thorugh_range"] = false
	
	
	pass # Replace with function body.


func _on_attack_area_body_exited(body: Node2D) -> void:
	black_board.data["is_player_near_by"] = false
	
	pass # Replace with function body.
