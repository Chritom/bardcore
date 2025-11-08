extends CharacterBody3D
class_name Player

signal leave

const TRUMPET = preload("uid://515m7a070dcx")
const VIOLIN = preload("uid://lxalv8rqbk0c")

@onready var player_name: Label3D = $PlayerName
@onready var instrument_spawn: Node3D = $InstrumentSpawn

@export var dash_force: float = 50.0
@export var dash_cooldown: float = 0.1
@export var dash_duration: float = 0.1

@export var stat_comp: stat_component
@export var inventory: inventory_component

var gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera: Camera3D
var player: int
var input
var device
var equipped_instrument

func init(player_num: int):
	player = player_num
	device = PlayerManager.get_player_device(player)
	input = DeviceInput.new(device)

func _ready() -> void:
	if !equipped_instrument:
		add_instrument(TRUMPET)

func _physics_process(delta: float) -> void:
	# only in case movement_sm doesnt work
	#movement()
	if device < 0:
		point_to_mouse()
	else:
		look_direction()
	
	if MultiplayerInput.is_action_just_pressed(device, "interact"):
		inventory.try_pickup()
	
	velocity.y -= gravity * delta
	move_and_slide()

func point_to_mouse():
	var mouse_position = get_viewport().get_mouse_position()
	
	var camera = get_tree().get_first_node_in_group("Camera")
	
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_normal = ray_origin + camera.project_ray_normal(mouse_position) * 1000
	
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_normal)
	
	ray_query.collide_with_bodies = true
	
	var space_state = get_world_3d().direct_space_state
	var ray_result = space_state.intersect_ray(ray_query)
	
	if !ray_result.is_empty():
		var look_at_position = Vector3(ray_result.position.x, position.y ,ray_result.position.z)
		look_at(look_at_position)

func look_direction():
	var input_dir = input.get_vector("look_left", "look_right", "look_up", "look_down").normalized()
	if !input_dir:
		return
	rotation = Vector3(0, -input_dir.angle() - PI/2, 0)

func movement():
	var device = PlayerManager.get_player_device(player)
	var input_dir = MultiplayerInput.get_vector(device, "move_left", "move_right", "move_up", "move_down")
	
	if input_dir:
		velocity.x = input_dir.x * stat_comp.get_stat(stat_comp.stat_id.MOVEMENT_SPEED)
		velocity.z = input_dir.y * stat_comp.get_stat(stat_comp.stat_id.MOVEMENT_SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, stat_comp.get_stat(stat_comp.stat_id.MOVEMENT_SPEED))
		velocity.z = move_toward(velocity.z, 0, stat_comp.get_stat(stat_comp.stat_id.MOVEMENT_SPEED))

func set_playername():
	player_name.set_text("P " + str(player))

func add_instrument(instrument):
	if equipped_instrument:
		equipped_instrument.queue_free()
	var instrument_instance = instrument.instantiate()
	instrument_instance.position = instrument_spawn.position
	add_child(instrument_instance)
	equipped_instrument = instrument_instance
