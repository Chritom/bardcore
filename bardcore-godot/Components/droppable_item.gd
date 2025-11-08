extends Node3D
class_name droppable_item

enum item_type {
	RING,
	HELMET,
	TORSO,
	BOOTS,
	INSTRUMENT,
}

@export var type: item_type = item_type.RING
@export var upgrades: Array[upgrade]
@export var mesh: PackedScene

var item_mesh: Node3D

func _ready() -> void:
	item_mesh = mesh.instantiate()
	add_child(item_mesh)

func _process(delta: float) -> void:
	item_mesh.rotate(Vector3.UP, delta * deg_to_rad(25))
	item_mesh.position.y = lerp(item_mesh.position.y + 1, sin(Time.get_ticks_msec()/300.0)*0.5 + 1, 0.5)
