# touchbuttons-plugin-godot3
This plugin for Godot Engine 3.5+ adds TouchBaseButton class and its subclasses. TouchButtons are roughly similar to its native BaseButton-deriver buttons but have some differences, such as:
- Most valuable: TouchButtons support multitouch.
- TouchButtons have not `hovered`, `focused` and other associated states by the reason of its usage (touchscreens).
- There's no support of shortcuts, but it might be added in the future.
- Appearance manipulation (theme) differ with native buttons' one according to Engine limitations. See [Change Appearance](#change-appearance) for more information.

Most of buttons functionality can be found in the native Buttons docs. There is some additional options:
- (when `toggle_mode` is `true`) Pass-by Press: Button become pressed when finger enters its pressable area and become released when finger exits.
- Pass Screen Drag: Button forwards any recieved screen drag input event with `drag_input` signal.
- TouchButtons use **TouchButtonGroup**s instead of native ButtonGroup resource, because ButtonGroups support only built-in Buttons.

## Change appearance
Any TouchButton automatically loads default buttons' theme, located at `res://addons/touch_buttons/buttons.theme`.
If you want to change the button appearance, attach any *Theme* resource to the button (`theme` property) or create a new one, if needed. All changes in theme will affect the button view (excluding `check_vadjust` property of *TouchCheckButton* and *TouchCheckBox* because it's not currently implemented).
\
Theme parameters (same as native):
- TouchButton:

  Colors:
  - `font_color`
  - `font_color_pressed`
  - `font_color_disabled`
  - `icon_color_normal`
  - `icon_color_pressed`
  - `icon_color_disabled`
  
  Constants:
  - `hseparation`

  Fonts:
  - `font`
  
  Icons:
  - `icon`
  
  Styles:
  - `normal`
  - `pressed`
  - `disabled`

- TouchCheckBox:

  Colors:
  - `font_color`
  - `font_color_pressed`
  - `font_color_disabled`
  
  Constants:
  - `hseparation`
  - `check_vadjust` (currently helpless)

  Fonts:
  - `font`
  
  Icons:
  - `icon`
  
  Styles:
  - `normal`
  - `pressed`
  - `disabled`

- TouchCheckButton:

  Colors:
  - `font_color`
  - `font_color_pressed`
  - `font_color_disabled`
  
  Constants:
  - `hseparation`
  - `check_vadjust` (currently helpless)

  Fonts:
  - `font`
  
  Icons:
  - `icon`
  
  Styles:
  - `normal`
  - `pressed`
  - `disabled`
