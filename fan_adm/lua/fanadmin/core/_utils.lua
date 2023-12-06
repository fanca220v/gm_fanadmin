fadm.util = {}
--[[-------------------------------------------------------------------------
utility functions

:OnInitilized( function(table fadm) ) -- add function on full loaded server.
:ClientChat(player PLAYER*, ...) -- chat.AddText(...) with server
:ChatPrint(function FILTER, ...) -- :ClientChat() for many player
:ChatPrint(any STEAMID32/STEAMID64/NAME*, bool ALLOW_BY_NAME) -- get player by data
---------------------------------------------------------------------------]]

fadm.util.__init_functions = {}
function fadm.util:OnInitilized(func)
	if not isfunction(func) then return end
	table.insert(self.__init_functions, func)
	return self
end
hook.Add('InitPostEntity', 'fanadmin_init', function()
	for k,v in pairs(fadm.util.__init_functions) do
		v(fadm)
	end
end)

--
if SERVER then
	util.AddNetworkString('fadmin.writechatonclient')

	function fadm.util:ClientChat(player, ...)
		net.Start('fadmin.writechatonclient')
			net.WriteTable({...})
		net.Send(player)
	end
	function fadm.util:ChatPrint(filter, ...)
		fadm:print(Color(255,100,100), "~ ", Color(255,255,255), ...)
		if isfunction(filter) then
			for k,v in pairs(player.GetAll()) do
				if filter(v) then
					fadm.util:ClientChat(v, Color(255,100,100), "~ ", Color(255,255,255), ...)
				end
			end
		else
			for k,v in pairs(player.GetAll()) do
				fadm.util:ClientChat(v, Color(255,100,100), "~ ", Color(255,255,255), filter, ...)
			end
		end
	end
else
	net.Receive('fadmin.writechatonclient', function()
		chat.AddText(unpack(net.ReadTable()))
	end)
end
--
function fadm.util:GetPlayer(anydata, byname)
	anydata = anydata or ""
	for k,v in pairs(player.GetAll()) do
		if (v:SteamID()==anydata) then return v end
		if (v:SteamID64()==anydata) then return v end
		if (string.find(v:Name(), anydata)) and byname then return v end
	end
	return anydata
end
--
function fadm.util:IsSteamID32(str)
	return string.find(str or '',"STEAM_")~=nil
end
function fadm.util:IsSteamID64(str)
	return util.SteamIDTo64(str or "")~='0' and true or false
end