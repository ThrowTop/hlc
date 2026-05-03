-- hlc - readable wrappers around the Hyprland Lua API.
local M = {}

-- types

---@class HLC.Curve
---@field _name string
---@field _type "bezier"|"spring"

---@class HLC.Style

---@class HLC.NotifyOptions
---@field timeout?   integer
---@field icon?      string|integer
---@field color?     string|integer
---@field font_size? number

---@class HLC.Gradient
---@field colors string[]
---@field angle?  number

---@class HLC.StyleFactory
---@field popin     fun(perc?: number): HLC.Style
---@field slide     fun(perc?: number): HLC.Style
---@field slidevert fun(): HLC.Style
---@field fade      fun(): HLC.Style
---@field gnome     fun(): HLC.Style
---@field gnomed    fun(): HLC.Style
---@field loop      fun(): HLC.Style
---@field once      fun(): HLC.Style

---@class HLC.ExecResult
---@field stdout string|nil
---@field code   integer

---@class HLC.AnimationSpec
---@field enabled? boolean
---@field speed?   number
---@field curve?   HLC.Curve|string
---@field bezier?  string
---@field spring?  string
---@field style?   HLC.Style|string

---@class HLC.AnimationLeafProxy : HLC.AnimationSpec

---@class HLC.AnimationSpecs
---@field global?              HLC.AnimationSpec
---@field windows?             HLC.AnimationSpec
---@field windowsIn?           HLC.AnimationSpec
---@field windowsOut?          HLC.AnimationSpec
---@field windowsMove?         HLC.AnimationSpec
---@field layers?              HLC.AnimationSpec
---@field layersIn?            HLC.AnimationSpec
---@field layersOut?           HLC.AnimationSpec
---@field fade?                HLC.AnimationSpec
---@field fadeIn?              HLC.AnimationSpec
---@field fadeOut?             HLC.AnimationSpec
---@field fadeSwitch?          HLC.AnimationSpec
---@field fadeShadow?          HLC.AnimationSpec
---@field fadeGlow?            HLC.AnimationSpec
---@field fadeDim?             HLC.AnimationSpec
---@field fadeLayers?          HLC.AnimationSpec
---@field fadeLayersIn?        HLC.AnimationSpec
---@field fadeLayersOut?       HLC.AnimationSpec
---@field fadePopups?          HLC.AnimationSpec
---@field fadePopupsIn?        HLC.AnimationSpec
---@field fadePopupsOut?       HLC.AnimationSpec
---@field fadeDpms?            HLC.AnimationSpec
---@field border?              HLC.AnimationSpec
---@field borderangle?         HLC.AnimationSpec
---@field workspaces?          HLC.AnimationSpec
---@field workspacesIn?        HLC.AnimationSpec
---@field workspacesOut?       HLC.AnimationSpec
---@field specialWorkspace?    HLC.AnimationSpec
---@field specialWorkspaceIn?  HLC.AnimationSpec
---@field specialWorkspaceOut? HLC.AnimationSpec
---@field zoomFactor?          HLC.AnimationSpec
---@field monitorAdded?        HLC.AnimationSpec

---@class HLC.AnimationProxy
---@operator call(HLC.AnimationSpecs): nil
---@field global?              HLC.AnimationSpec
---@field windows?             HLC.AnimationSpec
---@field windowsIn?           HLC.AnimationSpec
---@field windowsOut?          HLC.AnimationSpec
---@field windowsMove?         HLC.AnimationSpec
---@field layers?              HLC.AnimationSpec
---@field layersIn?            HLC.AnimationSpec
---@field layersOut?           HLC.AnimationSpec
---@field fade?                HLC.AnimationSpec
---@field fadeIn?              HLC.AnimationSpec
---@field fadeOut?             HLC.AnimationSpec
---@field fadeSwitch?          HLC.AnimationSpec
---@field fadeShadow?          HLC.AnimationSpec
---@field fadeGlow?            HLC.AnimationSpec
---@field fadeDim?             HLC.AnimationSpec
---@field fadeLayers?          HLC.AnimationSpec
---@field fadeLayersIn?        HLC.AnimationSpec
---@field fadeLayersOut?       HLC.AnimationSpec
---@field fadePopups?          HLC.AnimationSpec
---@field fadePopupsIn?        HLC.AnimationSpec
---@field fadePopupsOut?       HLC.AnimationSpec
---@field fadeDpms?            HLC.AnimationSpec
---@field border?              HLC.AnimationSpec
---@field borderangle?         HLC.AnimationSpec
---@field workspaces?          HLC.AnimationSpec
---@field workspacesIn?        HLC.AnimationSpec
---@field workspacesOut?       HLC.AnimationSpec
---@field specialWorkspace?    HLC.AnimationSpec
---@field specialWorkspaceIn?  HLC.AnimationSpec
---@field specialWorkspaceOut? HLC.AnimationSpec
---@field zoomFactor?          HLC.AnimationSpec
---@field monitorAdded?        HLC.AnimationSpec

