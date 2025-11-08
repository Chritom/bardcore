extends Node3D
class_name inventory_component

#@export var tele_comp: telegraphing_component
@export var stat_comp: stat_component

var pickupable_items: Array[droppable_item]
var pickup_item: droppable_item

var slots = {
	droppable_item.item_type.RING: [],
	droppable_item.item_type.HELMET: null,
	droppable_item.item_type.TORSO: null,
	droppable_item.item_type.BOOTS: null,
	droppable_item.item_type.INSTRUMENT: null,
}

func try_pickup() -> void: #call this on pickup input
	if pickup_item:
		pickup(pickup_item)

func pickup(item: droppable_item) -> void: #call this if a item should be forced into a slot
	var slot = slots[item.type]
	if slot is Array:
		if slot.size() >= 2:
			drop(item.type)
		slot.append(item)
	elif slot is droppable_item:
		drop(item.type)
	slot = item
	stat_comp.add_upgrades(item.get_instance_id(),item.upgrades)
	item.get_parent().remove_child(item)

func drop(item_type: droppable_item.item_type) -> void:
	var slot = slots[item_type]
	if slot is Array:
		if slot[0] is droppable_item:
			MapManager.current_map.add_child(slot[0])
			slot[0].global_position = global_position + global_basis.z * -5
			stat_comp.remove_upgrades(slot[0].get_instance_id())
			slot.remove_at(0)
	elif slot is droppable_item:
		MapManager.current_map.add_child(slot)
		slot.global_position = global_position + global_basis.z * -5
		stat_comp.remove_upgrades(slot.get_instance_id())
		slots[item_type] = null

func add_possible_pickupable_item(area: Area3D) -> void:
	if area.owner is droppable_item:
		pickupable_items.append(area.owner)
		if !pickup_item:
			pickup_item = area.owner
		elif area.owner.global_position.distance_to(global_position) < pickup_item.global_position.distance_to(global_position):
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
