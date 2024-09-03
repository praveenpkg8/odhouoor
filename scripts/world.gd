extends Node2D

var rectangle_position = Vector2(100, 100)
var rectangle_size = Vector2(300, 200)
var mask_radius = 20

# Stores the positions where the circle has erased
var erased_positions = []

func _draw():
	# Draw the original rectangle
	rectangle_size.x -= 20
	draw_rect(Rect2(rectangle_position, rectangle_size), Color(1, 0, 0))
	
	# Draw erased circles (simulate erasing effect)
	#print("draw being called")
	#for position in erased_positions:
		#draw_circle(position, mask_radius, Color(1, 1, 1, 0))
		
func _ready():
	draw_rect(Rect2(rectangle_position, rectangle_size), Color(1, 0, 0))

func _process(delta):
	# Update the rectangle and request redraw
	var mouse_position = get_local_mouse_position()
	
	# Check if the mouse is within the rectangle bounds
	if mouse_position.x >= rectangle_position.x and mouse_position.x <= rectangle_position.x + rectangle_size.x and mouse_position.y >= rectangle_position.y and mouse_position.y <= rectangle_position.y + rectangle_size.y:
		
		erased_positions.append(mouse_position)

	# Request a redraw to trigger _draw()
	#_draw()
	queue_redraw()
