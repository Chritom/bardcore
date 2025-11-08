extends Node3D
class_name Map

@onready var enemy_nodes: Node3D = $Enemies
@onready var exit_nodes: Node3D = $Exits
@onready var bits: Node3D = $Bits

var enemies = []
var portals = []
var right_portal:Portal
var left_portal:Portal

func _ready() -> void:
	read_map()
	shuffle_boxes()

func read_map():
	for enemy in enemy_nodes.get_children():
		enemies.append(enemy)
	for portal in exit_nodes.get_children():
		portals.append(portal)
	
	connect_portals()

func connect_portals():
	for portal in portals:
		if portal.position.x <= 0:
			left_portal = portal
			left_portal.on_enter_portal.connect(exit_left)
		else:
			right_portal = portal
			right_portal.on_enter_portal.connect(exit_right)

func exit_left():
	MapManager.go_left()

func exit_right():
	MapManager.go_right()

func spawn_players():
	# TODO get access to all players and place them at the entrance
	# compat with multiplayer spawning in
	if PlayerManager.player_nodes.is_empty():
		return
	
	var entrance
	if MapManager.coming_from_left:
		entrance = left_portal
	else:
		entrance = right_portal
	
	var player_nodes = PlayerManager.player_nodes
	var entrance_position = entrance.spawn_center.global_position
	
	for player_node in player_nodes:
		var player = player_nodes[player_node]
		#var cur_scene = get_tree().get_current_scene()
		var cur_scene = MapManager.get_current_map()
		if cur_scene:
			cur_scene.add_child(player)
			player.position = entrance_position
			entrance_position.z += 2.0

func unlock_all_portals():
	for portal in portals:
		portal.unlock()
	
func lock_all_portals():
	for portal in portals:
		portal.lock()

func lock_unlock_all_portals():
	lock_all_portals()
	var unlock_timer = Timer.new()
	unlock_timer.one_shot = true
	unlock_timer.autostart = true
	unlock_timer.timeout.connect(unlock_all_portals)
	add_child(unlock_timer)

func shuffle_boxes():
	var boxes = bits.get_children()
	for box in boxes:
		box.position += Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
