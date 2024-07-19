tool
class_name TouchSlider extends TouchRange


signal drag_started()
signal drag_ended(value_changed)


var editable: bool = true setget set_editable, is_editable
var scrollable: bool = true setget set_scrollable, is_scrollable
var tick_count: int = 0 setget set_tick_count, get_tick_count
var ticks_on_borders: bool = false setget set_ticks_on_borders, get_ticks_on_borders

func _get_property_list():
	return [
		{ name = "editable", type = TYPE_BOOL },
		{ name = "scrollable", type = TYPE_BOOL },
		{
			name = "tick_count", type = TYPE_INT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "%s,%s,%s,or_greater" % [0, floor((max_value - min_value) / step), 1]
		},
		{ name = "ticks_on_borders", type = TYPE_BOOL }
	]

var _orientation: int = HORIZONTAL

var _grab: Grab = Grab.new() setget , _get_grab
func _get_grab():
	if _grab == null:
		_grab = Grab.new()
	return _grab

var _theme_cache: ThemeCache = ThemeCache.new() setget , _get_theme_cache
func _get_theme_cache():
	if _theme_cache == null:
		_theme_cache = ThemeCache.new()
	if _theme_cache._theme_type != _theme_type:
		_theme_cache._theme_type = _theme_type
	if _theme_cache._theme_type_variation != theme_type_variation:
		_theme_cache._theme_type_variation = theme_type_variation
	return _theme_cache

var _theme_type: String = "TouchSlider" setget _set_theme_type
func _set_theme_type(value):
	_theme_type = value
	_theme_cache._theme_type = _theme_type

var _touch_index: int = -1
var _was_pressed_by_mouse: bool = false


#region SETGET

func set_editable(value):
	editable = value
	update()

func is_editable():
	return editable


func set_scrollable(value):
	scrollable = value

func is_scrollable():
	return scrollable


func set_tick_count(value):
	if value == tick_count:
		return
	tick_count = value
	update()

func get_tick_count():
	return tick_count


func set_ticks_on_borders(value):
	if value != ticks_on_borders:
		ticks_on_borders = value
		update()

func get_ticks_on_borders():
	return ticks_on_borders

#endregion


func _init():
	_validate_shared()
	set_focus_mode(Control.FOCUS_ALL)
	step = 1.0


func _get_minimum_size():
	if _theme_type == "TouchSlider":
		return Vector2.ZERO
	
	var ss: Vector2 = _theme_cache.slider_style.get_minimum_size()
	var rs: Vector2 = _theme_cache.grabber_icon.get_size()
	
	if _orientation == HORIZONTAL:
		return Vector2(ss.x, max(ss.y, rs.y))
	else:
		return Vector2(max(ss.x, rs.x), ss.y)


func _set(property, value):
	if property == "theme_type_variation":
		_theme_cache._theme_type_variation = value
	return false


