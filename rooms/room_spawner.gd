extends Node2D
class_name Room

var camera_acceleration = 0.5
var room_index = 0

@onready var dungeon: DungeonGenerator = get_parent()
@onready var tilemap: TileMap = get_node("TileMap") 

func _ready():
	dungeon.finished_dungeon_generation.connect(set_doors)

func set_doors():
	if room_index + 1 > dungeon.floorplan.size() - 1 or room_index + 10 > dungeon.floorplan.size() - 1:
		return
	
	var has_up = dungeon.floorplan[room_index - 10]
	var has_left = dungeon.floorplan[room_index - 1]
	var has_right = dungeon.floorplan[room_index + 1]
	var has_down = dungeon.floorplan[room_index + 10]
	var exit_tile_pos: Vector2i
	
	if has_up != 0:
		var top_spawn = get_node("EntranceDetectors/EntranceUp")
		exit_tile_pos = tilemap.local_to_map(top_spawn.position)
		
		tilemap.erase_cell(0, exit_tile_pos)
	if has_left != 0:
		var left_spawn = get_node("EntranceDetectors/EntranceLeft")
		exit_tile_pos = tilemap.local_to_map(left_spawn.position)
		
		tilemap.erase_cell(0, exit_tile_pos)
		
	if has_right != 0:
		var right_spawn = get_node("EntranceDetectors/EntranceRight")
		exit_tile_pos = tilemap.local_to_map(right_spawn.position)
		
		tilemap.erase_cell(0, exit_tile_pos)

	if has_down != 0:
		var down_spawn = get_node("EntranceDetectors/EntranceDown")
		exit_tile_pos = tilemap.local_to_map(down_spawn.position)
		
		tilemap.erase_cell(0, exit_tile_pos)

func _on_entrance_body_entered(body):
	if body is CharacterBody2D:
		center_camera_to_room()

func center_camera_to_room():
	var camera = get_viewport().get_camera_2d()
	var spawn_center = get_node("SpawnCenter")
	
	var tween = create_tween()
	tween.tween_property(camera, "position", spawn_center.global_position, 0.25)
