tool
class_name TouchBaseButton, "res://addons/touch_buttons/icons/icon_touch_base_button.png"
extends Control


signal button_down
signal button_up
signal pressed
signal toggled(toggled_on)
signal drag_input(event)


enum PressMode { MODE_CLICK, MODE_TOGGLE, MODE_PASSBY_PRESS }
enum ActionMode { ACTION_MODE_BUTTON_PRESS, ACTION_MODE_BUTTON_RELEASE }
enum DrawMode { DRAW_NORMAL, DRAW_HOVER, DRAW_PRESSED, DRAW_DISABLED, DRAW_HOVER_PRESSED }


var disabled := false setget set_disabled, is_disabled
var button_pressed := false setget set_button_pressed, is_button_pressed
var press_mode: int = PressMode.MODE_CLICK
var action_mode: int = ActionMode.ACTION_MODE_BUTTON_RELEASE setget set_action_mode, get_action_mode
var pass_screen_drag := false setget set_pass_screen_drag, get_pass_screen_drag
var button_group: TouchButtonGroup setget set_button_group, get_button_group
var mouse_enabled := true
var mouse_button_mask: int = BUTTON_MASK_LEFT

func _get_property_list():
	return [
		{ name = "TouchBaseButton", type = TYPE_NIL, usage = PROPERTY_USAGE_CATEGORY },
		{ name = "disabled", type = TYPE_BOOL },
		{ name = "press_mode", type = TYPE_INT, hint = PROPERTY_HINT_ENUM, hint_string = "Click,Toggle,Pass-by Press" },
		{ name = "button_pressed", type = TYPE_BOOL },
		{ name = "action_mode", type = TYPE_INT, hint = PROPERTY_HINT_ENUM, hint_string = "Button Press,Button Release" },
		{
			name = "pass_screen_drag", type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT if press_mode == PressMode.MODE_CLICK else PROPERTY_USAGE_STORAGE
		},
		{ name = "mouse_enabled", type = TYPE_BOOL },
		{
			name = "mouse_button_mask", type = TYPE_INT,
			hint = PROPERTY_HINT_FLAGS, hint_string = "Left,Right,Middle",
			usage = PROPERTY_USAGE_DEFAULT if mouse_enabled else PROPERTY_USAGE_STORAGE
		},
		{ name = "button_group", type = TYPE_OBJECT, hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = "Resource" }
	]

var _touch_index := -1
var _mouse_mode := false
var _was_pressed_by_mouse := false


#region SETGET

func set_disabled(value):
	disabled = value
	if disabled and !is_toggle_mode():
		button_pressed = false


func set_press_mode(value):
	if press_mode != value:
		self.button_pressed = false
		_touch_index = false
		_was_pressed_by_mouse = false
	press_mode = value
	property_list_changed_notify()


func set_button_pressed(value):
	if value:
		button_pressed = true
		_emit_pressed()
		_unpress_group()
	else:
		var can_unpress = true
		if is_toggle_mode() and is_instance_valid(button_group):
			if !button_group.allow_unpress:
				can_unpress = false
				for i in button_group.get_buttons():
					if i == self:
						continue
					if i.is_button_pressed():
						can_unpress = true
						break
		if can_unpress:
			button_pressed = false
			_touch_index = -1
			_was_pressed_by_mouse = false
			_emit_released()


func set_action_mode(value):
	action_mode = value


func set_pass_screen_drag(value):
	pass_screen_drag = value


func set_button_group(value):
	if button_group == value:
		return
	if is_instance_valid(button_group):
		button_group._buttons.erase(self)
	button_group = value
	if is_instance_valid(button_group):
		if !(self in button_group._buttons):
			button_group._buttons.push_back(self)
	update_configuration_warning()


func set_mouse_enabled(value):
	mouse_enabled = value
	property_list_changed_notify()


func set_mouse_button_mask(value):
	mouse_button_mask = value


func is_disabled():
	return disabled
func is_button_pressed():
	return button_pressed
func get_press_mode():
	return press_mode
func get_action_mode():
	return action_mode
func get_pass_screen_drag():
	return pass_screen_drag
func get_button_group():
	return button_group
func is_mouse_enabled():
	return mouse_enabled


#endregion


func is_toggle_mode():
	return press_mode == PressMode.MODE_TOGGLE


func get_passby_press():
	return press_mode == PressMode.MODE_PASSBY_PRESS


func _emit_pressed():
	emit_signal("button_down")

	if press_mode != PressMode.MODE_CLICK:
		emit_signal("toggled", true)
		if is_toggle_mode():
			if is_instance_valid(button_group):
				button_group.emit_signal("pressed", self)
	
	if action_mode == ActionMode.ACTION_MODE_BUTTON_PRESS:
		emit_signal("pressed")


func _emit_released():
	emit_signal("button_up")
	
	if press_mode != PressMode.MODE_CLICK:
		emit_signal("toggled", false)
	
	if action_mode == ActionMode.ACTION_MODE_BUTTON_PRESS:
		emit_signal("pressed")


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	if !is_connected("pressed", self, "_pressed"):
		connect("pressed", self, "_pressed")
	if !is_connected("toggled", self, "_toggled"):
		connect("toggled", self, "_toggled")
	if !is_connected("resized", self, "_on_resized"):
		connect("resized", self, "_on_resized")


