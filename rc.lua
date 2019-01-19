--    AWESOMEWM/touchscreen
--    Copyright (C) 2019  Zaoqi <zaomir@outlook.com>

--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU Affero General Public License as published
--    by the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.

--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU Affero General Public License for more details.

--    You should have received a copy of the GNU Affero General Public License
--    along with this program.  If not, see <https://www.gnu.org/licenses/>.

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local freedesktop = require("fdo")

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify{
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors }
end

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

local terminal = "x-terminal-emulator"
local editor = os.getenv("EDITOR") or "editor"
local editor_cmd = terminal .. " -e " .. editor

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.max,
}

local mykeyboardheight = 100
local mykeyboardbar = awful.wibar{ position = "bottom", visible = false, height = mykeyboardheight }
local mykeyboard = "xvkbd"
local function update_mykeyboard_height()
    local w, h = root.size()
    if w > h then
        mykeyboardheight = h*0.35
    else
        mykeyboardheight = h*0.2
    end
    mykeyboardheight = math.floor(mykeyboardheight)
    mykeyboardbar:remove()
    mykeyboardbar = awful.wibar{ position = "bottom", visible = false, height = mykeyboardheight }
end
update_mykeyboard_height()
local function set_mykeyboard()
    awful.spawn("xvkbd -no-keypad")
end
local function kill_mykeyboard()
    for _, c in ipairs(client.get()) do
        if c.instance == mykeyboard then
            c:kill()
        end
    end
    mykeyboardbar.visible = false
end
local function mykeyboard_running()
    for _, c in ipairs(client.get()) do
        if c.instance == mykeyboard then
            return true
        end
    end
    return false
end
screen.connect_signal("tag::history::update", function() if mykeyboard_running() then set_mykeyboard() end end)

local myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

local mymainmenu = freedesktop.menu.build{
    before = {
        { "awesome", myawesomemenu, beautiful.awesome_icon }
    },
    after = {
        { "open terminal", terminal },
        { "keyboard", {
            { "on", set_mykeyboard },
            { "off", kill_mykeyboard }}},
    }
}
local mylauncher = awful.widget.launcher{
    image = beautiful.awesome_icon,
    menu = mymainmenu }

menubar.utils.terminal = terminal

local mytextclock = wibox.widget.textclock("%H:%M")

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
    function(s)
        update_mykeyboard_height()
        if mykeyboard_running() then set_mykeyboard() end
        set_wallpaper(s) end)

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
    local rtwi, rtht = root.size()
    local mywiht = math.floor(math.max(rtwi, rtht)*0.04)
    s.mywibox = awful.wibar{ position = "top", screen = s, height = mywiht }
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
local globalkeys = gears.table.join()
local clientkeys = gears.table.join()

local clientbuttons = gears.table.join(
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
      properties = {
          border_width = beautiful.border_width,
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

    { rule_any = { type = { "dialog" } },
      properties = {
        floating = true,
        titlebars_enabled = true, },
      callback = function(c)
          local cg = c:geometry()
          local s = awful.screen.focused()
          local wg = s.workarea
          if cg.x+cg.width > wg.x+wg.width or cg.y+cg.height > wg.y+wg.height then
              c.floating = false
              awful.titlebar.hide(c)
          else
              c.floating = true
              awful.titlebar.show(c)
          end
      end },
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
