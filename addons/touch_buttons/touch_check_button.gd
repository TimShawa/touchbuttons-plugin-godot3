tool
class_name TouchCheckButton extends TouchButton


func _init():
	toggle_mode = true
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
	
	_update_controls_size()
	
	_n_panel().self_modulate = Color.transparent if flat else Color.white
	
	_n_hbox().add_constant_override("separation", _get_button_constant("h_separation", _theme_type))
	
	_n_text().add_font_override("font", _get_button_font("font", _theme_type))
	_n_text().text = self.text
	_n_text().align = self.align
	_n_text().clip_text = self.clip_text
	
	if is_instance_valid(icon):
		_n_icon().show()
		_n_icon().texture = self.icon
	elif _has_theme_icon("icon", _theme_type):
		_n_icon().show()
		_n_icon().texture = _get_button_icon("icon", _theme_type)
	else:
		_n_icon().hide()
	
	if expand_icon:
		_n_icon().expand = false
		_n_icon().stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	else:
		_n_icon().expand = true
		_n_icon().stretch_mode = TextureRect.STRETCH_KEEP
	
	match get_draw_mode():
		DrawMode.DRAW_NORMAL:
			_n_panel().add_stylebox_override("panel", _get_button_stylebox("normal", _theme_type))
			_n_icon().self_modulate = _get_button_color("icon_color_normal", _theme_type)
			_n_text().add_color_override("font_color", _get_button_color("font_color", _theme_type))
		DrawMode.DRAW_PRESSED:
			_n_panel().add_stylebox_override("panel", _get_button_stylebox("pressed", _theme_type))
			_n_icon().self_modulate = _get_button_color("icon_color_pressed")
			_n_text().add_color_override("font_color", _get_button_color("font_color_pressed", _theme_type))
		DrawMode.DRAW_DISABLED:
			_n_panel().add_stylebox_override("panel", _get_button_stylebox("disabled", _theme_type))
			_n_icon().self_modulate = _get_button_color("icon_color_disabled")
			_n_text().add_color_override("font_color", _get_button_color("font_color_disabled", _theme_type))
	
	var item := "on" if button_pressed else "off"
	if disabled:
		item += "_disabled"
	_n_check().texture = _get_button_icon(item, _theme_type)


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
		size.x += _get_button_constant("h_separation", _theme_type)
	
	return size




