-- ~/nix/home-manager/hypr/hyprland.lua
-- Hyprland 0.55.x Lua config. Catppuccin Mocha accents, Caelestia shell on top.
-- Check after edits:  hyprctl reload && hyprctl configerrors
-- Lines tagged [verify] use dispatcher forms inferred from community configs.


----------------------
---- PALETTE/VARS ----
----------------------

local palette = {
    mauve   = "rgba(cba6f7ee)",
    blue    = "rgba(89b4faee)",
    teal    = "rgba(94e2d5ee)",
    surface = "rgba(45475acc)",
}

local mainMod     = "SUPER"
local terminal    = "alacritty"
local fileManager = "dolphin"
local launcher    = "caelestia shell drawers toggle launcher" -- list IPC: caelestia shell -s
local screenshot  = 'grim -g "$(slurp)" - | swappy -f -'


------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm finalize")         -- signals UWSM that compositor finished starting
    hl.exec_cmd("caelestia shell -d")    -- bar, launcher, notifications, wallpaper
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 6,
        gaps_out = 14,

        border_size = 2,

        col = {
            active_border   = { colors = { palette.mauve, palette.blue, palette.teal }, angle = 45 },
            inactive_border = palette.surface,
        },

        resize_on_border = true,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        dim_inactive = true,
        dim_strength = 0.06,

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 6,
            passes   = 3,
            noise    = 0.015,
            vibrancy = 0.2,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Curves. Spring curves need newer Hyprland, so bezier only here.
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("smooth",         { type = "bezier", points = { {0.4, 0},     {0.2, 1}     } })
hl.curve("overshoot",      { type = "bezier", points = { {0.34, 1.56}, {0.64, 1}    } }) -- springy pop

-- Animations
hl.animation({ leaf = "global",           enabled = true, speed = 10,   bezier = "easeOutQuint" })
hl.animation({ leaf = "border",           enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle",      enabled = true, speed = 60,   bezier = "linear",        style = "loop" }) -- rotating gradient
hl.animation({ leaf = "windows",          enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 4.1,  bezier = "overshoot",     style = "popin 80%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 1.49, bezier = "linear",        style = "popin 80%" })
hl.animation({ leaf = "fadeIn",           enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",          enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",             enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",           enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 4,    bezier = "easeOutQuint",  style = "fade" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 1.5,  bezier = "linear",        style = "fade" })
hl.animation({ leaf = "fadeLayersIn",     enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut",    enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 3,    bezier = "smooth",        style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3,    bezier = "smooth",        style = "slidevert" })
hl.animation({ leaf = "zoomFactor",       enabled = true, speed = 7,    bezier = "quick" })


-------------------
---- LAYOUTS ------
-------------------

hl.config({
    dwindle = {
        preserve_split = true,
        pseudotile     = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})


----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0,    -- Caelestia manages wallpaper
        disable_hyprland_logo   = true,
        vfr                     = true, -- save battery when idle
        key_press_enables_dpms  = true,
        mouse_move_enables_dpms = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 to 1.0

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


---------------------
---- KEYBINDINGS ----
---------------------

-- Apps
hl.bind(mainMod .. " + Q",     hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",     hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(launcher))
hl.bind(mainMod .. " + R",     hl.dsp.exec_cmd(launcher))

-- Session
hl.bind(mainMod .. " + C",           hl.dsp.window.close())
hl.bind(mainMod .. " + M",           hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + R",   hl.dsp.exec_cmd("hyprctl reload"))

-- Window state
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))                -- dwindle only
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- [verify]

-- Focus and move with arrows
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + " .. dir,            hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. dir,    hl.dsp.window.move({ direction = dir })) -- [verify]
end

-- Workspaces: SUPER + [0-9] switch, SUPER + SHIFT + [0-9] send window
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mainMod .. " + grave",       hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + ALT + S",     hl.dsp.window.move({ workspace = "special:magic" }))

-- Screenshots: region to editor
hl.bind("Print",                     hl.dsp.exec_cmd(screenshot))
hl.bind(mainMod .. " + SHIFT + S",   hl.dsp.exec_cmd(screenshot))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Drag and resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume and brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Media keys (needs playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    -- Ignore maximize requests from all apps
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    -- Small utility windows float instead of tiling
    name  = "float-utility-windows",
    match = { class = "^(blueman-manager|nm-connection-editor|pavucontrol|org.pulseaudio.pavucontrol|swappy)$" },

    float = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
