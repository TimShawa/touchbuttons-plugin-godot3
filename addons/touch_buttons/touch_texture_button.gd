tool
class_name TouchTextureButton, "res://addons/touch_buttons/icons/icon_touch_texture_button.png"
extends TouchBaseButton

enum StretchMode {
	STRETCH_SCALE,
	STRETCH_TILE,
	STRETCH_KEEP,
	STRETCH_KEEP_CENTERED,
	STRETCH_KEEP_ASPECT,
	STRETCH_KEEP_ASPECT_CENTERED,
	STRETCH_KEEP_ASPECT_COVERED
}

var expand := false setget set_expand, get_expand
var stretch_mode: int = StretchMode.STRETCH_SCALE setget set_stretch_mode, get_stretch_mode
var flip_h := false setget set_flip_h, is_flipped_h
var flip_v := false setget set_flip_v, is_flipped_v

var texture_normal: Texture setget set_texture_normal, get_texture_normal
var texture_hover: Texture setget set_texture_hover, get_texture_hover
var texture_pressed: Texture setget set_texture_pressed, get_texture_pressed
var texture_disabled: Texture setget set_texture_disabled, get_texture_disabled
var texture_focused: Texture setget set_texture_focused, get_texture_focused
var texture_click_mask: BitMap setget set_texture_click_mask, get_texture_click_mask

func _get_property_list():
	return [
		{ name = "TouchTextureButton", type = TYPE_NIL, usage = PROPERTY_USAGE_CATEGORY },
		{ name = "expand", type = TYPE_BOOL },
		{ name = "stretch_mode", type = TYPE_INT, hint = PROPERTY_HINT_ENUM, hint_string = "Scale,Tile,Keep,Keep Centered,Keep Aspect,Keep Aspect Centered,Keep Aspect Covered" },
		{ name = "flip_h", type = TYPE_BOOL },
		{ name = "flip_v", type = TYPE_BOOL },
		{ name = "Textures", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP },
		{ name = "texture_normal", type = TYPE_OBJECT, hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = "Texture" },
		{ name = "texture_pressed", type = TYPE_OBJECT, hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = "Texture" },
		{ name = "texture_hover", type = TYPE_OBJECT, hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = "Texture" },
		{ name = "texture_disabled", type = TYPE_OBJECT, hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = "Texture" },
		{ name = "texture_focused", type = TYPE_OBJECT, hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = "Texture" },
		{ name = "texture_click_mask", type = TYPE_OBJECT, hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = "BitMap" }
	]

var _texture_region := Rect2()
var _position_rect := Rect2()
var _tile := false


#region SETGET

func set_expand(value):
	expand = value
	minimum_size_changed()


func set_stretch_mode(value):
	stretch_mode = value


func set_flip_h(value):
	flip_h = value


func set_flip_v(value):
	flip_v = value


func set_texture_normal(value):
	texture_normal = value
	_texture_changed()


func set_texture_hover(value):
	texture_hover = value
	_texture_changed()


func set_texture_pressed(value):
	texture_pressed = value
	_texture_changed()


func set_texture_disabled(value):
	texture_disabled = value
	_texture_changed()


func set_texture_focused(value):
	texture_focused = value
	_texture_changed()


func set_texture_click_mask(value):
	texture_click_mask = value
	_texture_changed()


func get_expand():
	return expand
func get_stretch_mode():
	return stretch_mode
func is_flipped_h():
	return flip_h
func is_flipped_v():
	return flip_v
func get_texture_normal():
	return texture_normal
func get_texture_hover():
	return texture_hover
func get_texture_pressed():
	return texture_pressed
func get_texture_disabled():
	return texture_disabled
func get_texture_focused():
	return texture_focused
func get_texture_click_mask():
	return texture_click_mask

#endregion


func _get_stretch_mode():
	if expand:
		return stretch_mode
	return StretchMode.STRETCH_KEEP


