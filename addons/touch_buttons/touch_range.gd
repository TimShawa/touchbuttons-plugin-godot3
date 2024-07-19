tool
class_name TouchRange extends Control

signal value_changed(value)
signal changed()


var min_value: float = 0.0 setget set_min, get_min
var max_value: float = 100.0 setget set_max, get_max
var step: float = 1 setget set_step, get_step
var page: float = 0 setget set_page, get_page
var value: float = 0 setget set_value, get_value
var ratio: float = 0.0 setget set_as_ratio, get_as_ratio
var exp_edit: bool = false setget set_exp_ratio, is_ratio_exp
var rounded: bool = false setget set_use_rounded_values, is_using_rounded_values
var allow_greater: bool = false setget set_allow_greater, is_greater_allowed
var allow_lesser: bool = false setget set_allow_greater, is_lesser_allowed


func _get_property_list():
	return [
		{ name = "TouchRange", type = TYPE_NIL, usage = PROPERTY_USAGE_CATEGORY },
		{ name = "min_value", type = TYPE_REAL },
		{ name = "max_value", type = TYPE_REAL },
		{ name = "step", type = TYPE_REAL },
		{ name = "value", type = TYPE_REAL },
		{
			name = "ratio", type = TYPE_REAL,
			hint = PROPERTY_HINT_RANGE, hint_string = "0,1,0.01",
			usage = PROPERTY_USAGE_NOEDITOR
		},
		{ name = "exp_edit", type = TYPE_BOOL },
		{ name = "rounded", type = TYPE_BOOL },
		{ name = "allow_greater", type = TYPE_BOOL },
		{ name = "allow_lesser", type = TYPE_BOOL }
	]


var _shared: _Shared = null
var _rounded_values = false


func _ref_shared(p_shared: _Shared) -> void:
	if _shared and p_shared == _shared:
		return
	_unref_shared()
	_shared = p_shared
	_shared.owners.push_back(self)


func _unref_shared() -> void:
	if _shared:
		_shared.owners.erase(self)
		if _shared.owners.size() == 0:
			_shared.free()
			_shared = null


func _share(p_range: Node) -> void:
	var r = p_range as Range
	if r != null:
		share(r)


func _value_changed_notify() -> void:
	_value_changed(_shared.val)
	emit_signal("value_changed", _shared.val)
	update()


func _changed_notify(p_what: String = "") -> void:
	emit_signal("changed")
	update()


func _set_value_no_signal(p_val: float) -> void:
	
	if is_inf(p_val):
		return
	if _shared.step > 0:
		p_val = round((p_val - _shared.min_val) / _shared.step) * _shared.step + _shared.min_val
	if _rounded_values:
		p_val = round(p_val)
	if !_shared.allow_greater and p_val > _shared.max_val - _shared.page:
		p_val = _shared.max_val - _shared.page
	if !_shared.allow_lesser and p_val < _shared.min_val:
		p_val = _shared.min_val
	if _shared.val == p_val:
		return
	_shared.val = p_val


func _value_changed(p_value: float) -> void: pass


func _notify_shared_value_changed() -> void:
	_shared.emit_value_changed()


func set_value(p_val: float) -> void:
	var prev_val := _shared.val
	_set_value_no_signal(p_val)
	if _shared.val != prev_val:
		_shared.emit_value_changed()


func set_value_no_signal(p_val: float) -> void:
	var prev_val = _shared.val
	_set_value_no_signal(p_val)
	if _shared.val != prev_val:
		_shared.redraw_owners()


func set_min(p_min: float) -> void:
	if _shared.min_val == p_min: return
	_shared.min_val = p_min
	_shared.max_val = max(_shared.max_val, _shared.min_val)
	_shared.page = clamp(_shared.page, 0, _shared.max_val - _shared.min_val)
	set_value(_shared.val)
	_shared.emit_changed("min_val")
	update_configuration_warning()


func set_max(p_max: float) -> void:
	var max_validated = max(p_max, _shared.min_val)
	if _shared.max_val == max_validated:
		return
	_shared.max_val = max_validated
	_shared.page = clamp(_shared.page, 0, _shared.max_val - _shared.min_val)
	set_value(_shared.val)
	_shared.emit_changed("max_val")


func set_step(p_step: float) -> void:
	if _shared.step == p_step: return
	_shared.step = p_step
	_shared.emit_changed("step")


