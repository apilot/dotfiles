-- hyprland.lua -- Lua config for Hyprland 0.55.3
--
-- Migrated 1:1 from the hyprlang config on hypr_text (hyprland/*.conf).
-- New capability: per-output factory ICC profiles (PL2493H.icc) on both
-- external Iiyama monitors. ICC is Lua-API only -- the legacy text
-- `monitor=` line silently ignores `icc`.
--
-- Validation: `Hyprland --verify-config --config <this file>`
-- NOTE: --verify-config does NOT load plugins, so hy3:* dispatchers are
-- routed through `hyprctl dispatch` (robust at runtime) and `layout=hy3`
-- / `plugin.hy3` will produce hy3-related false-positive warnings under
-- verify -- these are expected and harmless.

------------------------------------------------------------------
-- variables  (variables.conf + monitors-detected.conf)
------------------------------------------------------------------
local terminal     = "kitty"
local browser      = "zen"
local editor       = "geany"
local fileExplorer = "thunar"
local mainMod      = "SUPER"

-- detected by ~/.config/hypr/scripts/monitors-detect.sh
local DP      = "DP-1"
local DP_RATE = "74.97"
local HDMI    = "HDMI-A-2"

local home       = os.getenv("HOME") or "/home/aboyarinov"
local ICC_IIYAMA = home .. "/.local/share/icc/PL2493H.icc"

------------------------------------------------------------------
-- monitors  (monitors.conf) + ICC
------------------------------------------------------------------
hl.monitor({ output = DP,       mode = "1920x1080@" .. DP_RATE, position = "0x0",      scale = 1.0, icc = ICC_IIYAMA })
hl.monitor({ output = "eDP-1",  mode = "1920x1080@240.00101",   position = "960x1080", scale = 1.0 })
hl.monitor({ output = HDMI,     mode = "1920x1080@75",          position = "1920x0",   scale = 1.0, icc = ICC_IIYAMA })

-- workspace -> monitor
hl.workspace_rule({ workspace = "1", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "2", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "3", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "4", monitor = DP })
hl.workspace_rule({ workspace = "5", monitor = DP })
hl.workspace_rule({ workspace = "6", monitor = DP })
hl.workspace_rule({ workspace = "7", monitor = HDMI })
hl.workspace_rule({ workspace = "8", monitor = HDMI })
hl.workspace_rule({ workspace = "9", monitor = HDMI })

------------------------------------------------------------------
-- environment  (env.conf)
------------------------------------------------------------------
hl.env("XCURSOR_THEME", "catppuccin-mocha-dark-cursors")
hl.env("HYPRCURSOR_THEME", "catppuccin-mocha-dark-cursors")
hl.env("HYPRCURSOR_SIZE", "25")
hl.env("LIBVA_DRIVER_NAME", "iHD")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
-- AQ_DRM_DEVICES intentionally unset: must see all cards incl. EVDI (DisplayLink).
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("GDK_DPI_SCALE", "1.0")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("GTK_THEME", "Catppuccin-Mocha-Standard-Lavender-Dark")
hl.env("XDG_MENU_PREFIX", "gentoo-")
hl.env("DBUS_SESSION_BUS_ADDRESS", "unix:path=/run/user/1000/bus")

------------------------------------------------------------------
-- config sections  (general / group / decoration / animations / misc / xwayland)
------------------------------------------------------------------
hl.config({
    general = {
        gaps_in        = 2,
        gaps_out       = 10,
        border_size    = 2,
        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(8f00ffee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = true,
        layout           = "hy3",   -- requires libhy3.so (loaded in autostart)
    },
    cursor = {
        enable_hyprcursor    = true,
        hide_on_key_press    = false,
        hide_on_touch        = false,
        no_hardware_cursors  = 0,
        sync_gsettings_theme = true,
    },
    decoration = {
        rounding            = 8,
        active_opacity      = 0.9,
        inactive_opacity    = 0.8,
        fullscreen_opacity  = 1,
        dim_inactive        = true,
        dim_strength        = 0.4,
        blur   = { enabled = true, size = 5, passes = 1 },
        shadow = { enabled = true, range = 4, render_power = 3, color = "rgba(1a1a1aee)" },
    },
    input = {
        numlock_by_default = true,
        follow_mouse       = 1,
        force_no_accel     = 0,
        sensitivity        = 0,
        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            drag_lock            = true,
        },
        tablet = {
            relative_input = true,
            output         = DP,
        },
    },
    misc     = { disable_hyprland_logo = true },
    debug    = { disable_logs = false },
    xwayland = { force_zero_scaling = true },
    -- hy3 plugin options (applied once the plugin registers at runtime)
    plugin = {
        hy3 = {
            node_collapse_policy = 0,
            autotile = { enable = true },
            tabs     = { height = 3, padding = 2, from_top = true, render_text = false },
        },
    },
})

------------------------------------------------------------------
-- animations  (animations.conf)
------------------------------------------------------------------
hl.config({ animations = { enabled = true } })
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows",    enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6,  bezier = "default" })

------------------------------------------------------------------
-- per-device input  (input.conf)
------------------------------------------------------------------
for _, name in ipairs({
    "at-translated-set-2-keyboard",
    "ergohaven-k:03-pro-v1-65mm-keyboard",
    "ergohaven-k:03-pro-v1-65mm",
    "ergohaven-k:03-pro-v1-65mm-consumer-control",
    "charybdis-keyboard",
    "zmk-project-charybdis-keyboard",
    "ergohaven-k:03-pro-v1-65mm-system-control",
}) do
    hl.device({ name = name, kb_layout = "us,ru", kb_options = "grp:win_space_toggle" })
end

hl.device({ name = "ergohaven-k:03-pro-v1-65mm-mouse", sensitivity = 0.7 })
hl.device({ name = "weylus-stylus---bigme",             sensitivity = -1 })
hl.device({ name = "pen-emu",                           sensitivity = -1 })

------------------------------------------------------------------
-- window rules  (rules.conf)
------------------------------------------------------------------
-- floats by title
for _, t in ipairs({
    "^(garuda-assistant)$", "^(CopyQ)$", "^(garuda-boot-options)$",
    "^(garuda-boot-repair)$", "^(garuda-gamer)$", "^(garuda-network-assistant)$",
    "^(garuda-settings-manager)$", "^(garuda-welcome)$", "^(KMix)$", "^(Rofi)$",
    "^(org.gnome.Calculator)$", "^(org.gnome.Nautilus)$", "^(eww)$", "^(pavucontrol)$",
    "^(nm-connection-editor)$", "^(blueberry.py)$", "^(org.gnome.Settings)$",
    "^(org.gnome.Calendar)$", "^(org.gnome.design.Palette)$", "^(Color Picker)$",
    "^(Network)$", "^(transmission-gtk)$", "^(Save File)$", "^(wants to save)$",
    "^Открыть папку как$", "^(zen-browser.app wants to save)$",
}) do
    hl.window_rule({ float = true, match = { title = t } })
end

-- floats by class
for _, c in ipairs({
    "^(xdg-desktop-portal)$", "^(xdg-desktop-portal-gtk)$", "^(xdg-desktop-portal-gnome)$",
    "^(org.keepassxc.KeePassXC)$", "^(dotfiles.floating)$", "^(simple-scan)$", "^(swayimg)$",
    "^(alsamixer)$", "^(lxappearence)$", "^(nm-connection-editor)$", "^(thunderbird-esr)$",
    "^(xarchiver)$", "^(blueman-services)$", "^(PinegrowLibrary)$", "^(pavucontrol)$",
    "^(blueman-manager)$", "^(org.kde.kmix)$", "^(qt5ct)$", "^(qt6ct)$",
    "^(com.github.hluk.copyq)$",
}) do
    hl.window_rule({ float = true, match = { class = c } })
end
hl.window_rule({ float = true, match = { class = "quickshell" } })

-- special float rules
hl.window_rule({ no_anim = true, match = { title = "^(REAPER)$" } })
hl.window_rule({ float = true, match = { modal = true } })                         -- modal windows
hl.window_rule({ float = true, match = { class = "^thunar$", title = [[^Rename\s]] } })
hl.window_rule({ float = true, match = { title = "(Select|Open)( a)? (File|Folder)(s)?" } })
hl.window_rule({ float = true, match = { title = "File (Operation|Upload)( Progress)?" } })
hl.window_rule({ float = true, match = { title = ".* Properties" } })
hl.window_rule({ float = true, match = { title = "Export Image as PNG" } })
hl.window_rule({ float = true, match = { title = "GIMP Crash Debug" } })
hl.window_rule({ float = true, match = { title = "Save As" } })
hl.window_rule({ float = true, match = { title = "Library" } })

-- xwayland popups
hl.window_rule({ no_dim = true,   no_shadow = true, rounding = 10, match = { xwayland = true, title = "win[0-9]+" } })

-- gnome calendar extras
hl.window_rule({ rounding = 0, no_shadow = true, no_anim = true, match = { class = "^org.gnome.Calendar$" } })

-- Picture-in-Picture
hl.window_rule({ move = "100%-w-2% 100%-w-3%", keep_aspect_ratio = true, float = true, pin = true,
                 match = { title = [[Picture(-| )in(-| )[Pp]icture]] } })

-- keepassxc access request
hl.window_rule({ float = true,  center = true, match = { class = "^org.keepassxc.KeePassXC$", title = [[^(KeePassXC -  Access Request)$]] } })
-- dotfiles.floating size
hl.window_rule({ size = "90% 90%", match = { class = "^dotfiles.floating$" } })
-- swayimg size
hl.window_rule({ size = "90% 90%", match = { class = "^swayimg$" } })
-- thunderbird-esr center
hl.window_rule({ center = true, match = { class = "^thunderbird-esr$" } })
-- xarchiver size
hl.window_rule({ size = "70% 60%", match = { class = "^xarchiver$" } })
-- tile rules
hl.window_rule({ tile = true, match = { initial_title = "^(Mozilla Thunderbird)$" } })
hl.window_rule({ tile = true, match = { class = "^Pinegrow$" } })
hl.window_rule({ float = true, center = true, match = { class = "^PinegrowLibrary$" } })
-- zen empty-title popup
hl.window_rule({ float = true, match = { title = "^$", class = "zen" } })
hl.window_rule({ move = "100%-w-20 70", match = { title = "^$", class = "zen" } })
-- REAPER no_focus
hl.window_rule({ no_focus = true, match = { class = "REAPER", title = "^$" } })
-- empty class/title no_blur
hl.window_rule({ no_blur = true, match = { class = "^()$", title = "^()$" } })
-- Ardour
hl.window_rule({ opacity = 1, no_dim = true, no_blur = true, opaque = true, match = { class = "^(Ardour)" } })

-- opacity rules (0.85 override 0.85 override)
for _, m in ipairs({
    { class = "^thunar$" }, { class = "^brave-browser$" },
    { title = "^(gedit)$" }, { title = "^(catfish)" }, { float = true },
}) do
    hl.window_rule({ opacity = "0.85 override 0.85 override", match = m })
end
hl.window_rule({ stay_focused = true, match = { title = "^(wofi)$" } })

------------------------------------------------------------------
-- layer rules  (rules.conf)
------------------------------------------------------------------
hl.layer_rule({ animation = "popin 80%", match = { namespace = "launcher" } })
hl.layer_rule({ blur = true, match = { namespace = "launcher" } })
for _, ns in ipairs({ "wofi", "thunar", "gedit", "gtk-layer-shell", "catfish", "brave", "ghostty", "eww_powermenu", "waybar" }) do
    hl.layer_rule({ blur = true, match = { namespace = ns } })
end
hl.layer_rule({ ignore_alpha = 0.5, match = { namespace = "noctalia-background-.*$" } })
hl.layer_rule({ blur = true,       match = { namespace = "noctalia-background-.*$" } })
hl.layer_rule({ blur_popups = true, match = { namespace = "noctalia-background-.*$" } })

------------------------------------------------------------------
-- keybinds  (keybinds.conf)
------------------------------------------------------------------
-- helper: route a dispatcher through hyprctl (works for plugins like hy3
-- and for dispatchers whose Lua hl.dsp wrapper is uncertain).
local function hctl(disp, arg)
    return hl.dsp.exec_cmd("hyprctl dispatch " .. disp .. (arg and (" " .. arg) or ""))
end
local function hy3(arg)  return hctl("hy3:" .. arg) end

-- noctalia-shell shortcuts
hl.bind(mainMod .. " + D",        hl.dsp.exec_cmd("/usr/bin/qs -c noctalia-shell ipc call launcher toggle"))
hl.bind(mainMod .. " + CTRL + D",  hl.dsp.exec_cmd("/usr/bin/qs -c noctalia-shell ipc call settings toggle"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("/usr/bin/qs -c noctalia-shell ipc call sessionMenu toggle"))
hl.bind(mainMod .. " + N",        hl.dsp.exec_cmd("/usr/bin/qs -c noctalia-shell ipc call controlCenter toggle"))
hl.bind(mainMod .. " + ALT + L",   hl.dsp.exec_cmd("/usr/bin/qs -c noctalia-shell ipc call lockScreen lock"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("/usr/bin/qs -c noctalia-shell ipc call notifications clear"))
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))

-- clipboard / window switcher
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("/usr/bin/qs -c noctalia-shell ipc call launcher clipboard"))
hl.bind("ALT + Tab",       hl.dsp.exec_cmd("/usr/bin/qs -c noctalia-shell ipc call launcher windows"))

-- app launches / window ops
hl.bind(mainMod .. " + Return",        hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + T",             hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",             hctl("killactive"))
hl.bind(mainMod .. " + F",             hctl("fullscreen"))
hl.bind(mainMod .. " + SHIFT + space", hctl("togglefloating"))
hl.bind(mainMod .. " + E",             hl.dsp.exec_cmd(fileExplorer))
hl.bind(mainMod .. " + SHIFT + R",     hl.dsp.exec_cmd("~/.config/hypr/scripts/monitors-detect.sh"))

-- function-key apps
hl.bind(mainMod .. " + F1",  hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + F2",  hl.dsp.exec_cmd("thunderbird"))
hl.bind(mainMod .. " + F4",  hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + F6",  hl.dsp.exec_cmd("gparted"))
hl.bind(mainMod .. " + F9",  hl.dsp.exec_cmd("meld"))
hl.bind(mainMod .. " + F12", hl.dsp.exec_cmd("galculator"))

-- blue light filter
hl.bind(mainMod .. " + B",        hl.dsp.exec_cmd("hyprshade on sephia"))
hl.bind(mainMod .. " + CTRL + B",  hl.dsp.exec_cmd("hyprshade off"))

-- brightness
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -c backlight set 5%-"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -c backlight set +5%"))

-- scripts
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_ext_monitors.sh"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/start-workspace-apps.sh"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("~/.config/hypr/scripts/lock-with-monitors.sh"))

-- hy3
hl.bind("mouse:272", hy3("focustab mouse"), { mouse = true })            -- bindn: left-click focuses hy3 tab
hl.bind(mainMod .. " + S", hy3("makegroup opposite force_ephemeral"))
hl.bind(mainMod .. " + W", hy3("changegroup opposite"))
hl.bind(mainMod .. " + X", hy3("changegroup toggletab"))

-- move focus (arrows / ctrl+arrows / ctrl+hjkl)
for _, kp in ipairs({
    { "left",  "l" }, { "right", "r" }, { "up", "u" }, { "down", "d" },
}) do
    hl.bind(mainMod .. " + " .. kp[1],        hy3("movefocus " .. kp[2]))
    hl.bind(mainMod .. " + CTRL + " .. kp[1], hy3("movefocus " .. kp[2]))
end
for _, kp in ipairs({ { "h", "l" }, { "l", "r" }, { "k", "u" }, { "j", "d" } }) do
    hl.bind(mainMod .. " + CTRL + " .. kp[1], hy3("movefocus " .. kp[2]))
end

-- move windows
hl.bind(mainMod .. " + SHIFT + up",    hy3("movewindow u"))
hl.bind(mainMod .. " + SHIFT + down",  hy3("movewindow d"))
hl.bind(mainMod .. " + SHIFT + left",  hy3("movewindow l"))
hl.bind(mainMod .. " + SHIFT + right", hy3("movewindow r"))

-- workspaces
for i = 1, 9 do hl.bind(mainMod .. " + " .. i, hctl("workspace", tostring(i))) end
hl.bind(mainMod .. " + 0", hctl("workspace", "10"))

-- move to workspace
for i = 1, 9 do hl.bind("ALT + SHIFT + " .. i, hctl("movetoworkspace", tostring(i))) end
hl.bind("ALT + SHIFT + 0", hctl("movetoworkspace", "10"))

-- move active window silently
for i = 1, 9 do hl.bind(mainMod .. " + SHIFT + " .. i, hctl("movetoworkspacesilent", tostring(i))) end
hl.bind(mainMod .. " + SHIFT + 0", hctl("movetoworkspacesilent", "10"))

-- scroll workspaces
hl.bind(mainMod .. " + mouse_down", hctl("workspace", "e+1"))
hl.bind(mainMod .. " + mouse_up",   hctl("workspace", "e-1"))

-- mouse move / resize (bindm)
hl.bind(mainMod .. " + mouse:272", hctl("movewindow"),    { mouse = true })
hl.bind(mainMod .. " + mouse:273", hctl("resizewindow"),  { mouse = true })

-- navigation mode
hl.bind(mainMod .. " + CTRL + SHIFT + 0", hl.dsp.exec_cmd("~/.config/hypr/scripts/set_nav_mode.sh toggle"))
hl.bind(mainMod .. " + CTRL + SHIFT + 9", hl.dsp.exec_cmd("~/.config/hypr/scripts/set_nav_mode.sh standard"))
hl.bind(mainMod .. " + CTRL + 0",         hl.dsp.exec_cmd("~/.config/hypr/scripts/set_nav_mode.sh status"))

-- screenshots (fallback)
hl.bind("CTRL + Print",  hl.dsp.exec_cmd(".config/hypr/scripts/screenshot_window.sh"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(".config/hypr/scripts/screenshot_display.sh"))

-- volume
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ 0%"))

-- media
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- resize submap
hl.bind(mainMod .. " + R", hctl("submap", "resize"))
hl.define_submap("resize", function()
    hl.bind("right", hctl("resizeactive", "50 0"),  { ["repeat"] = true })
    hl.bind("L",     hctl("resizeactive", "50 0"),  { ["repeat"] = true })
    hl.bind("left",  hctl("resizeactive", "-50 0"), { ["repeat"] = true })
    hl.bind("H",     hctl("resizeactive", "-50 0"), { ["repeat"] = true })
    hl.bind("up",    hctl("resizeactive", "0 -50"), { ["repeat"] = true })
    hl.bind("K",     hctl("resizeactive", "0 -50"), { ["repeat"] = true })
    hl.bind("down",  hctl("resizeactive", "0 50"),  { ["repeat"] = true })
    hl.bind("J",     hctl("resizeactive", "0 50"),  { ["repeat"] = true })
    hl.bind("escape", hctl("submap", "reset"))
end)

------------------------------------------------------------------
-- autostart  (execs.conf) -- runs once at session start
------------------------------------------------------------------
hl.on("hyprland.start", function()
    -- Lua has no synchronous `plugin = path` directive (text config only).
    -- Load hy3 at startup, then reload so `layout=hy3` + plugin.hy3 options
    -- re-apply with the plugin registered. Sequenced via && to avoid a race.
    -- (layout=hy3 set during config parse is a no-op while hy3 is absent.)
    hl.exec_cmd("hyprctl plugin load /usr/lib64/libhy3.so && hyprctl reload")
    -- exec (every-reload) items -- idempotent, safe to run once
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("hyprctl setcursor catppuccin-mocha-dark-cursors 25")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme catppuccin-mocha-dark-cursors")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 25")
    -- exec-once items
    hl.exec_cmd("dbus-daemon --session --address=unix:path=/run/user/1000/bus --fork")
    hl.exec_cmd("dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hyprland")
    hl.exec_cmd("nm-applet --indicator &")
    hl.exec_cmd("blueman-tray")
    hl.exec_cmd("~/.config/hypr/scripts/monitors-detect.sh")
    hl.exec_cmd("~/.local/bin/wpaperd -d")
    hl.exec_cmd("/usr/libexec/hyprpolkitagent")
    hl.exec_cmd("/usr/bin/qs -c noctalia-shell")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("gentoo-pipewire-launcher &")
    hl.exec_cmd("exec xrdb -load ~/.Xresources")
    hl.exec_cmd("~/.config/hypr/scripts/set_nav_mode.sh standard")
end)
