# hlc

A small Lua helper library for Hyprland's Lua config API. Wraps `hl.config()` behind a readable proxy so you can write and read config values naturally, and provides utilities for animations, curves, gradients, and notifications.

Requires Hyprland with Lua config support.

## config

`hlc.config` mirrors `hl.config()` but is readable and additive. Assignment, call syntax, and dot-access all write to Hyprland immediately and update the internal mirror.

```lua
local hlc = require("hlc")

hlc.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
    },
    decoration = {
        rounding = 10,
        blur = { enabled = true, size = 8, passes = 2 },
    },
})

-- section shorthands work the same way
hlc.decoration = {
    inactive_opacity = 0.8,
}

-- partial write via call syntax — only touches the given keys
hlc.decoration.blur({ size = 12, passes = 3 })

-- read a value back from the mirror
local rounding = hlc.decoration.rounding -- returns 10

-- capture a sub-proxy to avoid repeating the path
local tp = hlc.config.input.touchpad
tp.natural_scroll = true
tp.disable_while_typing = true
```

`hlc.decoration` and `hlc.config.decoration` are the same proxy.

## animations

`hlc.animation` mirrors animation state. Writes apply to Hyprland immediately. You can set everything at once or individual leaves separately — both work.

```lua
local ease   = hlc.curve(0.23, 1, 0.32, 1)
local linear = hlc.curve(0, 0, 1, 1)

hlc.animation = {
    global     = { speed = 8 },
    windows    = { speed = 4, curve = ease },
    windowsOut = { speed = 2, curve = linear, style = hlc.style.popin(85) },
    workspaces = { speed = 3, curve = ease,   style = hlc.style.slide() },
}

-- set leaves individually outside the table
hlc.animation.fade = { speed = 3, curve = ease }

-- or write a single field
hlc.animation.windows.speed = 6
```

`hlc.anim(speed, curve?, style?)` is a shorthand for building the spec table:

```lua
hlc.animation.windowsIn = hlc.anim(3.5, ease, hlc.style.popin(85))
```

### curves

```lua
local ease = hlc.curve(0.23, 1, 0.32, 1)         -- anonymous
local named = hlc.curve("myease", 0.23, 1, 0.32, 1) -- registers under that name in Hyprland
```

### styles

```lua
hlc.style.popin(85)   -- popin 85%
hlc.style.slide()
hlc.style.fade()
hlc.style.slidevert()
```

## gradients

```lua
hlc.general.col.active_border = hlc.gradient("rgb(B4BEFE)", "rgb(89B4FA)", 45)
-- or as a raw table
hlc.general.col.inactive_border = { colors = { "rgb(313244)" } }
```

## misc

```lua
-- wraps hl.exec_once, accepts multiple strings
hlc.exec_once("waybar", "hyprpaper", "hypridle")

-- wraps hl.notification.create, timeout defaults to 2000ms
hlc.notify("hello")
hlc.notify("something", 1000)
```

## reading config in keybinds

Since the mirror is readable, you can use config values in `hl.bind` callbacks:

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