func _gui_input(event):
	if Engine.is_editor_hint():
		return
	
	if event.device == -1:
		return
	
	if !editable:
		return
	
	# Click
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				_was_pressed_by_mouse = true
				var grabber: Texture
				if get_global_rect().has_point(event.global_position) or has_focus():
					grabber = _theme_cache.grabber_hl_icon
				else:
					grabber = _theme_cache.grabber_icon
				
				_grab.pos = event.position.y if _orientation == VERTICAL else event.position.x
				_grab.value_before_dragging = get_as_ratio()
				emit_signal("drag_started")
				
				var grab_width: float = 0.0 if _theme_cache.center_grabber else float(grabber.get_width())
				var grab_height: float = 0.0 if _theme_cache.center_grabber else float(grabber.get_height())
				var MAX = rect_size.y - grab_height if _orientation == VERTICAL else rect_size.x - grab_width
				set_block_signals(true)
				
				if _orientation == VERTICAL:
					set_as_ratio(1 - (float(_grab.pos) - (grab_height / 2.0)) / MAX)
				else:
					set_as_ratio((float(_grab.pos) - (grab_width / 2.0)) / MAX)
				
				set_block_signals(false)
				_grab.active = true
				_grab.uvalue = get_as_ratio()
				emit_signal("value_changed")
				grab_focus()
				
			elif _was_pressed_by_mouse:
				_was_pressed_by_mouse = false
				_grab.active = false
				var value_changed = !is_equal_approx(float(_grab.value_before_dragging), get_as_ratio())
				emit_signal("drag_ended", value_changed)
	
	# Motion
	if event is InputEventMouseMotion:
		if _grab.active:
			var grabber: Texture = _theme_cache.grabber_hl_icon
			var grab_width: float = 0.0 if _theme_cache.center_grabber else float(grabber.get_width())
			var grab_height: float = 0.0 if _theme_cache.center_grabber else float(grabber.get_height())
			var motion: float = (event.position.y if _orientation == VERTICAL else event.position.x) - _grab.pos
			if _orientation == VERTICAL:
				motion = -motion
			var areasize: float = rect_size.y - grab_height if _orientation == VERTICAL else rect_size.x - grab_width
			if areasize <= 0:
				return
			var umotion: float = motion / float(areasize)
			set_as_ratio(_grab.uvalue + umotion)
	
	# Touch
	if event is InputEventScreenTouch:
		if event.is_pressed():
			_touch_index = event.index
			var grabber: Texture
			if get_rect().has_point(event.position) or has_focus():
				grabber = _theme_cache.grabber_hl_icon
			else:
				grabber = _theme_cache.grabber_icon
			
			_grab.pos = event.position.y if _orientation == VERTICAL else event.position.x
			_grab.value_before_dragging = get_as_ratio()
			emit_signal("drag_started")
			
			var grab_width: float = 0.0 if _theme_cache.center_grabber else float(grabber.get_width())
			var grab_height: float = 0.0 if _theme_cache.center_grabber else float(grabber.get_height())
			var MAX = rect_size.y - grab_height if _orientation == VERTICAL else rect_size.x - grab_width
			set_block_signals(true)
			
			if _orientation == VERTICAL:
				set_as_ratio(1 - (float(_grab.pos) - (grab_height / 2.0)) / MAX)
			else:
				set_as_ratio((float(_grab.pos) - (grab_width / 2.0)) / MAX)
			
			set_block_signals(false)
			_grab.active = true
			_grab.uvalue = get_as_ratio()
			emit_signal("value_changed")
			grab_focus()
			
		elif !_was_pressed_by_mouse:
			if event.index == _touch_index:
				_touch_index = -1
				_grab.active = false
				var value_changed = !is_equal_approx(float(_grab.value_before_dragging), get_as_ratio())
				emit_signal("drag_ended", value_changed)
	
	# Drag
	if event is InputEventScreenDrag:
		if _grab.active:
			if !_was_pressed_by_mouse and _touch_index == event.index:
				var grabber: Texture = _theme_cache.grabber_hl_icon
				var grab_width: float = 0.0 if _theme_cache.center_grabber else float(grabber.get_width())
				var grab_height: float = 0.0 if _theme_cache.center_grabber else float(grabber.get_height())
				var motion: float = (event.position.y if _orientation == VERTICAL else event.position.x) - _grab.pos
				if _orientation == VERTICAL:
					motion = -motion
				var areasize: float = rect_size.y - grab_height if _orientation == VERTICAL else rect_size.x - grab_width
				if areasize <= 0:
					return
				var umotion: float = motion / float(areasize)
				set_as_ratio(_grab.uvalue + umotion)
	
	# Mouse wheel scrolling
	if event is InputEventMouseButton:
		if scrollable and !_grab.active:
			if event.is_pressed() and event.button_index == BUTTON_WHEEL_UP:
				if focus_mode != FOCUS_NONE:
					grab_focus()
				set_value(get_value() + get_step())
			elif event.is_pressed() and event.button_index == BUTTON_WHEEL_DOWN:
				if focus_mode != FOCUS_NONE:
					grab_focus()
				set_value(get_value() - get_step())