---@class HLC.ConfigProxy
---@field [string] any
---@operator call(table): nil

---@class HLC.Module
---@field config      HLC.ConfigProxy
---@field d           table
---@field bezier      fun(x1: number, y1: number, x2: number, y2: number, name?: string): HLC.Curve
---@field spring      fun(mass: number, stiffness: number, dampening: number, name?: string): HLC.Curve
---@field curve       fun(x1: number, y1: number, x2: number, y2: number, name?: string): HLC.Curve
---@field style       HLC.StyleFactory
---@field animation   HLC.AnimationProxy
---@field anim        fun(speed: number, curve?: HLC.Curve|string, style?: HLC.Style|string): HLC.AnimationSpec
---@field gradient    fun(...): HLC.Gradient
---@field notify      fun(text: string, opts?: integer|HLC.NotifyOptions): nil
---@field exec_async  fun(cmd: string, callback: fun(result: HLC.ExecResult), opts?: { interval?: integer }): nil
---@field exec_sync   fun(cmd: string): string|nil
---@field general     HLC.ConfigProxy
---@field decoration  HLC.ConfigProxy
---@field input       HLC.ConfigProxy
---@field animations  HLC.ConfigProxy
---@field misc        HLC.ConfigProxy
---@field binds       HLC.ConfigProxy
---@field cursor      HLC.ConfigProxy
---@field gestures    HLC.ConfigProxy
---@field group       HLC.ConfigProxy
---@field dwindle     HLC.ConfigProxy
---@field master      HLC.ConfigProxy
---@field layout      HLC.ConfigProxy
---@field opengl      HLC.ConfigProxy
---@field render      HLC.ConfigProxy
---@field scrolling   HLC.ConfigProxy
---@field xwayland    HLC.ConfigProxy
---@field ecosystem   HLC.ConfigProxy
---@field experimental HLC.ConfigProxy
---@field debug       HLC.ConfigProxy
---@field quirks      HLC.ConfigProxy

-- util

local function get_nested(t, path)
    for i = 1, #path do
        if type(t) ~= "table" then
            return nil
        end
        t = t[path[i]]
    end
    return t
end

