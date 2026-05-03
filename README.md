# hlc

Lua helper library for Hyprland's Lua config API.

- Readable config mirror, every write is reflected back, no need for `hl.get_config()`
- Bezier and spring curve constructors
- Animation proxy, leaf writes apply immediately
- Dispatcher shortcuts, all `hl.dsp.*` dispatchers available as `hlc.*` and auto-dispatched

Requires Hyprland with Lua config support.

## install

```sh
curl -fsSL https://raw.githubusercontent.com/ThrowTop/hlc/master/hlc.lua -o ~/.config/hypr/hlc.lua
```

Then in your config:

```lua
local hlc = require("hlc")
```

## config

`hlc.<section>`, `hlc.config.<section>`, and `hlc.config({ <section> = {...} })` are all the same proxy. Writes go to Hyprland immediately and update an internal mirror so values are readable:

```lua
hlc.decoration.rounding = 10
local r = hlc.decoration.rounding -- 10
```

Capture a sub-proxy to avoid repeating a path:

```lua
local tp = hlc.input.touchpad
tp.natural_scroll = true
tp.disable_while_typing = true
```

Call syntax does a partial write, only the given keys are touched:

```lua
hlc.decoration.blur({ size = 12, passes = 3 })
```

Bulk write via `hlc.config(...)` or direct section assignment:

```lua
hlc.config({
    general = { gaps_in = 4, gaps_out = 8, border_size = 2 },
    decoration = { rounding = 12 },
    misc = { disable_hyprland_logo = true },
})

hlc.decoration = { inactive_opacity = 0.9 }
```

## curves

### bezier

`hlc.bezier(x1, y1, x2, y2, name?)` registers a cubic bezier curve and returns a curve object. Name is optional; an internal name is generated if omitted.

```lua
local ease   = hlc.bezier(0.23, 1, 0.32, 1)
local linear = hlc.bezier(0, 0, 1, 1)
local named  = hlc.bezier(0.23, 1, 0.32, 1, "myease")
```

`hlc.curve` is an alias for `hlc.bezier`.

### spring

`hlc.spring(mass, stiffness, dampening, name?)` registers a spring curve. Keep mass at `1` and tune stiffness and dampening. Higher stiffness means faster, lower dampening means more bounce.

```lua
local snap  = hlc.spring(1, 200, 18)
local fluid = hlc.spring(1, 120, 16)
local named = hlc.spring(1, 150, 14, "myspring")
```

## animations

`hlc.animation` is a proxy that writes directly to Hyprland. Assign a table of leaves to configure multiple at once, or write individual leaves:

```lua
local ease  = hlc.bezier(0.23, 1, 0.32, 1)
local snap  = hlc.spring(1, 200, 18)
local pop   = hlc.style.popin(87)
local slide = hlc.style.slide()
local fade  = hlc.style.fade()

hlc.animation = {
    global      = { speed = 10 },
    windows     = { speed = 5, curve = snap },
    windowsIn   = { speed = 4, curve = snap, style = pop },
    windowsOut  = { speed = 2, curve = hlc.bezier(0, 0, 1, 1), style = pop },
    workspaces  = { speed = 4, curve = ease, style = slide },
    layers      = { speed = 4, curve = snap },
    layersIn    = { speed = 4, curve = snap, style = fade },
    layersOut   = { speed = 2, curve = hlc.bezier(0, 0, 1, 1), style = fade },
    fade        = { speed = 3, curve = hlc.bezier(0.15, 0, 0.1, 1) },
}

-- individual leaf, applies immediately
hlc.animation.border = { speed = 5, curve = ease }
hlc.animation.windows.speed = 6
```

`hlc.anim(speed, curve?, style?)` is shorthand for building a spec table:

```lua
windowsIn = hlc.anim(4, snap, pop),
```

### styles

| Constructor             | Description                  |
| ----------------------- | ---------------------------- |
| `hlc.style.popin(%)`    | Scale in from a percentage   |
| `hlc.style.slide(%)`    | Slide in (optional offset %) |
| `hlc.style.slidevert()` | Slide in vertically          |
| `hlc.style.fade()`      | Fade                         |
| `hlc.style.gnome()`     | GNOME-style                  |
| `hlc.style.gnomed()`    | GNOME-style (reversed)       |
| `hlc.style.loop()`      | Loop                         |
| `hlc.style.once()`      | Play once                    |

## gradients

`hlc.gradient(...colors, angle?)` trailing number is treated as the angle in degrees.

```lua
hlc.general.col.active_border   = hlc.gradient("rgb(B4BEFE)", "rgb(89B4FA)", 45)
hlc.general.col.inactive_border = { colors = { "rgb(313244)" } }
```

## notify

```lua
hlc.notify("hello")
hlc.notify("hello", 1000)  -- timeout in ms, default 2000
hlc.notify("hello", {
    timeout   = 3000,
    icon      = "hint",
    color     = "rgb(B4BEFE)",
    font_size = 14,
})
```

## dispatchers

All `hl.dsp.*` dispatchers are available directly on `hlc` and execute immediately. Useful inside event handlers and callbacks where you want to fire a dispatch rather than return a dispatcher.

`hlc.focus(...)` is equivalent to `hl.dispatch(hl.dsp.focus(...))`, and so on for every dispatcher.

```lua
hlc.exec_cmd("kitty")
hlc.focus({ window = "address:0x..." })
hlc.window.close()
hlc.window.move({ workspace = "2" })
hlc.window.resize({ x = 100, y = 0, relative = true })
hlc.window.pin({ action = "enable", window = addr })
hlc.submap("reset")
hlc.exit()
```

For keybinds, pass `hl.dsp.*` dispatchers as usual, those are lazy and executed by Hyprland when the key is pressed:

```lua
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + Q",      hl.dsp.window.close())
hl.bind("SUPER + H",      hl.dsp.focus({ direction = "left" }))
```

Use `hlc.*` dispatchers when you need to fire immediately, for example in `hl.on` event handlers or inside `hl.bind` function callbacks:

```lua
hl.on("hyprland.start", function()
    hlc.exec_cmd("waybar")
    hlc.exec_cmd("hyprpaper")
end)

hl.bind("SUPER + SHIFT + R", function()
    hlc.window.move({ workspace = "special:scratch" })
end)
```

## reading config in binds

The config mirror makes toggle binds straightforward:

```lua
hl.bind("SUPER + SHIFT + A", function()
    hlc.animations.enabled = not hlc.animations.enabled
end)

hl.bind("SUPER + SHIFT + R", function()
    local cur = hlc.decoration.rounding
    hlc.decoration.rounding = cur == 0 and 12 or 0
    hlc.notify("rounding: " .. hlc.decoration.rounding, 1500)
end)

hl.bind("SUPER + SHIFT + B", function()
    hlc.decoration.blur.enabled = not hlc.decoration.blur.enabled
    hlc.notify("blur: " .. (hlc.decoration.blur.enabled and "on" or "off"), 1500)
end)
```