func _notification(what):
	match what:
		NOTIFICATION_THEME_CHANGED:
			_theme_cache._theme = theme
			minimum_size_changed()
			update()
		
		NOTIFICATION_MOUSE_ENTER:
			update()
		
		NOTIFICATION_MOUSE_EXIT:
			update()
		
		NOTIFICATION_VISIBILITY_CHANGED, NOTIFICATION_EXIT_TREE:
			_grab.active = false
		
		NOTIFICATION_DRAW:
			if _theme_type == "TouchSlider":
				return
			
			var ci: RID = get_canvas_item()
			var ratio: float = 0 if is_nan(get_as_ratio()) else get_as_ratio()
			
			var style = _theme_cache.slider_style
			var tick = _theme_cache.tick_icon
			
			var highlighted = editable and (get_global_rect().has_point(get_global_mouse_position()) or has_focus())
			var grabber: Texture
			if editable:
				if highlighted:
					grabber = _theme_cache.grabber_hl_icon
				else:
					grabber = _theme_cache.grabber_icon
			else:
				grabber = _theme_cache.grabber_disabled_icon
			
			var grabber_area: StyleBox
			if highlighted:
				grabber_area = _theme_cache.grabber_area_hl_style
			else:
				grabber_area = _theme_cache.grabber_area_style
			
			if _orientation == VERTICAL:
				var widget_width: int = style.get_minimum_size().x
				var areasize: float = rect_size.y - (0 if _theme_cache.center_grabber else grabber.get_height())
				var grabber_shift: int = grabber.get_height() if _theme_cache.center_grabber else 0
				style.draw(ci, Rect2(Vector2(rect_size.x / 2 - widget_width / 2, 0), Vector2(widget_width, rect_size.y)))
				grabber_area.draw(ci, Rect2(
					Vector2((rect_size.x - widget_width) / 2, rect_size.y - areasize * ratio - grabber.get_height() / 2 + grabber_shift),
					Vector2(widget_width, areasize * ratio + grabber.get_height() / 2 - grabber_shift)
				))
				
				if tick_count > 1:
					var grabber_offset: int = (grabber.get_height() / 2 - tick.get_height() / 2)
					for i in tick_count:
						if !ticks_on_borders and (i == 0 or i == tick_count - 1):
							continue
						var ofs: int = (i * areasize / (tick_count - 1)) + grabber_offset - grabber_shift
						tick.draw(ci, Vector2((rect_size.x - widget_width) / 2, ofs))
				
				grabber.draw(ci, Vector2(
					rect_size.x / 2 - grabber.get_width() / 2 + _theme_cache.grabber_offset,
					rect_size.y - ratio * areasize - grabber.get_height() + grabber_shift
				))
			else:
				var widget_height = style.get_minimum_size().y
				var areasize: float = rect_size.x - (0 if _theme_cache.center_grabber else grabber.get_width())
				var grabber_shift = -grabber.get_width() / 2 if  _theme_cache.center_grabber else 0
				
				style.draw(ci, Rect2(Vector2(0, (rect_size.y - widget_height) / 2), Vector2(rect_size.x, widget_height)))
				grabber_area.draw(ci, Rect2(
					Vector2(0, (rect_size.y - widget_height) / 2),
					Vector2(areasize * ratio + grabber.get_width() / 2 + grabber_shift, widget_height)
				))
				
				if tick_count > 1:
					var grabber_offset: int = (grabber.get_width() / 2 - tick.get_width() / 2)
					for i in tick_count:
						if (!ticks_on_borders) and ((i == 0) or (i == tick_count - 1)):
							continue
						var ofs: int = (i * areasize / (tick_count - 1)) + grabber_offset + grabber_shift
						tick.draw(ci, Vector2(ofs, (rect_size.y - widget_height) / 2))
				
				grabber.draw(ci, Vector2(
					ratio * areasize + grabber_shift,
					rect_size.y / 2 - grabber.get_height() / 2 + _theme_cache.grabber_offset
				))


#region Structures

class Grab extends Resource:
	var pos: int = 0
	var uvalue: float = 0.0
	var value_before_dragging = 0.0
	var active = false

func _draw():
	return

class ThemeCache extends Resource:
	var _theme: Theme
	var _theme_type := ""
	var _theme_type_variation := ""
	
	var slider_style = StyleBoxEmpty.new() setget , get_slider_style
	func get_slider_style():
		return get_theme_item("style/slider")
	
	var grabber_area_style = StyleBoxEmpty.new() setget , get_grabber_area_style
	func get_grabber_area_style():
		return get_theme_item("style/grabber_area")
	
	var grabber_area_hl_style = StyleBoxEmpty.new() setget , get_grabber_area_hl_style
	func get_grabber_area_hl_style():
		return get_theme_item("style/grabber_area_highlight")
	
	
	var grabber_icon: Texture setget , get_grabber_icon
	func get_grabber_icon():
		return get_theme_item("icon/grabber")
	
	var grabber_hl_icon: Texture setget , get_grabber_hl_icon
	func get_grabber_hl_icon():
		return get_theme_item("icon/grabber_highlight")
	
	var grabber_disabled_icon: Texture setget , get_grabber_disabled_icon
	func get_grabber_disabled_icon(): return get_theme_item("icon/grabber_disabled")
	var tick_icon: Texture setget , get_tick_icon
	func get_tick_icon():
		return get_theme_item("icon/tick")
	
	
	var center_grabber: bool = false setget , get_center_grabber
	func get_center_grabber():
		return get_theme_item("constant/center_grabber")
	
	var grabber_offset: int = 0 setget , get_grabber_offset
	func get_grabber_offset():
		return get_theme_item("constant/grabber_offset")
	
	
	func get_theme_item(property):
		var theme: Theme
		if is_instance_valid(_theme):
			theme = _theme
		else:
			theme = preload("res://addons/touch_buttons/buttons_theme.tres")
		
		var item: String = property.get_slice("/", 1)
		var type = _theme_type if _theme_type_variation.empty() else _theme_type_variation
		
		match property.get_slice("/", 0):
			"color":
				if theme.has_color(item, type):
					return theme.get_color(item, type)
			"constant":
				if theme.has_constant(item, type):
					return theme.get_constant(item, type)
			"font":
				if theme.has_font(item, type):
					return theme.get_font(item, type)
			"font_size":
				if theme.has_font_size(item, type):
					return theme.get_font_size(item, type)
			"icon":
				if theme.has_icon(item, type):
					return theme.get_icon(item, type)
			"style":
				if theme.has_stylebox(item, type):
					return theme.get_stylebox(item, type)
#		print(property.get_slice("/", 0), " ", item)
		print(type)

#endregion

func _process(delta):
	update()
