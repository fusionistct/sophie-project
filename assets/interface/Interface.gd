extends Control

signal health_changed(health)
signal health_initialize(maxHealth)

func _on_Health_health_changed(health) -> void:
	emit_signal("health_changed", health)


func _on_Health_health_initialize(maxHealth) -> void:
	emit_signal("health_initialize", maxHealth)


func _on_Interface_health_changed(health) -> void:
	pass # Replace with function body.
