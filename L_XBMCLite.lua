module("L_XBMCLite", package.seeall)
_VERSION = "0.0.1"
_COPYRIGHT = ""

local ipAddress

local port = 8080
	
local DEBUG_MODE = true

local json = require("json")

local mapping = {
	left = { method = "Input.Left" },
	right = { method = "Input.Right" },
	up = { method = "Input.Up" },
	down = { method = "Input.Down" },
	back = { method = "Input.Back" },
	home = { method = "Input.Home" },
	enter = { method = "Input.Select" },
	contextmenu = { method = "Input.ContextMenu" },
	info = { method = "Input.Info" },
	playpause = { method = "Player.PlayPause", params = { playerid = 1 } },
	stop = { method = "Player.Stop", params = { playerid = 1 } },
	skipnext = { method = "Player.GoNext", params = { playerid = 1 } },
	skipprev = { method = "Player.GoPrevious", params = { playerid = 1 } },
	faster = { method = "Player.SetSpeed", params = { playerid = 1, speed = "increment" } },
	slower = { method = "Player.SetSpeed", params = { playerid = 1, speed = "decrement" } },
	mute = { method = "Application.SetMute", params = { mute = "toggle"; } },
	subtitles = { method = "Input.ExecuteAction", params = { action = "showsubtitles" } },
	reboot = { method = "System.Reboot" },
	suspend = { method = "System.suspend" },
	shutdown = { method = "System.shutdown" },
	audioupdate = { method = "AudioLibrary.Scan" },
	audioclean = { method = "AudioLibrary.Clean" },
	videoupdate = { method = "VideoLibrary.Scan" },
	videoclean = { method = "VideoLibrary.Clean" }
}

local function log(stuff, level)
	luup.log("XBMC Lite: " .. stuff, (level or 50))
end

local function debug(stuff)
	if (DEBUG_MODE) then
		log("debug " .. stuff, 1)
	end
end

function xbmc_json_call( meth, para, msg_id )
	--local cmd = '{"jsonrpc": "2.0", "method": "" .. meth .. "", "params": {" .. para .. "}, "id": 1}'
	
	if ( meth == nil ) then
		debug( "call to xbmc_json_call with nil method, ignore it")
		return false
	end
	
	local request = { jsonrpc = "2.0"; id = 1; }
					
	request.method = meth
	if (para ~= nil) and (type(para) == "table") then request.params = para end
	
	local cmd = "jsonrpc?request=" .. json.encode(request)
	
	debug( "xbmc_json_call with: " .. cmd )
	
	return sendCommand(cmd)		
end

function XBMCall (action)
	debug( "XBMCall: " .. action )

	local method = mapping[action].method
	local params = mapping[action].params
	
	local dbg_str = ""
	if (action ~= nil) then dbg_str = dbg_str .. "action: " .. action end
	if (method ~= nil) then dbg_str = dbg_str .. " method: " .. method end
	if (params ~= nil) then dbg_str = dbg_str .. " params: " .. table.concat(params) end		
	debug( dbg_str )
	
	--curlcall (method, params)
	return xbmc_json_call( method, params )
end


function sendCommand(command)	
	local url = "http://" .. ipAddress .. ":" .. port .. "/" .. command
	luup.log("Sending command " .. url)
	
	local status, data = luup.inet.wget(url)
	if (data) then
		debug("Received response " .. data)
	else
		log("Received empty response")
	end

	return true
end

function init(lul_device)
	log("Setting up XBMCLite Remote")
   	ipAddress = luup.devices[lul_device].ip
end