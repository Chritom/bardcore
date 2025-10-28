extends Node3D
class_name inventory_component

#@export var tele_comp: telegraphing_component

var pickupable_items: Array[droppable_item]
var pickup_item: droppable_item

var slots = {
	droppable_item.item_type.RING: [],
	droppable_item.item_type.HELMET: null,
	droppable_item.item_type.TORSO: null,
	droppable_item.item_type.BOOTS: null,
	droppable_item.item_type.INSTRUMENT: null,
}

var pickup_area: Area3D

func try_pickup() -> void: #call this on pickup input
	if pickup_item:
		pickup(pickup_item)

func pickup(item: droppable_item) -> void: #call this if a item should be forced into a slot
	var slot = slots[item.type]
	if slot is Array:
		slot.append(item)
	elif slot is droppable_item:
		drop(item.type)
	slot = item

func drop(item_type: droppable_item.item_type) -> void:
	var slot = slots[item_type]
	if slot is Array:
		if slot.size() >= 2:
			if slot[0] is droppable_item:
				get_tree().add_child(slot.pop_at(0))
	elif slot is droppable_item:
		get_tree().add_child(slot) #TODO: make enviroment a class to check for, also may create a function to call here that handles add_child() itself to put it at the right place
		slot.global_position = global_position + Vector3.FORWARD * 5
		slots[item_type] = null

func add_possible_pickupable_item(area: Area3D) -> void:
	if area.owner is droppable_item:
		pickupable_items.append(area.owner)
		if area.owner.global_position.distance_to(global_position) < pickup_item.global_position.distance_to(global_position):
			pickup_item = area.owner

func remove_pickupable_item(area: Area3D) -> void:
	if area.owner is droppable_item:
		pickupable_items.erase(area.owner)
		if area.owner == pickup_item:
			pickup_item = null
		evaluate_closest_pickupable()

func evaluate_closest_pickupable() -> void:
	var closest: droppable_item = null
	var distance_to_closest: float = 1000
	for item in pickupable_items:
		if closest == null:
			break
		elif closest.global_position.distance_to(global_position) > distance_to_closest:
			break
		closest = item
		distance_to_closest = closest.global_position.distance_to(global_position)
