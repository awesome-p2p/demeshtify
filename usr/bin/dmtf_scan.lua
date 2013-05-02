#!/usr/bin/lua

local max_lines = 300
local log_file = "/www/log/wifiscan.json"

local iw = require "iwinfo"
local dev = "wlan0"

local t = assert(iw.type(dev), "Not a wireless device")
local f = assert(io.open(log_file, "a"), "Cannot open")

local n, cell
for n, cell in ipairs(iw[t].scanlist(dev)) do
    f:write(string.format(
        "{\"BSSID\": %q,\"SSID\": %q,\"Mode\": %q,\"Channel\": \"%d\",\"Signal\": \"%d\",\"Quality\": \"%d\", \"Max_Quality\": \"%d\",\"Encryption\": %q,\"ScanDate\": %q },\n",
        cell.bssid, cell.ssid, cell.mode, cell.channel,
        cell.signal, cell.quality, cell.quality_max,
        cell.encryption.description, os.date()
    ))
end

f:close()
-- Count the number of lines
local lines = 0
local ll = assert(io.lines(log_file), "Can't open log")
for _ in ll do
	lines=lines+1
end

-- Reduce filesize by removing lines from the beginning of file to reduce to max_lines
if lines >= max_lines then
	local ldel = lines - max_lines
    -- this constructs a sed command to delete the first ldel number of lines from the log file
	local sed_command = "sed -i '1,"..ldel.."d' "..log_file
    os.execute(sed_command)
end
--print("Number of lines is:", lines)


os.exit(0)