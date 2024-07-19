tool
class_name TouchCheckButton, "res://addons/touch_buttons/icons/icon_touch_check_button.png"
extends TouchButton


func _init(text := ""):
	._init(text)
	press_mode = PressMode.MODE_TOGGLE
	align = TextAlign.ALIGN_LEFT
	_theme_type = "TouchCheckButton"


func _ready() -> void:
	._ready()
	var check := TextureRect.new()
	check.name = "Check"
	_n_hbox().add_child(check)
	_n_hbox().move_child(check, 1)
	check.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	update()


func _n_check() -> Node:
	if has_node("__button_panel/HBoxContainer/Check"):
		return $__button_panel/HBoxContainer/Check
	return null


func _draw() -> void:
	if !is_node_ready():
		return
	
	._draw()
	
	var item := "on" if button_pressed else "off"
	if disabled:
		item += "_disabled"
	_n_check().texture = get_theme_item("icon", item, _theme_type)


func _get_minimum_size() -> Vector2:
	var size = ._get_minimum_size()
	
	if !is_instance_valid(_n_check()) \
			or !is_instance_valid(_n_check().texture):
		return size
	
	var stylebox: StyleBox = _n_panel().get_stylebox("panel","PanelContainer")
	var border := stylebox.content_margin_top + stylebox.content_margin_bottom
	
	size.x += _n_check().rect_size.x
	size.y = max( size.y - border, _n_check().texture.get_size().y) + border
	
	if _n_icon().visible or !text.empty():
		size.x += get_theme_item("constant", "hseparation", _theme_type)
	
	return size


func is_node_ready():
	return .is_node_ready() and is_instance_valid(_n_check())
