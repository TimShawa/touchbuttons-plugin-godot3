tool
class_name TouchVSlider extends TouchSlider


func _init():
	_validate_shared()
	_orientation = VERTICAL
	_theme_type = "TouchVSlider"
	size_flags_horizontal = 0
	size_flags_vertical = 1
