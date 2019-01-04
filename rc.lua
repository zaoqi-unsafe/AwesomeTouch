local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local freedesktop = require("freedesktop")

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.max,
}

local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end

local mykeyboardheight = 100
local mykeyboardbar = awful.wibar{ position = "bottom", visible = false, height = mykeyboardheight }
local mykeyboard = "xvkbd"
local function update_mykeyboard_height()
    local w, h = root.size()
    if w > h then
        mykeyboardheight = h*0.4
    else
        mykeyboardheight = h*0.2
    end
    mykeyboardheight = math.floor(mykeyboardheight)
    mykeyboardbar:remove()
    mykeyboardbar = awful.wibar{ position = "bottom", visible = false, height = mykeyboardheight }
end
update_mykeyboard_height()
local function set_keyboard()
    awful.spawn("xvkbd -no-keypad")
end
local function kill_keyboard()
    for _, c in ipairs(client.get()) do
        if c.instance == mykeyboard then
            c:kill()
        end
    end
    mykeyboardbar.visible = false
end

myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

    mymainmenu = freedesktop.menu.build({
        before = { { "awesome", myawesomemenu, beautiful.awesome_icon } },
        after =  { { "open terminal", terminal }, { "keyboard", set_keyboard } }
    })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

menubar.utils.terminal = terminal

mytextclock = wibox.widget.textclock("%H:%M")

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end))

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end))

local myclosebutton=awful.widget.button{ image = "/usr/share/awesome/themes/default/titlebar/close_normal.png" }
myclosebutton:buttons(gears.table.join(
    awful.button({}, 1, nil, function()
        local c = client.focus
        if c then
            c:kill()
        end
    end)
))


local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

screen.connect_signal("property::geometry",
    function(s) update_mykeyboard_height() set_wallpaper(s) end)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4" }, s, awful.layout.layouts[1])
    s.mypromptbox = awful.widget.prompt()
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join())
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)
    s.mywibox = awful.wibar({ position = "top", screen = s })
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist,
        {
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            myclosebutton,
            mytextclock,
        },
    }
end)

root.buttons(gears.table.join())
globalkeys = gears.table.join()
clientkeys = gears.table.join()

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c.instance == mykeyboard then
        else
            client.focus = c
        end
        c:raise()
    end))

root.keys(globalkeys)

awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },
    
    { rule = { instance = mykeyboard },
      properties = {
        floating = true,
        above = true,
        skip_taskbar = true, },
      callback = function(kb)
          for _, c in ipairs(client.get()) do
              if c.instance == mykeyboard and c ~= kb then
                  c:kill()
              end
          end
          mykeyboardbar.visible = true
          kb:geometry(mykeyboardbar:geometry())
      end },

    { rule_any = { type = { "dialog" } }, properties = { titlebars_enabled = true }
    },
}

client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("request::titlebars", function(c)
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            if c.instance == mykeyboard then
            else
                client.focus = c
            end
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        {
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {
            {
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        {
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
