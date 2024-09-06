extends Node2D

const SPEED = 60

var direction = -1


@export var behaviour_ai: BehaviourTree
@export var enemy: Enemy
@export var DieParticle: PackedScene
@export var damage := 30

var result: BehaviourTreeResults
var blackboard: Blackboard

@onready var animated_sprite = $AnimatedSprite2D
const BULLET: PackedScene = preload("res://scene/enemy/bullet.tscn")



@onready var player: CharacterBody2D

@export var follow_offset: Vector2 = Vector2(100, 100)
@export var smoothing_factor: float = 0.5
@export var attraction_force: float = 40.0
var current_point_index = 0
@export var movement_speed = 100


var can_fire = true
var can_die = true

var next_fire_time = 0
var fire_rate = 1 # Bullets per second

var radius = 100
var num_points = 16
var patrol_points = []





# Called when the node enters the scene tree for the first time.
func _ready():
	result = BehaviourTreeResults.new()
	blackboard = Blackboard.new()
	blackboard.data["parent_node"] = self
	blackboard.data["is_on_attack_range"] = false
	blackboard.data["is_on_follow_through_range"] = false
	
		# Generate the patrol points along a circle
	for i in range(num_points):
		var angle = i * 2 * PI / num_points
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		patrol_points.append(Vector2(x, y))
	
	# Set the initial position to the first patrol point
	position = patrol_points[current_point_index]
	
	
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_instance_valid(enemy):
		queue_free()
	if player and is_instance_valid(enemy):
		var movement_details = enemy.move_towards_player(
			global_position,
			player,
			rotation,
			delta
		)
		print("move towards player")
		global_position = movement_details.get("global_position")
		rotation = movement_details.get("rotation")


	behaviour_ai.tick(
		delta,
		blackboard,
		result
	)
	



func spwan_bullet():
	var direction = global_position.direction_to(player.global_position)
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = global_position
	new_bullet.direction = direction
	get_tree().current_scene.add_child(new_bullet)
	enemy.manage_attack()

func _on_attack_process_attack_player():
	enemy.manage_attack()
	if can_fire:
		spwan_bullet()
		can_fire = false
		next_fire_time = max(next_fire_time, Time.get_ticks_msec() + (1.0 / fire_rate) * 1000)

	if Time.get_ticks_msec() > next_fire_time:
		can_fire = true

	



func _on_patrol_movement_progresser(
	delta: float
):
	var movement_details = enemy.manage_movement(
		position,
		delta,
		current_point_index,
		movement_speed,
		patrol_points
	)
	position = movement_details.get("position")
	current_point_index = movement_details.get("current_point_index")
	
	
	



func _on_patroling_zone_body_entered(body):
	blackboard.data["is_on_attack_range"] = true
	

func _on_patroling_zone_body_exited(body):
	blackboard.data["is_on_attack_range"] = false
	


func _on_follow_through_zone_body_entered(body):
	player = body
	blackboard.data["is_on_follow_through_range"] = true
	
	pass # Replace with function body.


func _on_follow_through_zone_body_exited(body):
	player = null
	blackboard.data["is_on_follow_through_range"] = false
	pass


func _on_is_follow_through_move_towards_player():
	pass
	

func kill():
	var die_particle = DieParticle.instantiate()
	die_particle.global_position = global_position
	get_tree().current_scene.add_child(die_particle)
	queue_free()


func _on_enemy_area_body_entered(body):
	enemy.manage_health(40, self)