func _notification(p_what: int) -> void:
	match p_what:
		NOTIFICATION_DRAW:
			var draw_mode: int = get_draw_mode();
			if draw_mode == DrawMode.DRAW_HOVER_PRESSED:
				draw_mode = DrawMode.DRAW_PRESSED
			
			var texdraw: Texture
			
			match draw_mode:
				DrawMode.DRAW_NORMAL:
					if is_instance_valid(texture_normal):
						texdraw = texture_normal
				DrawMode.DRAW_PRESSED:
					if texture_pressed == null:
						if texture_hover == null:
							if is_instance_valid(texture_normal):
								texdraw = texture_normal
						else:
							texdraw = texture_hover
					else:
						texdraw = texture_pressed
				DrawMode.DRAW_HOVER:
					if texture_hover == null:
						if is_instance_valid(texture_pressed) and is_button_pressed():
							texdraw = texture_pressed
						elif is_instance_valid(texture_normal):
							texdraw = texture_normal
					else:
						texdraw = texture_hover
				DrawMode.DRAW_DISABLED:
					if texture_disabled == null:
						if is_instance_valid(texture_normal):
							texdraw = texture_normal
					else:
						texdraw = texture_disabled
			
			var ofs: Vector2
			var size: Vector2
			
			if is_instance_valid(texdraw):
				size = texdraw.get_size()
				_texture_region = Rect2(Vector2(), texdraw.get_size())
				_tile = false
				match _get_stretch_mode():
					StretchMode.STRETCH_KEEP:
						size = texdraw.get_size()
					StretchMode.STRETCH_SCALE:
						size = self.rect_size
					StretchMode.STRETCH_TILE:
						size = self.rect_size
						_tile = true
					StretchMode.STRETCH_KEEP_CENTERED:
						ofs = (self.rect_size - texdraw.get_size()) / 2
						size = texdraw.get_size()
					StretchMode.STRETCH_KEEP_ASPECT:
						var _size := self.rect_size
						var tex_width: float = texdraw.get_width() * _size.y / texdraw.get_height()
						var tex_height: float = _size.y
						if tex_width > _size.x:
							tex_width = _size.x
							tex_height = texdraw.get_height() * tex_width / texdraw.get_width()
						size.x = tex_width
						size.y = tex_height
					StretchMode.STRETCH_KEEP_ASPECT_CENTERED:
						var _size := self.rect_size
						var tex_width: float = texdraw.get_width() * _size.y / texdraw.get_height()
						var tex_height: float = _size.y
						if tex_width > _size.x:
							tex_width = _size.x
							tex_height = texdraw.get_height() * tex_width / texdraw.get_width()
						ofs.x = (_size.x - tex_width) / 2
						ofs.y = (_size.y - tex_height) / 2
						size.x = tex_width
						size.y = tex_height
					StretchMode.STRETCH_KEEP_ASPECT_COVERED:
						size = self.rect_size
						var tex_size = texdraw.get_size()
						var scale_size := Vector2(size.x / tex_size.x, size.y / tex_size.y)
						var scale: float = scale_size.x if scale_size.x > scale_size.y else scale_size.y
						var scaled_tex_size = tex_size * scale
						var ofs2 = ((scaled_tex_size - size) / scale).abs() / 2.0
						_texture_region = Rect2(ofs2, size / scale)
				
				_position_rect = Rect2(ofs, size);
				
				size.x *= -1.0 if flip_h else 1.0
				size.y *= -1.0 if flip_v else 1.0
				
				if _tile:
					draw_texture_rect(texdraw, Rect2(ofs, size), _tile)
				else:
					draw_texture_rect_region(texdraw, Rect2(ofs, size), _texture_region)
			else:
				_position_rect = Rect2()


func _texture_changed():
	update()
	minimum_size_changed()


func _get_minimum_size():
	var rscale = Vector2()
	
	if (!expand):
		if texture_normal == null:
			if texture_pressed == null:
				if texture_click_mask == null:
					rscale = Vector2()
				else:
					rscale = texture_click_mask.get_size()
			else:
				rscale = texture_pressed.get_size()
		else:
			rscale = texture_normal.get_size()

	return rscale.abs()


func has_point(p_point: Vector2):
	if is_instance_valid(texture_click_mask):
		var point := p_point
		var rect: Rect2
		var mask_size = texture_click_mask.get_size()
		
		if _position_rect.has_no_area():
			rect.size = mask_size
		elif _tile:
			if _position_rect.has_point(point):
				var cols: int = ceil(_position_rect.size.x / mask_size.x)
				var rows: int = ceil(_position_rect.size.y / mask_size.y)
				var col: int = int(point.x / mask_size.x) % cols
				var row: int = int(point.y / mask_size.y) % rows
				point.x -= mask_size.x * col
				point.y -= mask_size.y * row
		else:
			var ofs: Vector2 = _position_rect.position
			var scale: Vector2 = mask_size / _position_rect.size
			if _get_stretch_mode() == StretchMode.STRETCH_KEEP_ASPECT_COVERED:
				var _min = min(scale.x, scale.y)
				scale.x = _min
				scale.y = _min
				ofs -= _texture_region.position / _min
			
			point -= ofs
			point *= scale
			
			rect.position = Vector2(max(0, _texture_region.position.x), max(0, _texture_region.position.y))
			rect.size = Vector2(min(mask_size.x, _texture_region.size.x), min(mask_size.y, _texture_region.size.y))
		
		if !rect.has_point(point):
			return false
		
		return texture_click_mask.get_bitv(point)
	
	return get_global_rect().has_point(p_point)
