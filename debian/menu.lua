-- automatically generated file. Do not edit (see /usr/share/doc/menu/html)

local awesome = awesome

Debian_menu = {}

Debian_menu["Debian_窗口管理器"] = {
	{"awesome",function () awesome.exec("/usr/bin/awesome") end,"/usr/share/pixmaps/awesome.xpm"},
}
Debian_menu["Debian_应用程序_Shell"] = {
	{"Bash", "x-terminal-emulator -e ".."/bin/bash --login"},
	{"Dash", "x-terminal-emulator -e ".."/bin/dash -i"},
	{"Sh", "x-terminal-emulator -e ".."/bin/sh --login"},
}
Debian_menu["Debian_应用程序_系统_管理"] = {
	{"Editres","editres"},
	{"Xfontsel","xfontsel"},
	{"Xkill","xkill"},
	{"Xrefresh","xrefresh"},
}
Debian_menu["Debian_应用程序_系统_系统监控"] = {
	{"Pstree", "x-terminal-emulator -e ".."/usr/bin/pstree.x11","/usr/share/pixmaps/pstree16.xpm"},
	{"Top", "x-terminal-emulator -e ".."/usr/bin/top"},
	{"Xev","x-terminal-emulator -e xev"},
}
Debian_menu["Debian_应用程序_系统_硬件"] = {
	{"Xvidtune","xvidtune"},
}
Debian_menu["Debian_应用程序_系统"] = {
	{ "管理", Debian_menu["Debian_应用程序_系统_管理"] },
	{ "系统监控", Debian_menu["Debian_应用程序_系统_系统监控"] },
	{ "硬件", Debian_menu["Debian_应用程序_系统_硬件"] },
}
Debian_menu["Debian_应用程序"] = {
	{ "Shell", Debian_menu["Debian_应用程序_Shell"] },
	{ "系统", Debian_menu["Debian_应用程序_系统"] },
}
Debian_menu["Debian"] = {
	{ "窗口管理器", Debian_menu["Debian_窗口管理器"] },
	{ "应用程序", Debian_menu["Debian_应用程序"] },
}

debian = { menu = { Debian_menu = Debian_menu } }
return debian