# hlc

Lua helper library for Hyprland's Lua config API. The main thing it adds over the raw `hl.*` API is a readable config mirror — every write is reflected back so you can read current values without calling `hl.get_config()`.

Requires Hyprland with Lua config support.

## config

Writes go to Hyprland immediately and update the mirror. All three forms below do the same thing:

```lua
local hlc = require("hlc")

hlc.config({ decoration = { rounding = 10 } })
hlc.decoration = { rounding = 10 }
hlc.decoration.rounding = 10
```

Reads return whatever was last written:

```lua
local r = hlc.decoration.rounding -- 10
```

Capture a sub-proxy to avoid repeating the path:

```lua
local tp = hlc.config.input.touchpad
tp.natural_scroll = true
tp.disable_while_typing = true
```

Call syntax does a partial write — only the given keys are touched:

```lua
hlc.decoration.blur({ size = 12, passes = 3 })
```

## animations

Leaf writes apply immediately. You can bulk-assign or set leaves individually:

```lua
local ease   = hlc.curve(0.23, 1, 0.32, 1)
local linear = hlc.curve(0, 0, 1, 1)
local pop    = hlc.style.popin(85)
local slide  = hlc.style.slide()

hlc.animation = {
    global     = { speed = 8 },
    windows    = { speed = 4, curve = ease },
    windowsIn  = hlc.anim(3.5, ease, pop),
    windowsOut = { speed = 2, curve = linear, style = pop },
    workspaces = hlc.anim(3, ease, slide),
}

-- set later, applies immediately
hlc.animation.fade = { speed = 3, curve = ease }
hlc.animation.windows.speed = 6
```

`hlc.anim(speed, curve?, style?)` just builds the spec table — use it or don't.

Named curves register under that name in Hyprland:

```lua
local myease = hlc.curve("myease", 0.23, 1, 0.32, 1)
```

Available styles: `popin(%)`, `slide(%)`, `slidevert()`, `fade()`, `gnome()`, `loop()`, `once()`

## gradients

```lua
hlc.general.col.active_border   = hlc.gradient("rgb(B4BEFE)", "rgb(89B4FA)", 45)
hlc.general.col.inactive_border = { colors = { "rgb(313244)" } }
```

## reading config in keybinds

```lua
hl.bind("SUPER + SHIFT + R", function()
    local cur = hlc.decoration.rounding
    hlc.decoration.rounding = cur == 0 and 8 or cur == 8 and 12 or 0
    hlc.notify("rounding: " .. hlc.decoration.rounding, 1500)
end)

hl.bind("SUPER + SHIFT + A", function()
    hlc.animations.enabled = not hlc.animations.enabled
    hlc.notify("animations: " .. (hlc.animations.enabled and "on" or "off"), 1500)
end)
```

## misc

```lua
hlc.exec_once("waybar", "hyprpaper", "hypridle") -- accepts multiple strings
hlc.notify("hello")
hlc.notify("hello", 1000) -- timeout in ms, default 2000
```
