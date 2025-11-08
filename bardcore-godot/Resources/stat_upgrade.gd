extends upgrade
class_name stat_upgrade

@export var effected_stat: stat_component.stat_id = stat_component.stat_id.MAX_HEALTH
@export var apply_priority: int = 10
@export var dynamic: bool = false

func apply(stat_value: float) -> float:
		#Modify stat_value here, if using external values to calculate: set dynamic true!
		return stat_value
