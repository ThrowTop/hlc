local hlc = require("hlc")

-- hlc.config mirrors hl.config() but is readable and additive.
-- assignment, call, and dot-access all do the same thing.
hlc.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        col = {
            -- hlc.gradient is just a factory, returns { colors = {...}, angle = n }
            active_border = hlc.gradient("rgb(B4BEFE)", "rgb(89B4FA)", 45),
            -- raw table works the same way
            inactive_border = { colors = { "rgb(313244)" } },
        },
    },
    decoration = {
        rounding = 10,
        blur = { enabled = true, size = 8, passes = 2 },
    },
    misc = { disable_hyprland_logo = true },
})

hlc.decoration = {
    inactive_opacity = 0.8,
}

-- capture a sub-proxy to write a section without repeating the path
local tp = hlc.config.input.touchpad

tp.natural_scroll = true
tp.disable_while_typing = true

-- read a value back from the mirror
local gi = hlc.general.gaps_in -- returns 4

-- hlc.curve returns a reusable curve object passed to hlc.animation
local ease = hlc.curve(0.23, 1, 0.32, 1)
local linear = hlc.curve(0, 0, 1, 1)
local snappy = hlc.curve(0.15, 0, 0.1, 1)

-- named curve, registers it under that name in hyprland
local myease = hlc.curve("myease", 0.23, 1, 0.32, 1)

-- hlc.style returns a style value passed to hlc.animation
local pop = hlc.style.popin(85)
local slide = hlc.style.slide()
local fade = hlc.style.fade()

-- hlc.animation mirrors animation state, writes apply immediately.
-- reading a leaf property returns what was last set.
hlc.animation = {
    global = { speed = 8 },
    windows = { speed = 4, curve = ease },
    -- hlc.anim(speed, curve?, style?) is shorthand for the same table
    windowsIn = hlc.anim(3.5, ease, pop),
    windowsOut = { speed = 2, curve = linear, style = pop },
    workspaces = hlc.anim(3, ease, slide),
    layers = { speed = 3, curve = ease },
    layersIn = { speed = 3, curve = ease, style = fade },
    layersOut = { speed = 1.5, curve = linear, style = fade },
}

-- leaves can also be set individually outside the table
hlc.animation.fade = { speed = 3, curve = ease }

-- individual field writes work too
hlc.animation.windows.speed = 6
local spd = hlc.animation.windows.speed -- returns 6

-- hlc.notify wraps hl.notification.create, timeout defaults to 2000ms
hlc.notify("hello")
hlc.notify("Short Hello", 1000)

-- hlc.decoration is shorthand for hlc.config.decoration (same proxy)
local rounding = hlc.decoration.rounding -- returns 10
local blur_on = hlc.config.decoration.blur.enabled -- returns true

-- call syntax does a partial write — only the given keys are touched
hlc.decoration.blur({ size = 10, passes = 3 })

-- toggles, read current value from the mirror, write back the new one
local mod = "SUPER"

hl.bind(mod .. " + SHIFT + A", function()
    hlc.animations.enabled = not hlc.animations.enabled
    hlc.notify("animations: " .. (hlc.animations.enabled and "on" or "off"), 1500)
end)

hl.bind(mod .. " + SHIFT + R", function()
    local cur = hlc.decoration.rounding
    hlc.decoration.rounding = cur == 0 and 8 or cur == 8 and 12 or 0
    hlc.notify("rounding: " .. hlc.decoration.rounding, 1500)
end)

hl.bind(mod .. " + SHIFT + B", function()
    hlc.decoration.blur.enabled = not hlc.decoration.blur.enabled
    hlc.notify("blur: " .. (hlc.decoration.blur.enabled and "on" or "off"), 1500)
end)

hl.bind(mod .. " + SHIFT + D", function()
    local on = hlc.decoration.inactive_opacity < 1.0
    hlc.decoration.inactive_opacity = on and 1.0 or 0.8
    hlc.notify("dim: " .. (on and "off" or "on"), 1500)
end)


