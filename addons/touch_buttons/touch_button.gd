tool
class_name TouchButton extends TouchBaseButton


enum TextAlign { ALIGN_LEFT, ALIGN_CENTER, ALIGN_RIGHT }


var text := "" setget set_text, get_text
var icon: Texture setget set_icon, get_icon_texture
var flat := false setget set_flat, is_flat
var clip_text := false setget set_clip_text, get_clip_text
var align: int = TextAlign.ALIGN_CENTER setget set_align, get_align
var icon_align: int = TextAlign.ALIGN_LEFT setget set_icon_align, get_icon_align
var expand_icon := false setget set_expand_icon, is_expand_icon


func _get_property_list():
	return [
		{ name = "TouchButton", type = TYPE_NIL, usage = PROPERTY_USAGE_CATEGORY },
		{ name = "text", type = TYPE_STRING, hint = PROPERTY_HINT_MULTILINE_TEXT },
		{ name = "icon", type = TYPE_OBJECT, hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = "Texture" },
		{ name = "flat", type = TYPE_BOOL },
		{ name = "clip_text", type = TYPE_BOOL },
		{ name = "align", type = TYPE_INT, hint = PROPERTY_HINT_ENUM, hint_string = "Left,Center,Right" },
		{ name = "icon_align", type = TYPE_INT, hint = PROPERTY_HINT_ENUM, hint_string = "Left,Center,Right" },
		{ name = "expand_icon", type = TYPE_BOOL }
	]


var _theme_type := "TouchButton"
var _buttons_theme = load("res://addons/touch_buttons/buttons.theme")


#region SETGET

func set_text(value):
	text = value; update()
func set_icon(value):
	icon = value; update()
func set_flat(value):
	flat = value; update()
func set_clip_text(value):
	clip_text = value; update()
func set_align(value):
	align = value; update()
func set_icon_align(value):
	icon_align = value; update()

func set_expand_icon(value):
	expand_icon = value;
	rect_size.x = max(rect_size.x, get_combined_minimum_size().x)
	rect_size.y = max(rect_size.y, get_combined_minimum_size().y)
	update()


func get_text():
	return text
func get_icon_texture():
	return icon
func is_flat():
	return flat
func get_clip_text():
	return clip_text
func get_align():
	return align
func get_icon_align():
	return icon_align
func is_expand_icon():
	return expand_icon

#endregion


func _ready() -> void:
	if !is_instance_valid(_n_panel()):
		var panel = PanelContainer.new()
		add_child(panel, 0)
		panel.name = "__button_panel"
		_n_panel().call_deferred("set_anchors_preset", Control.PRESET_WIDE)
		
		_n_panel().add_child(HBoxContainer.new(), true)
		_n_hbox().set_anchors_preset(Control.PRESET_WIDE)
		
		_n_hbox().add_child(Control.new(), true)
		_n_control().size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_n_control().size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		_n_control().add_child(TextureRect.new(), true)
		_n_icon().mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		_n_control().add_child(Label.new(), true)
		_n_text().valign = Label.VALIGN_CENTER


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


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_THEME_CHANGED:
			update()


func _n_panel() -> Node:
	if has_node("__button_panel"):
		return $__button_panel
#	push_error("There is no __button_panel node.")
	return null


func _n_hbox() -> Node:
	if has_node("__button_panel/HBoxContainer"):
		return $__button_panel/HBoxContainer
	return null


func _n_control() -> Node:
	if has_node("__button_panel/HBoxContainer/Control"):
		return $__button_panel/HBoxContainer/Control
	return null


func _n_icon() -> Node:
	if has_node("__button_panel/HBoxContainer/Control/TextureRect"):
		return $__button_panel/HBoxContainer/Control/TextureRect
#	push_error("There is no __button_panel/HBoxContainer/TextureRect node.")
	return null


func _n_text() -> Node:
	if has_node("__button_panel/HBoxContainer/Control/Label"):
		return $__button_panel/HBoxContainer/Control/Label
#	push_error("There is no __button_panel/HBoxContainer/Label node.")
	return null


