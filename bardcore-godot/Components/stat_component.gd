extends Node
class_name stat_component

enum stat_id {
	
	# -- Movement Stats --
	MOVEMENT_SPEED, #Maximum Move Speed
	MOVEMENT_ACCELERATION, #Amount of Acceleration
	
	# -- Health Stats --
	MAX_HEALTH, #Maximum Amount of Health
	TIME_TILL_REGENERATION, #Seconds till Regeneration starts after last hit
	REGENERATION_AMOUNT, #Regeneration per delta time
	IN_HEAL, #Modifier applied on all incoming heals
	HEALTH_GAIN, #Modifier applied on all positive health changes (incoming heals, regeneration, ...)
	INCOMING_DAMAGE, #Modifier applied on all negative health changes (hits, status-effect damage, ...)
	
	# -- Combat Stats --
	OUT_HEAL, #Modifier applied on all outgoing heals
	OUT_DAMAGE, #Modifier applied on all outgoing damaging hits
	ARMOR, #Multiplied with the damage after accounting for armor-piercing
	ARMOR_PIERCING, #Removed form armor of hits target
	RANGE, #Multiplies the leangth of the instruments area
	ANGLE, #Multiplies the angle of the instruments area
	
}

var upgrades: Dictionary[int, Array] = {}
var stat_upgrades: Dictionary[int, Array] = {}

@export var stats: Dictionary = {
	
	# -- Movement Stats --
	stat_id.MOVEMENT_SPEED: 10.0, #Maximum Move Speed
	stat_id.MOVEMENT_ACCELERATION: 0.5, #Amount of Acceleration
	
	# -- Health Stats --
	stat_id.MAX_HEALTH: 100.0, #Maximum Amount of Health
	stat_id.TIME_TILL_REGENERATION: 2.5, #Seconds till Regeneration starts after last hit
	stat_id.REGENERATION_AMOUNT: 5.0, #Regeneration per delta time
	stat_id.IN_HEAL: 1.0, #Modifier applied on all incoming heals
	stat_id.HEALTH_GAIN: 1.0, #Modifier applied on all positive health changes (incoming heals, regeneration, ...)
	stat_id.INCOMING_DAMAGE: 1.0, #Modifier applied on all negative health changes (hits, status-effect damage, ...)
	
	# -- Combat Stats --
	stat_id.OUT_HEAL: 1.0, #Modifier applied on all outgoing heals
	stat_id.OUT_DAMAGE: 1.0, #Modifier applied on all outgoing damaging hits
	stat_id.ARMOR: 1.0, #Multiplied with the damage after accounting for armor-piercing
	stat_id.ARMOR_PIERCING: 0.0, #Removed form armor of hits target
	stat_id.RANGE: 1.0, #Multiplies the leangth of the instruments area
	stat_id.ANGLE: 1.0, #Multiplies the angle of the instruments area
	
}

func _ready() -> void:
	for key in stats.keys():
		var stat_object: stat = stat.new()
		stat_object.base = stats[key]
		stat_object.modified = stats[key]
		stats[key] = stat_object

func get_stat(s_id: stat_id) -> float:
	var requested_stat: stat = stats[s_id]
	if requested_stat:
		if requested_stat.dynamic:
			calculate_stat(requested_stat, s_id)
		return requested_stat.modified
	else:
		push_warning("There was no stat with stat_id: "+str(s_id)+"! A float with amount 1.0 was returned instead.")
		return 1.0

func add_upgrades(Item_ID: int, new_upgrades: Array[upgrade]) -> void:
	upgrades[Item_ID] = new_upgrades
	var stats_upgrades_changed: Dictionary[stat_id, int]
	for new_upgrade in new_upgrades:
		if new_upgrade is stat_upgrade:
			stats_upgrades_changed[new_upgrade.effected_stat] = 0
			var this_stats_upgrades: Array[stat_upgrade] = stat_upgrades[new_upgrade.effected_stat]
			this_stats_upgrades.append(new_upgrade)
			this_stats_upgrades.sort_custom(sort_stat_upgrades_according_to_apply_prio)
		if new_upgrade is triggered_upgrade:
			new_upgrade.connect_trigger()
		recalculate_stats(stats_upgrades_changed)

func remove_upgrades(Item_ID) -> void:
	var old_upgrades: Array[upgrade] = upgrades[Item_ID]
	var stats_upgrades_changed: Dictionary[stat_id, int]
	for old_upgrade in old_upgrades:
		if old_upgrade is stat_upgrade:
			stat_upgrades[old_upgrade.effected_stat].erase(old_upgrade)
			stats_upgrades_changed[old_upgrade.effected_stat] = 0
		if old_upgrade is triggered_upgrade:
			old_upgrade.disconnect_trigger()
	if stats_upgrades_changed.keys().size() > 0:
		recalculate_stats(stats_upgrades_changed)
	upgrades.erase(Item_ID)

func calculate_stat(stat_object: stat, s_id: stat_id) -> void:
	var stat_value = stat_object.base
	if s_id in stat_upgrades.keys():
		var modifing_upgrades: Array[stat_upgrade] = stat_upgrades[s_id]
		if modifing_upgrades is Array:
			for mod_upgrade in modifing_upgrades:
				stat_value = mod_upgrade.apply(stat_value)
				if mod_upgrade.dynamic: stat_object.dynamic = true
	stat_object.modified = stat_value

func sort_stat_upgrades_according_to_apply_prio(a: stat_upgrade, b: stat_upgrade) -> bool:
	if a.apply_priority > b.apply_priority:
		return true
	return false

func recalculate_stats(s_ids: Dictionary[stat_id, int]) -> void:
	for s_id in s_ids.keys():
		calculate_stat(stats[s_id], s_id)