func _input(event: InputEvent) -> void:
	if disabled:
		return
	
	if event.device == -1:
		return
	
	if !Engine.editor_hint:
		
		if event is InputEventAction:
			if event.action == "ui_accept":
				self.button_press = true
				self.button_press = false
		
		if event is InputEventScreenTouch or event is InputEventScreenDrag:
			if !_was_pressed_by_mouse and !is_button_pressed():
				_mouse_mode = false
		if event is InputEventMouse:
			if _was_pressed_by_mouse or !is_button_pressed():
				_mouse_mode = true
		
		match press_mode:
		
			PressMode.MODE_CLICK:
				if event is InputEventScreenTouch:
					if event.is_pressed() and !is_button_pressed(): # PRESS
						if _has_point(event.position):
							self.button_pressed = true
							_touch_index = event.index
					if event.is_released() and is_button_pressed(): # RELEASE
						if !_was_pressed_by_mouse:
							if event.index == _touch_index:
								self.button_pressed = false

				if event is InputEventMouseButton:
					if mouse_button_mask & _get_button_mask(event.button_index):
						if event.is_pressed() and !is_button_pressed(): # PRESS
							if _has_point(event.position):
								self.button_pressed = true
								_was_pressed_by_mouse = true
						if event.is_released() and is_button_pressed(): # RELEASE
							if _was_pressed_by_mouse:
								self.button_pressed = false

				if pass_screen_drag:

					if event is InputEventScreenDrag:
						if is_button_pressed():
							emit_signal("drag_input", event.duplicate())

					if event is InputEventMouseMotion:
						if is_button_pressed():
							var drag = InputEventScreenDrag.new()

							for i in [
								"index",
								"position",
								"relative",
								"speed",
								"device"
							]:
								if i in event:
									drag.set(i, event.get(i))
							
							emit_signal("drag_input", drag)
			
			PressMode.MODE_TOGGLE:
				
				if event is InputEventScreenTouch:
					if _has_point(event.position):
						if event.is_pressed():
							self.button_pressed = not button_pressed
				
				if event is InputEventMouseButton:
					if mouse_button_mask & _get_button_mask(event.button_index):
						if event.is_pressed():
							if _has_point(event.position):
								self.button_pressed = not button_pressed

			PressMode.MODE_PASSBY_PRESS:

				if event is InputEventScreenTouch:
					if _has_point(event.position):
						if event.is_pressed() and !is_button_pressed(): # PRESS
							self.button_pressed = true
							_touch_index = event.index
						if event.is_released() and is_button_pressed(): # RELEASE
							if !_was_pressed_by_mouse:
								if _touch_index == event.index:
									self.button_pressed = false
				
				if event is InputEventScreenDrag:
					if !is_button_pressed() and _has_point(event.position): # ENTER
						self.button_pressed = true
						_touch_index = event.index
					if is_button_pressed() and !_has_point(event.index): # EXIT
						if !_was_pressed_by_mouse:
							if event.index == _touch_index:
								self.button_pressed = false

				if event is InputEventMouseButton:
					if mouse_button_mask & _get_button_mask(event.button_index):
						if event.is_pressed() and !is_button_pressed(): # PRESS
							self.button_pressed = true
							_was_pressed_by_mouse = true
						if event.is_released() and is_button_pressed(): # RELEASE
							if _was_pressed_by_mouse:
								self.button_pressed = false

				if event is InputEventMouseMotion:
					print(event.button_mask)
					if mouse_button_mask & _get_button_mask(event.button_index):
						if _has_point(event.position) and !is_button_pressed(): # ENTER
							self.button_pressed = true
							_was_pressed_by_mouse = true
						if !_has_point(event.position) and is_button_pressed(): # EXIT
							if _was_pressed_by_mouse:
								self.button_pressed = false


func is_hovered() -> bool:
	return !Engine.editor_hint and _mouse_mode and _has_point(get_global_mouse_position())


func get_touch_index():
	return _touch_index


func get_draw_mode() -> int:
	if disabled:
		return DrawMode.DRAW_DISABLED
	if button_pressed:
		if is_hovered():
			return DrawMode.DRAW_HOVER_PRESSED
		return DrawMode.DRAW_PRESSED
	if is_hovered():
		return DrawMode.DRAW_HOVER
	return DrawMode.DRAW_NORMAL


func set_pressed_no_signal(p_pressed: bool) -> void:
	if not is_blocking_signals():
		set_block_signals(true)
		self.button_pressed = p_pressed
		_touch_index = -1
		_was_pressed_by_mouse = false
		set_block_signals(false)
	self.button_pressed = p_pressed
	_touch_index = -1
	_was_pressed_by_mouse = false


func _pressed() -> void: pass
func _toggled(toggled_on: bool) -> void: pass


func _on_resized():
	rect_pivot_offset = rect_size / 2


func _has_point(point: Vector2) -> bool:
	return get_global_rect().has_point(point)


func _get_configuration_warning():
	if is_instance_valid(button_group) and !is_toggle_mode():
		return tr("ButtonGroup is intended to be used only with buttons that have toggle_mode set to true.")
	return ""


var _redraw_timer := 0.0
const _REDRAW_FRAMES = 10

func _process(delta: float) -> void:
	_redraw_timer += delta
	if _redraw_timer >= 1 / _REDRAW_FRAMES:
		update()
		_redraw_timer -= 1 / _REDRAW_FRAMES


func _unpress_group():
	if is_instance_valid(button_group):
		for button in button_group.get_buttons():
			if button == self:
				continue
			if button.is_toggle_mode():
				button.set_pressed_no_signal(false)
				button._emit_released()


func _get_button_mask(index: int) -> int:
	if index <= 0:
		return 0
	return int(pow(2, index - 1))
