#!/usr/bin/lua

local max_lines = 25
local lstart = 0
local dev = "wlan0"
local log_file = "/www/log/wifiscan.json"
local log_tmp = "/www/log/wifiscan.tmp"

local iw = require "iwinfo"
local t = assert(iw.type(dev), "Not a wireless device")
                   
local fi = assert(io.open(log_file, "r"), "Cannot open log for reading")
local fo = assert(io.open(log_tmp, "w"), "Cannot open temporary file")  

-- Count the number of lines
local lc = 0
local ll = assert(io.lines(log_file), "Can't open log")
for _ in ll do
	lc = lc + 1
end

if (lc > max_lines) then
	lstart = lc - max_lines - 1
  fo:write("\{ \"items\": \[\n")
else
  lstart = 0
end

local i = 1
for line in fi:lines() do 
	if ( (i > lstart) and (i < lc) ) then
 		fo:write(string.format("%s\n", line)) 
	end
	i = i + 1
end

local n, cell
local wscan = iw[t].scanlist(dev)
local last = table.getn(wscan)  -- calculate size of the array
for n, cell in ipairs(wscan) do
    if (n < last) then
      fo:write(string.format(
          "{\"BSSID\": %q,\"SSID\": %q,\"Mode\": %q,\"Channel\": \"%d\",\"Signal\": \"%d\",\"Quality\": \"%d\", \"Max_Quality\": \"%d\",\"Encryption\": %q,\"ScanDate\": %q },\n",
          cell.bssid, cell.ssid, cell.mode, cell.channel,
          cell.signal, cell.quality, cell.quality_max,
          cell.encryption.description, os.date()
      ))
    else
      fo:write(string.format(
          "{\"BSSID\": %q,\"SSID\": %q,\"Mode\": %q,\"Channel\": \"%d\",\"Signal\": \"%d\",\"Quality\": \"%d\", \"Max_Quality\": \"%d\",\"Encryption\": %q,\"ScanDate\": %q }\n",
          cell.bssid, cell.ssid, cell.mode, cell.channel,
          cell.signal, cell.quality, cell.quality_max,
          cell.encryption.description, os.date()
      ))
    end
end
fo:write("\]\}\n")
fo:close()
os.remove(log_file)
os.rename(log_tmp, log_file)
