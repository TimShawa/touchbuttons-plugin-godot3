# touchbuttons-plugin-godot3
This plugin for Godot Engine 3.x adds TouchBaseButton class and its subclasses. TouchButtons are roughly similar to its native BaseButton-deriver buttons but have some differences, such as:

- Most valuable difference: TouchButtons support multitouch.
- There's no support of shortcuts, but it might be added in the future.
- Appearance manipulation (theme) differ with native buttons' one according to Engine limitations. See [Change Appearance](#change-appearance) for more information.
- Button *"click"*, *"toggle"* and *"pass-by"* press modes switch between each other with `press_mode`.
- Mouse responding can be disabled with `mouse_enabled` set to `false`.                                                                                   \
Most of buttons functionality can be found in the native Buttons docs. There is some additional options:
- Pass-by Press: Button become pressed when finger enters its pressable area and become released when finger exits.
- Pass Screen Drag (in "click" press mode): Button forwards any recieved screen drag input event with `drag_input` signal.
- TouchButtons use **TouchButtonGroup**s instead of native ButtonGroup resource, because ButtonGroups support only built-in Buttons.

**Note:** *In the plugin version for Godot 3.x mouse responsibility is kinda wierd in visual and also perhaps in behavior. This issue have not been noticed in the version for Godot 4.*

## Added items:
- **TouchBaseButton**: base for all touchscreen buttons
- **TouchGroupButton**: resource for setup touchscreen buttons as radio
- **TouchButton**: Default touchscreen button
- **TouchCheckbox**: Button that represents a binary choice, used for option that should be confirmed; change appearance when is radio
- **TouchCheckButton**: Button that represents a binary choice, used for option that has immediate effect
- **TouchTextureButton**: Button that use texture properties instead of theme property for state appearance

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
