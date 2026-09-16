------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "1920x1200@60",
    position = "auto-left",
    scale    = "1",
})

-- Dupelicate extrenal monitor enable if you needed
-- hl.monitor({
--    output  = "HDMI-A-1",
--    mode    = "1920x1200@120",
--    position= "0x0",
--    scale   = "1",
--    mirror  = "eDP-1",
--})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@120",
    position = "0x0",
    scale    = "1",
    mirror   = "true",
})