func _update_controls_size():
	_n_panel().rect_size = rect_size
	minimum_size_changed()
	
	var sep: int = _get_button_constant("h_separation", _theme_type)
	var con_size: Vector2 = _n_control().rect_size
	
	if !_n_icon().visible or _n_icon().texture == null:
		_n_icon().rect_size = Vector2.ZERO
		_n_icon().rect_position = Vector2.ZERO
		_n_text().rect_position = Vector2.ZERO
		_n_text().rect_size = con_size
		return
	
	_n_icon().rect_size = _n_icon().texture.get_size()
	var text_min_size = _n_text().get_combined_minimum_size()
	
	match icon_align:
		TextAlign.ALIGN_LEFT:
			if expand_icon:
				_n_icon().rect_size = min(con_size.x - text_min_size.x, con_size.y) * Vector2.ONE
			_n_icon().rect_position = Vector2(0, (con_size.y - _n_icon().rect_size.y) / 2)
			_n_text().rect_position = Vector2(_n_icon().rect_size.x, 0)
			_n_text().rect_size = con_size - _n_text().rect_position
		
		TextAlign.ALIGN_CENTER:
			if expand_icon:
				_n_icon().rect_size = min(con_size.x, con_size.y) * Vector2.ONE
			_n_icon().rect_position = (con_size - _n_icon().rect_size) / 2
			_n_text().rect_position = Vector2.ZERO
			_n_text().rect_size = con_size
		
		TextAlign.ALIGN_RIGHT:
			if expand_icon:
				_n_icon().rect_size = min(con_size.x - text_min_size.x, con_size.y) * Vector2.ONE
			_n_icon().rect_position = Vector2(con_size.x - _n_icon().rect_size.x, (con_size.y - _n_icon().rect_size.y) / 2)
			_n_text().rect_position = Vector2.ZERO
			_n_text().rect_size = Vector2(_n_icon().rect_position.x, con_size.y)


func _get_minimum_size() -> Vector2:
	if !is_node_ready():
		return Vector2.ZERO
	
	var separation = _get_button_constant("h_separation", _theme_type)
	var stylebox: StyleBox = _n_panel().get_stylebox("panel","PanelContainer")
	var borders := Vector2(
		stylebox.content_margin_left + stylebox.content_margin_right,
		stylebox.content_margin_top + stylebox.content_margin_bottom)
	
	var min_size := borders
	var text_size = _n_text().get_combined_minimum_size()
	
	if !_n_icon().visible or _n_icon().texture == null or expand_icon:
		return min_size + text_size
	
	if !text.empty():
		if icon_align == TextAlign.ALIGN_CENTER:
			min_size.x += separation
	
	var icon_size = _n_icon().texture.get_size()
	
	if icon_align == TextAlign.ALIGN_CENTER:
		min_size.x += max(text_size.x, icon_size.x)
	else:
		min_size.x += text_size.x + icon_size.x
	min_size.y += max(text_size.y, icon_size.y)
	
	return min_size


func _get_button_color(name: String, theme_type: String = _theme_type) -> Color:
	if !theme_type_variation.empty():
		theme_type = theme_type_variation
	if is_instance_valid(theme):
		if theme.has_color(name, theme_type):
			return theme.get_color(name, theme_type)
	return _buttons_theme.get_color(name, theme_type)


func _get_button_constant(name: String, theme_type: String = _theme_type) -> int:
	if !theme_type_variation.empty():
		theme_type = theme_type_variation
	if is_instance_valid(theme):
		if theme.has_constant(name, theme_type):
			return theme.get_constant(name, theme_type)
	return _buttons_theme.get_constant(name, theme_type)


func _get_button_font(name: String, theme_type: String = _theme_type) -> Font:
	if !theme_type_variation.empty():
		theme_type = theme_type_variation
	if is_instance_valid(theme):
		if theme.has_font(name, theme_type):
			return theme.get_font(name, theme_type)
	return _buttons_theme.get_font(name, theme_type)


func _get_button_icon(name: String, theme_type: String = _theme_type) -> Texture:
	if !theme_type_variation.empty():
		theme_type = theme_type_variation
	if is_instance_valid(theme):
		if theme.has_icon(name, theme_type):
			return theme.get_icon(name, theme_type)
	return _buttons_theme.get_icon(name, theme_type)


func _get_button_stylebox(name: String, theme_type: String = _theme_type) -> StyleBox:
	if !theme_type_variation.empty():
		theme_type = theme_type_variation
	if is_instance_valid(theme):
		if theme.has_stylebox(name, theme_type):
			return theme.get_stylebox(name, theme_type)
	return _buttons_theme.get_stylebox(name, theme_type)


func _has_theme_icon(name, theme_type):
	if !theme_type_variation.empty():
		theme_type = theme_type_variation
	if is_instance_valid(theme):
		if theme.has_icon(name, theme_type):
			return true
	return _buttons_theme.has_icon(name, theme_type)
	
