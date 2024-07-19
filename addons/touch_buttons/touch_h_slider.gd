tool
class_name TouchHSlider extends TouchSlider


func _init():
	_validate_shared()
	_orientation = HORIZONTAL
	_theme_type = "TouchHSlider"
	size_flags_horizontal = 1
	size_flags_vertical = 0
