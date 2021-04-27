extends HBoxContainer

var maximum_value

func initialize(maximum):
	maximum_value = maximum
	$TextureProgress.max_value = maximum

func _on_Interface_health_changed(health) -> void:
	$TextureProgress.value = health

func _on_Interface_health_initialize(maxHealth) -> void:
	initialize(maxHealth)
