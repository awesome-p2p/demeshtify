#!/usr/bin/lua

local max_lines = 300
local log_file = "/www/log/wifiassoclist.json"
local iw = require "iwinfo"
local dev = "wlan0-1"


local t = assert(iw.type(dev), "Not a wireless device")

local f = assert(io.open(log_file, "a"), "Cannot open")

local n, cell
local al = iw[t].assoclist(dev)
if al and next(al) then
    for n, cell in pairs(al) do
--        print(n, cell.signal, cell.noise )
        f:write(string.format("{\"BSSID\": %q,\"Signal\": %q,\"Noise\": %q,\"Date\": %q },\n", n, cell.signal, cell.noise, os.date() ))
    end
end

os.exit(0)