local function set_nested(t, path, value)
    for i = 1, #path - 1 do
        local k = path[i]
        if type(t[k]) ~= "table" then
            t[k] = {}
        end
        t = t[k]
    end
    t[path[#path]] = value
end

local function deep_merge(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" and type(dst[k]) == "table" then
            deep_merge(dst[k], v)
        else
            dst[k] = v
        end
    end
end

local function wrap_path(path, value)
    local t = value
    for i = #path, 1, -1 do
        t = { [path[i]] = t }
    end
    return t
end

-- config mirror

local config_mirror = {}
local config_proxy_mt = {}

config_proxy_mt.__index = function(proxy, key)
    local path = rawget(proxy, "_path")
    local new_path = {}
    for _, v in ipairs(path) do
        new_path[#new_path + 1] = v
    end
    new_path[#new_path + 1] = key
    local mirrored = get_nested(config_mirror, new_path)
    if mirrored ~= nil and type(mirrored) ~= "table" then
        return mirrored
    end
    return setmetatable({ _path = new_path }, config_proxy_mt)
end

config_proxy_mt.__newindex = function(proxy, key, value)
    local path = rawget(proxy, "_path")
    local full_path = {}
    for _, v in ipairs(path) do
        full_path[#full_path + 1] = v
    end
    full_path[#full_path + 1] = key
    if type(value) == "table" then
        local node = config_mirror
        for _, seg in ipairs(full_path) do
            if type(node[seg]) ~= "table" then
                node[seg] = {}
            end
            node = node[seg]
        end
        deep_merge(node, value)
    else
        set_nested(config_mirror, full_path, value)
    end
    hl.config(wrap_path(full_path, value))
end

config_proxy_mt.__call = function(proxy, tbl)
    if type(tbl) ~= "table" then
        error("hlc.config: expected a table", 2)
    end
    local path = rawget(proxy, "_path")
    local node = config_mirror
    for _, seg in ipairs(path) do
        if type(node[seg]) ~= "table" then
            node[seg] = {}
        end
        node = node[seg]
    end
    deep_merge(node, tbl)
    hl.config(wrap_path(path, tbl))
end

config_proxy_mt.__tostring = function(proxy)
    local path = rawget(proxy, "_path")
    return "hlc.config[" .. (#path > 0 and table.concat(path, ".") or "root") .. "]"
end

---@type HLC.ConfigProxy
M.config = setmetatable({ _path = {} }, config_proxy_mt)

-- curve

local curve_mt = {
    __tostring = function(c)
        return rawget(c, "_name")
    end,
    __newindex = function()
        error("hlc curve is read-only", 2)
    end,
}

local curve_counter = 0

local function validate_coord(label, v)
    if type(v) ~= "number" then
        error("hlc.bezier: " .. label .. " must be a number", 3)
    end
    if v < -1 or v > 2 then
        error("hlc.bezier: " .. label .. " must be in [-1, 2]", 3)
    end
end

local function validate_spring(label, v)
    if type(v) ~= "number" or v <= 0 then
        error("hlc.spring: " .. label .. " must be a positive number", 3)
    end
end

---@param  x1   number
---@param  y1   number
---@param  x2   number
---@param  y2   number
---@param  name? string
---@return HLC.Curve
function M.bezier(x1, y1, x2, y2, name)
    if name == nil then
        curve_counter = curve_counter + 1
        name = string.format("hlc_curve_%d", curve_counter)
    end
    validate_coord("x1", x1)
    validate_coord("y1", y1)
    validate_coord("x2", x2)
    validate_coord("y2", y2)
    hl.curve(name, { type = "bezier", points = { { x1, y1 }, { x2, y2 } } })
    return setmetatable({ _name = name, _type = "bezier" }, curve_mt)
end

---@param  mass      number
---@param  stiffness number
---@param  dampening number
---@param  name?     string
---@return HLC.Curve
function M.spring(mass, stiffness, dampening, name)
    if name == nil then
        curve_counter = curve_counter + 1
        name = string.format("hlc_curve_%d", curve_counter)
    end
    validate_spring("mass", mass)
    validate_spring("stiffness", stiffness)
    validate_spring("dampening", dampening)
    hl.curve(name, { type = "spring", mass = mass, stiffness = stiffness, dampening = dampening })
    return setmetatable({ _name = name, _type = "spring" }, curve_mt)
end

M.curve = M.bezier

local function resolve_curve(c)
    if c == nil then
        return "default"
    end
    if type(c) == "string" then
        return c
    end
    if getmetatable(c) == curve_mt then
        return rawget(c, "_name")
    end
    error("hlc: curve must be an hlc.curve() object or a string", 3)
end

-- style

local style_mt = {
    __tostring = function(s)
        return rawget(s, "_str")
    end,
}

local function make_style(str, kind, extra)
    return setmetatable({ _str = str, _kind = kind, _extra = extra }, style_mt)
end

local function require_percent(fn, perc)
    if type(perc) ~= "number" or perc < 0 or perc > 100 then
        error("hlc.style." .. fn .. ": percentage must be in [0, 100]", 3)
    end
end

---@type HLC.StyleFactory
M.style = {
    popin = function(perc)
        if perc == nil then
            return make_style("popin", "popin")
        end
        require_percent("popin", perc)
        return make_style(string.format("popin %d%%", math.floor(perc)), "popin", perc)
    end,
    slide = function(perc)
        if perc == nil then
            return make_style("slide", "slide")
        end
        require_percent("slide", perc)
        return make_style(string.format("slide %d%%", math.floor(perc)), "slide", perc)
    end,
    slidevert = function()
        return make_style("slidevert", "slidevert")
    end,
    fade = function()
        return make_style("fade", "fade")
    end,
    gnome = function()
        return make_style("gnome", "gnome")
    end,
    gnomed = function()
        return make_style("gnomed", "gnomed")
    end,
    loop = function()
        return make_style("loop", "loop")
    end,
    once = function()
        return make_style("once", "once")
    end,
}

local function resolve_style(s)
    if s == nil then
        return nil
    end
    if type(s) == "string" then
        return s
    end
    if getmetatable(s) == style_mt then
        return rawget(s, "_str")
    end
    error("hlc: style must be an hlc.style.* object or a string", 3)
end

-- animation

local VALID_LEAVES = {}
for _, leaf in ipairs({
    "global",
    "windows",
    "windowsIn",
    "windowsOut",
    "windowsMove",
    "layers",
    "layersIn",
    "layersOut",
    "fade",
    "fadeIn",
    "fadeOut",
    "fadeSwitch",
    "fadeShadow",
    "fadeGlow",
    "fadeDim",
    "fadeLayers",
    "fadeLayersIn",
    "fadeLayersOut",
    "fadePopups",
    "fadePopupsIn",
    "fadePopupsOut",
    "fadeDpms",
    "border",
    "borderangle",
    "workspaces",
    "workspacesIn",
    "workspacesOut",
    "specialWorkspace",
    "specialWorkspaceIn",
    "specialWorkspaceOut",
    "zoomFactor",
    "monitorAdded",
}) do
    VALID_LEAVES[leaf] = true
end

local anim_state = {}

local function curve_key(c)
    if getmetatable(c) == curve_mt and rawget(c, "_type") == "spring" then
        return "spring"
    end
    return "bezier"
end

local function apply_animation(leaf)
    local s = anim_state[leaf]
    local spec = {
        leaf = leaf,
        enabled = s.enabled,
        speed = s.speed,
    }
    if s.curve ~= nil then
        spec[curve_key(s.curve)] = resolve_curve(s.curve)
    elseif s.spring ~= nil then
        spec.spring = s.spring
    elseif s.bezier ~= nil then
        spec.bezier = s.bezier
    else
        spec.bezier = "default"
    end
    local str = resolve_style(s.style)
    if str then
        spec.style = str
    end
    hl.animation(spec)
end

local function normalise_animation(leaf, spec)
    if type(spec) ~= "table" then
        error(string.format("hlc.animation.%s: expected a table", leaf), 3)
    end
    local enabled = spec.enabled
    if enabled == nil then
        enabled = true
    end
    local speed = spec.speed or 1
    if enabled and (type(speed) ~= "number" or speed <= 0) then
        error(string.format("hlc.animation.%s: speed must be > 0 when enabled", leaf), 3)
    end
    return { enabled = enabled, speed = speed, curve = spec.curve, bezier = spec.bezier, spring = spec.spring, style = spec.style }
end

local leaf_mt = {}

leaf_mt.__index = function(proxy, key)
    local s = anim_state[rawget(proxy, "_leaf")]
    return s and s[key] or nil
end

leaf_mt.__newindex = function(proxy, key, value)
    local leaf = rawget(proxy, "_leaf")
    local s = anim_state[leaf]
    if not s then
        s = { enabled = true, speed = 1 }
        anim_state[leaf] = s
    end
    s[key] = value
    apply_animation(leaf)
end

leaf_mt.__tostring = function(proxy)
    local leaf = rawget(proxy, "_leaf")
    local s = anim_state[leaf] or {}
    return string.format(
        "hlc.animation.%s{enabled=%s, speed=%s, curve=%s, style=%s}",
        leaf,
        tostring(s.enabled),
        tostring(s.speed),
        s.curve and tostring(s.curve) or "nil",
        s.style and tostring(s.style) or "nil"
    )
end

local leaf_cache = {}
local function leaf_proxy(leaf)
    local p = leaf_cache[leaf]
    if not p then
        p = setmetatable({ _leaf = leaf }, leaf_mt)
        leaf_cache[leaf] = p
    end
    return p
end

---@type HLC.AnimationProxy
local animation_proxy = setmetatable({}, {
    __index = function(_, leaf)
        if not VALID_LEAVES[leaf] then
            error(string.format("hlc.animation: no such leaf %q", leaf), 2)
        end
        return leaf_proxy(leaf)
    end,
    __newindex = function(_, leaf, spec)
        if not VALID_LEAVES[leaf] then
            error(string.format("hlc.animation: no such leaf %q", leaf), 2)
        end
        anim_state[leaf] = normalise_animation(leaf, spec)
        apply_animation(leaf)
    end,
    __call = function(self, specs)
        if type(specs) ~= "table" then
            error("hlc.animation(...): expected a table of {leaf = spec}", 2)
        end
        for leaf, spec in pairs(specs) do
            self[leaf] = spec
        end
    end,
})

M.animation = animation_proxy

-- anim

---@param  speed number
---@param  curve? HLC.Curve|string
---@param  style? HLC.Style|string
---@return HLC.AnimationSpec
function M.anim(speed, curve, style)
    local t = { speed = speed }
    if curve then
        t.curve = curve
    end
    if style then
        t.style = style
    end
    return t
end

-- gradient

---@param  ... string|number  color strings followed by an optional angle
---@return HLC.Gradient
function M.gradient(...)
    local args = { ... }
    local angle
    if type(args[#args]) == "number" then
        angle = table.remove(args)
    end
    local t = { colors = args }
    if angle then
        t.angle = angle
    end
    return t
end

-- notify

---@param text string
---@param opts? integer|HLC.NotifyOptions  timeout in ms, or options table. default 2000ms
function M.notify(text, opts)
    local t = { text = tostring(text) }
    if type(opts) == "number" then
        t.timeout = opts
    elseif type(opts) == "table" then
        t.timeout = opts.timeout
        t.icon = opts.icon
        t.color = opts.color
        t.font_size = opts.font_size
    end
    t.timeout = t.timeout or 2000
    t.icon = t.icon or "ok"
    hl.notification.create(t)
end

-- exec

local _exec_id = 0

---@param cmd      string
---@param callback fun(result: HLC.ExecResult): nil
---@param opts?    { interval?: integer }
function M.exec_async(cmd, callback, opts)
    _exec_id = _exec_id + 1
    local id       = string.format("%d_%d", os.time(), _exec_id)
    local sh_file  = string.format("/tmp/hlc_%s.sh",   id)
    local out_file = string.format("/tmp/hlc_%s.out",  id)
    local don_file = string.format("/tmp/hlc_%s.done", id)
    local interval = (opts and opts.interval) or 100

    local f = io.open(sh_file, "w")
    if not f then
        callback({ stdout = nil, code = -1 })
        return
    end
    f:write(string.format("#!/bin/bash\n%s > %s 2>&1\necho $? > %s\n", cmd, out_file, don_file))
    f:close()

    hl.exec_cmd("bash " .. sh_file)

    local timer
    timer = hl.timer(function()
        local df = io.open(don_file, "r")
        if not df then return end
        local code_str = df:read("*l")
        df:close()

        timer:set_enabled(false)

        local stdout
        local of = io.open(out_file, "r")
        if of then
            local s = of:read("*a"):gsub("%s+$", "")
            of:close()
            stdout = s ~= "" and s or nil
        end

        os.remove(sh_file)
        os.remove(out_file)
        os.remove(don_file)

        callback({ stdout = stdout, code = tonumber(code_str) or -1 })
    end, { timeout = interval, type = "repeat" })
end

---@param  cmd string
---@return string|nil
function M.exec_sync(cmd)
    local f = io.popen(cmd)
    if not f then return nil end
    local s = f:read("*a"):gsub("%s+$", "")
    f:close()
    return s ~= "" and s or nil
end

-- dispatch

local function wrap_dsp(dsp)
    local t = {}
    for k, v in pairs(dsp) do
        if type(v) == "function" then
            t[k] = function(...)
                hl.dispatch(v(...))
            end
        elseif type(v) == "table" then
            t[k] = wrap_dsp(v)
        end
    end
    return t
end

M.d = wrap_dsp(hl.dsp)

-- export

local CONFIG_SECTIONS = {
    animations = true,
    binds = true,
    cursor = true,
    debug = true,
    decoration = true,
    dwindle = true,
    ecosystem = true,
    experimental = true,
    general = true,
    gestures = true,
    group = true,
    input = true,
    layout = true,
    master = true,
    misc = true,
    opengl = true,
    quirks = true,
    render = true,
    scrolling = true,
    xwayland = true,
}

---@type HLC.Module
local _export = setmetatable({}, {
    __index = function(_, k)
        if M[k] ~= nil then
            return M[k]
        end
        if CONFIG_SECTIONS[k] then
            return M.config[k]
        end
    end,
    __newindex = function(_, k, v)
        if k == "animation" then
            animation_proxy(v)
            return
        end
        if k == "config" then
            config_proxy_mt.__call(M.config, v)
            return
        end
        if CONFIG_SECTIONS[k] then
            config_proxy_mt.__call(M.config[k], v)
            return
        end
        error(string.format("hlc: cannot assign to hlc.%s", tostring(k)), 2)
    end,
})

-- apparently lsp and autocomplete doesnt work if i return the metatable directly.
return _export


