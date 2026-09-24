-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
 hl.on("hyprland.start", function ()
  hl.exec_cmd("hypridle")
  hl.exec_cmd("quickshell -c ~/.config/quickshell/end4-sl &")
  hl.exec_cmd("nm-applet --indicator")

  -- setup screen sharing
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

  -- setup clipboard 
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

end)