func set_page(p_page: float) -> void:
	var page_validated = clamp(p_page, 0, _shared.max_val - _shared.min_val)
	if _shared.page == page_validated: return
	_shared.page = page_validated
	set_value(_shared.val)
	_shared.emit_changed("page")


func set_as_ratio(p_value: float) -> void:
	var v: float
	if _shared.exp_ratio and get_min() >= 0:
		var exp_min = 0.0 if (get_min() == 0) else log(get_min()) / log(2.0)
		var exp_max = log(get_max()) / log(2.0)
	else:
		var percent = (get_max() - get_min()) * p_value
		if get_step() > 0:
			var steps = round(percent / get_step())
			v = steps * get_step() + get_min()
		else:
			v = percent + get_min()
	v = clamp(v, get_min(), get_max())
	set_value(v)


func get_value() -> float:
	return _shared.val


func get_min() -> float:
	return _shared.min_val


func get_max() -> float:
	return _shared.max_val


func get_step() -> float:
	return _shared.step


func get_page() -> float:
	return _shared.page


func get_as_ratio() -> float:
	if is_equal_approx(get_max(), get_min()):
		return 1.0
	if _shared.exp_ratio and get_min() >= 0:
		var exp_min = 0.0 if (get_min() == 0) else log(get_min()) / log(2.0)
		var exp_max = log(get_max()) / log(2.0)
		var value = clamp(get_value(), _shared.min_val, _shared.max_val)
		var v = log(value) / log(2.0)
		return clamp((v - exp_min) / (exp_max - exp_min), 0, 1)
	else:
		var value = clamp(get_value(), _shared.min_val, _shared.max_val)
		return clamp((value - get_min()) / (get_max() - get_min()), 0, 1)


func set_use_rounded_values(p_enable: bool) -> void:
	_rounded_values = p_enable


func is_using_rounded_values() -> bool:
	return _rounded_values


func set_exp_ratio(p_enable: bool) -> void:
	if _shared.exp_ratio == p_enable:
		return
	_shared.exp_ratio = p_enable
	update_configuration_warning()


func is_ratio_exp() -> bool:
	return _shared.exp_ratio


func set_allow_greater(p_allow: bool) -> void:
	_shared.allow_greater = p_allow


func is_greater_allowed() -> bool:
	return _shared.allow_greater


func set_allow_lesser(p_allow: bool) -> void:
	_shared.allow_greater = p_allow


func is_lesser_allowed() -> bool:
	return _shared.allow_lesser


func share(p_range: Range) -> void:
	if p_range != null:
		p_range._ref_shared(_shared)
		p_range._changed_notify()
		p_range._value_changed_notify()


func unshare() -> void:
	var nshared := _Shared.new()
	nshared.min_val = _shared.min_val
	nshared.max_val = _shared.max_val
	nshared.val = _shared.val
	nshared.step = _shared.step
	nshared.page = _shared.page
	nshared.exp_ratio = _shared.exp_ratio
	nshared.allow_greater = _shared.allow_greater
	nshared.allow_lesser = _shared.allow_lesser
	_unref_shared()
	_ref_shared(nshared)


func _get_configuration_warning() -> String:
	var warning := ""
	if _shared.exp_ratio and _shared.min_val <= 0:
		warning = tr("If \"Exp Edit\" is enabled, \"Min Value\" must be greater than 0.")
	return warning


func _init():
	_validate_shared()
	size_flags_vertical = 0

func _ready():
	_validate_shared()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_unref_shared()


class _Shared extends Object:
	var val: float = 0.0
	var min_val: float = 0.0
	var max_val: float = 100.0
	var step: float = 1.0
	var page: float = 0.0
	var exp_ratio: bool = false
	var allow_greater: bool = false
	var allow_lesser: bool = false
	var owners: Array
	
	func emit_value_changed() -> void:
		for E in owners:
			if !E.is_inside_tree():
				continue
			E._value_changed_notify()
	
	func emit_changed(p_what: String = "") -> void:
		for E in owners:
			if !E.is_inside_tree():
				continue
			E._changed_notify(p_what)
	
	func redraw_owners() -> void:
		for E in owners:
			if !E.is_inside_tree():
				continue
			E.update()


func _validate_shared():
	if !_shared:
		_shared = _Shared.new()
		_shared.owners.push_back(self)
