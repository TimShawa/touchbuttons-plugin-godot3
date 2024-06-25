tool
class_name TouchButtonGroup, "res://addons/touch_buttons/icons/icon_touch_button_group.png"
extends Resource


signal pressed(button)


var allow_unpress := false setget set_allow_unpress, get_allow_unpress


func _get_property_list():
	return [
		{ name = "TouchButtonBase", type = TYPE_NIL, usage = PROPERTY_USAGE_CATEGORY },
		{ name = "allow_unpress", type = TYPE_BOOL }
	]


func set_allow_unpress(value):
	allow_unpress = value


func get_allow_unpress():
	return allow_unpress


var _buttons := []


func _init():
	resource_local_to_scene = true
	resource_name = "TouchButtonGroup"


func get_buttons() -> Array:
	return _buttons.duplicate()


func get_pressed_button():
	for i in _buttons:
		if i.button_pressed:
			return i
	return null
