extends Node2D
class_name DungeonGenerator

var cellw: int = 208
var cellh: int = 120
var W: int = 500
var H: int = 330

var placedSpecial: bool
var cells: Array = []
var floorplan: Array = []
var floorplanCount: int
var cellQueue: Array
var endrooms: Array
var maxrooms: int = 15
var minrooms: int = 7
var bossl: int
var finished: bool = false
signal finished_dungeon_generation

@onready var room: PackedScene = preload("res://rooms/normal/room1.tscn")
@onready var boss_room: PackedScene = preload("res://rooms/boss/room1.tscn")
@onready var reward_room: PackedScene = preload("res://rooms/reward/room1.tscn")
@onready var coin_room: PackedScene = preload("res://rooms/coin/room1.tscn")
@onready var character: CharacterBody2D = get_node("character")
@onready var camera: Camera2D = get_node("Camera2D")

func _ready():
	start()

func start():
	placedSpecial = false

	for cell_element in cells:
		cell_element.queue_free()

	cells = []
	floorplan = []
	
	for i in range(101):
		floorplan.append(0)

	floorplanCount = 0
	cellQueue = []
	endrooms = []
	visit(45)
	spawn_player()

func _physics_process(_delta):
	if cellQueue.size() > 0:
		var i = cellQueue.pop_front()
		var x = i % 10
		var created = 0

		if x > 1:
			created = created | visit(i - 1)

		if x < 9:
			created = created | visit(i + 1)

		if i > 20:
			created = created | visit(i - 10)

		if i < 70:
			created = created | visit(i + 10)

		if not created:
			endrooms.append(i)
	elif not placedSpecial:
		if floorplanCount < minrooms:
			start()
			return

		placedSpecial = true
		bossl = endrooms.pop_front()
		cell(bossl, boss_room)

		var rewardl = poprandomendroom()
		cell(rewardl, reward_room)

		var coinl = poprandomendroom()
		cell(coinl, coin_room)

		var secretl = picksecretroom()

		if !rewardl or !coinl or !secretl:
			start()
			return
	elif not finished:
		finished = true
		finished_dungeon_generation.emit()

func cell(i: int, room_scene: PackedScene) -> Room:
	if find_child("Room"+str(i), false, false):
		var duplicated_cell = find_child("Room"+str(i), false, false)
		remove_child(duplicated_cell)

	var x: int = i % 10
	var y: int = (i - x) / 10
	var instance: Room = room_scene.instantiate()
	
	instance.global_position = Vector2(W / 2 + cellw * (x - 5), H / 2 + cellh * (y - 4))
	instance.room_index = i
	instance.name = "Room" + str(i)
	add_child(instance)
	cells.append(instance)
	return instance

func poprandomendroom() -> int:
	if endrooms.size() > 0:
		var index: int = randi() % endrooms.size()
		var i: int = endrooms[index]
		endrooms.remove_at(index)
		return i
	else:
		return -1

func picksecretroom() -> int:
	for e in range(900):
		var x = randi() % 9 + 1
		var y = randi() % 8 + 2
		var i = y * 10 + x

		if floorplan[i] != 0:
			continue

		if bossl == i - 1 or bossl == i + 1 or bossl == i + 10 or bossl == i - 10:
			continue

		if ncount(i) >= 3:
			return i

		if e > 300 and ncount(i) >= 2:
			return i

		if e > 600 and ncount(i) >= 1:
			return i

	return 0   # Default value if no suitable room is found

func ncount(i: int) -> int:
	if i + 1 > floorplan.size() - 1 or i + 10 > floorplan.size() - 1:
		return 0
	return floorplan[i - 10] + floorplan[i - 1] + floorplan[i + 1] + floorplan[i + 10]

func visit(i: int) -> int:
	if i < 0 or i >= 100 or floorplan[i] != 0:
		return 0

	var neighbours: int = ncount(i)

	if neighbours > 1:
		return 0

	if floorplanCount >= maxrooms:
		return 0

	if randf() < 0.5 and i != 45:
		return 0

	cellQueue.append(i)
	floorplan[i] = 1
	floorplanCount += 1

	cell(i, room)
	return 1

func spawn_player():
	var room_element: Room = cells[0]
	var center = room_element.get_node("SpawnCenter")
	character.global_position = center.global_position
	camera.global_position = center.global_position
