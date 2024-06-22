tool
class_name TouchBaseButton extends Control


signal button_down
signal button_up
signal pressed
signal toggled(toggled_on)
signal drag_input(event)


enum ActionMode { ACTION_MODE_BUTTON_PRESS, ACTION_MODE_BUTTON_RELEASE }
enum DrawMode { DRAW_NORMAL, DRAW_PRESSED, DRAW_DISABLED }


var disabled := false setget set_disabled, is_disabled
var toggle_mode := false setget set_toggle_mode, is_toggle_mode
var button_pressed := false setget set_button_pressed, is_button_pressed
var action_mode: int = ActionMode.ACTION_MODE_BUTTON_RELEASE setget set_action_mode, get_action_mode
var passby_press := false setget set_passby_press, get_passby_press
var pass_screen_drag := false setget set_pass_screen_drag, get_pass_screen_drag
var button_group: TouchButtonGroup setget set_button_group, get_button_group


func _get_property_list():
	return [
		{ name = "TouchBaseButton", type = TYPE_NIL, usage = PROPERTY_USAGE_CATEGORY },
		{ name = "disabled", type = TYPE_BOOL },
		{ name = "toggle_mode", type = TYPE_BOOL },
		{ name = "button_pressed", type = TYPE_BOOL },
		{ name = "action_mode", type = TYPE_INT, hint = PROPERTY_HINT_ENUM, hint_string = "Button Press,Button Release" },
		{ name = "passby_press", type = TYPE_BOOL },
		{ name = "pass_screen_drag", type = TYPE_BOOL },
		{ name = "button_group", type = TYPE_OBJECT, hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = "Resource" }
	]

var _touch_index := -1

#region SETGET

func set_toggle_mode(value):
	toggle_mode = value
	button_pressed = false
	update_configuration_warning()


func set_disabled(value):
	disabled = value
	if disabled:
		button_pressed = false


func set_button_pressed(value):
	if value:
		button_pressed = true
		_emit_pressed()
	else:
		if toggle_mode and is_instance_valid(button_group):
			if !button_group.allow_unpress and !value:
				return
		button_pressed = false
		_touch_index = -1
		_emit_released()


func set_action_mode(value):
	action_mode = value
func set_passby_press(value):
	passby_press = value
func set_pass_screen_drag(value):
	pass_screen_drag = value


func set_button_group(value):
	if button_group == value:
		return
	if is_instance_valid(button_group):
		button_group._buttons.erase(self)
		button_group.disconnect("pressed", self, "_on_group_button_pressed")
	button_group = value
	if is_instance_valid(value):
		if !(self in button_group._buttons):
			button_group._buttons.push_back(self)
			if !button_group.is_connected("pressed", self, "_on_group_button_pressed"):
				button_group.connect("pressed", self, "_on_group_button_pressed")
	update_configuration_warning()


func is_disabled():
	return disabled
func is_toggle_mode():
	return toggle_mode
func is_button_pressed():
	return button_pressed
func get_action_mode():
	return action_mode
func get_passby_press():
	return passby_press
func get_pass_screen_drag():
	return pass_screen_drag
func get_button_group():
	return button_group


#endregion


func _emit_pressed():
	if button_pressed:
		return
	
	emit_signal("button_down")
	emit_signal("toggled", true)
	
	if action_mode == ActionMode.ACTION_MODE_BUTTON_PRESS:
		emit_signal("pressed")
	
	if toggle_mode and is_instance_valid(button_group):
		button_group.emit_signal("pressed", self)


func _emit_released():
	if !button_pressed:
		return
	
	if toggle_mode and is_instance_valid(button_group):
		if !button_group.allow_unpress:
			return
	
	emit_signal("button_up")
	emit_signal("toggled", false)
	
	if action_mode == ActionMode.ACTION_MODE_BUTTON_PRESS:
		emit_signal("pressed")
		
	if toggle_mode and is_instance_valid(button_group):
		button_group.emit_signal("pressed", null)


func _on_group_button_pressed(button: TouchBaseButton):
	if button != self:
		set_pressed_no_signal(false)


func _init() -> void:
	if !is_connected("pressed", self, "_pressed"):
		connect("pressed", self, "_pressed")
	if !is_connected("toggled", self, "_toggled"):
		connect("toggled", self, "_toggled")
	if !is_connected("resized", self, "_on_resized"):
		connect("resized", self, "_on_resized")


func _input(event: InputEvent) -> void:
	if disabled:
		return
	if !Engine.is_editor_hint():
		# REGULAR
		if !toggle_mode and !passby_press:
			if event is InputEventScreenTouch:
				if event.pressed:
					if _in_rect(event.position):
						if !button_pressed:
							_touch_index = event.index
						if event.index == _touch_index:
							self.button_pressed = true
#						else:
#							self.button_pressed = false
				if _touch_index == event.index and !event.pressed:
					self.button_pressed = false
			# Pass drag events to, as examle, look controller panel
			if pass_screen_drag:
				if event is InputEventScreenDrag:
					if button_pressed and event.index == _touch_index:
						emit_signal("drag_input", event)
		# PASS-BY
		elif !toggle_mode and passby_press:
			# Touch
			if event is InputEventScreenTouch:
				if event.is_pressed() and !event.is_echo():
					if _in_rect(event.position):
						if !button_pressed:
							_touch_index = event.index
						if event.index == _touch_index:
							self.button_pressed = true
						else:
							self.button_pressed = false
				if event.is_released() and event.index == _touch_index:
					self.button_pressed = false
			# Drag
			if event is InputEventScreenDrag:
				if !button_pressed:
					if _in_rect(event.position):
						self.button_pressed = true
						_touch_index = event.index
				elif event.index == _touch_index:
					if !_in_rect(event.position):
						self.button_pressed = false
		# TOGGLE
		if toggle_mode and !passby_press:
				if event is InputEventScreenTouch:
					if event.is_pressed():
						if _in_rect(event.position):
							if !button_pressed:
								_touch_index = event.index
							if event.index == _touch_index:
								if button_pressed:
									self.button_pressed = false
								else:
									self.button_pressed = true


func get_touch_index():
	return _touch_index


func get_draw_mode() -> int:
	if disabled:
		return DrawMode.DRAW_DISABLED
	if button_pressed:
		return DrawMode.DRAW_PRESSED
	return DrawMode.DRAW_NORMAL


func set_pressed_no_signal(p_pressed: bool) -> void:
	self.button_pressed = p_pressed


func _pressed() -> void: pass
func _toggled(toggled_on: bool) -> void: pass


func _on_resized():
	rect_pivot_offset = rect_size / 2


func _in_rect(point: Vector2, global := true):
	if global:
		return get_global_rect().has_point(point)
	return get_rect().has_point(point)


func _get_configuration_warning():
	if is_instance_valid(button_group) and !toggle_mode:
		return tr("ButtonGroup is intended to be used only with buttons that have toggle_mode set to true.")
	return ""

var _redraw_timer := 0.0
const _REDRAW_FRAMES = 10

func _process(delta: float) -> void:
	_redraw_timer += delta
	#printt(roundi(1 / delta), roundi(_REDRAW_FRAMES))
	if _redraw_timer >= 1 / _REDRAW_FRAMES:
		update()
		_redraw_timer -= 1 / _REDRAW_FRAMES
