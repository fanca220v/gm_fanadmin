fadm.cmds = fadm.cmds or {}

fadm.cmds.command_tags = {'/', '!'} -- first char's for run command

fadm.cmds.fside = {SERVER=1, CLIENT=2, SHARED=3} -- side of CMD function

-- access checkers
fadm.cmds.access_checks = {}
fadm.cmds.AddAccessCheck = function(id, func)
	fadm.cmds.access_checks[id] = func
end
fadm.cmds.AccessCheck = function(player, id, value)
	local f = fadm.cmds.access_checks[id]
	if f then
		return f(player, value)
	end
end

fadm.cmds.AddAccessCheck('meta', function(player, require)
	if not IsValid(player) or not player:IsPlayer() then return true end

	local t = player:GetRank() or {access={}}
	t = t.access['meta'] or {}
	return table.HasValue(t, require), "Require meta (".. require ..")"
end)
fadm.cmds.AddAccessCheck('flag', function(player, require)
	if not IsValid(player) or not player:IsPlayer() then return true end

	local flag = player:GetRank() or {access={}}
	flag = flag.access['flag'] or ""
	return string.find(flag, "*")~=nil or string.find(flag, require)~=nil, "Require flag (".. require ..")"
end)
--[[-------------------------------------------------------------------------
commands

object CMD:
	string uid* -- unique ID
	string nicename* -- nice name
	table commands* -- chat/console commands
	table access* -- access's
	table args* -- arguments
	function svfunc* -- server side function
	function clfunc* -- client side function

	NiceName( string NAME ) -- set nice name ( or get if NAME is nil )
	Argument( int TYPE*, bool REQUIRE*, any ONNIL ) -- add argument
	OnActivate( function( ... )*, side ) -- calling with command run
	SetAccess( string TYPE*, any ALLOW ) -- set access for command
	CommandForActivate( string COMMAND* ) -- chat/console command for call run this command
	Run( player ACTIVATOR*, table ARGS* ) -- run command


Add( string UID* ) -- create CMD object
Get( string UID* ) -- get CMD object
GetByCommand( string COMMAND* ) -- get CMD object with CMD.commands
[SERVER] CommandNotify( ... ) -- formated chat.AddText by server
[SERVER] ExecuteClient( player ACTIVATOR, player TARGET*, string CMD_UID*, table args* ) -- execute command on client
[SERVER] CommandRun( player ACTIVATOR, object CMD*, table ARGS* ) -- execute command on client
---------------------------------------------------------------------------]]

-- nets
if SERVER then

util.AddNetworkString('fanadmin.Execute')

end
--

-- arguments
fadm.cmds.argument = {}
fadm.cmds._argument= {}
fadm.cmds.AddArgument = function(name, nicename)
	local uid = table.Count(fadm.cmds.argument)
	
	local arg = {}
	arg.uid = uid
	arg.name = name
	arg.isvalid = function(activator, arg_, required, i) return (arg_==nil and required~=false) and false or true, ('argument(%s): not valid, require: %s'):format(i, arg.name) end
	arg.autocomplete = function(command, args) return "<".. arg.name ..">" end
	arg.get = function(data) return false end
	arg.menu = function(parent) return false end

	function arg:Valid(func)
		self.isvalid = func
		return self
	end
	function arg:Result(func)
		self.get = func
		return self
	end
	function arg:AutoComplete(func)
		self.autocomplete = func
		return self
	end
	function arg:Menu(func)
		self.menu = func
		return self
	end

	fadm.cmds._argument[arg.uid] = arg
	fadm.cmds.argument[arg.name] = arg.uid
	-- fadm.cmds.argument_nicename[uid] = tostring(nicename or name)
	return arg
end

fadm.cmds.AddArgument("STRING") -- string
:Result(function(string,adata)
	return tostring(string)
end)
:AutoComplete(function(_,_,cmd,required)
	return "<string>"
end)

fadm.cmds.AddArgument("TEXT") -- multi words string( good work only on last argument )
:Result(function(string,adata)
	local args,k = adata.args, adata.i
	local text = ""
	for i=1, #args - k + 1 do
		text = text .." ".. tostring(args[k+i-1])
	end

	return text:Trim()
end)
:AutoComplete(function(_,_,cmd,required)
	return "<text>"
end)

fadm.cmds.AddArgument("INT") -- number
:Valid(function(activator,data,adata)
	return isnumber(tonumber(data))
end)
:Result(function(int,adata)
	return tonumber(int) or 0
end)
:AutoComplete(function(_,_,cmd,required)
	return "<number>"
end)

fadm.cmds.AddArgument("BOOL") -- bool
:Result(function(bool,adata)
	return tobool(bool) or false
end)
:AutoComplete(function(_,_,cmd,required)
	return "<bool>"
end)

local getplayer = function(str,activator)
	if isstring(str) then
		local ent
		if IsValid(activator) and activator:IsPlayer() and str=="@eye" then
			ent = activator:GetEyeTrace().Entity
		elseif IsValid(activator) and activator:IsPlayer() and str=="@me" then
			ent = activator
		else
			ent = player.GetBySteamID(str:Trim()) or player.GetBySteamID64(str:Trim())
			if not IsValid(ent) then
				for _,p in pairs(player.GetAll()) do
					if string.find(p:Name(), str:Trim()) then ent = p break end
				end
			end
		end
		if IsValid(ent) and ent:IsPlayer() then
			return ent
		else
			return false, "Argument(%s): Player not found"
		end
	elseif IsValid(str) and str:IsPlayer() then
		return str
	else
		return false, "Argument(%s): Player not found"
	end
end
fadm.cmds.AddArgument("PLAYER") -- player
:Valid(function(activator,data,adata)
	local ent, reason = getplayer(data, activator)
	return ent==false and false or ent, tostring(reason):format(adata.i)
end)
:Result(function(data,adata)
	return getplayer(data, adata.activator)
end)
:AutoComplete(function(_,_,cmd,required)
	return "<player>"
end)

local getentity = function(str,activator)
	if isstring(str) then
		if IsValid(activator) and activator:IsPlayer() and str=="@me" then
			return activator
		elseif (str=='@eye' and IsValid(activator) and activator:IsPlayer()) then
			local ent = activator:GetEyeTrace().Entity
			if IsValid(ent) then
				return ent
			else
				return false, "Argument(%s): Entity not found"
			end
		else
			local ent = Entity( tonumber(str) or -10 )
			if IsValid(ent) then
				return ent
			else
				return false, "Argument(%s): Entity not found"
			end
		end
	elseif IsValid(str) and IsEntity(str) then
		return str
	else
		return false, "Argument(%s): Entity not found"
	end
end
fadm.cmds.AddArgument("ENTITY") -- entity
:Valid(function(activator,data,adata)
	local ent, reason = getentity(data, activator)
	return ent==false and false or ent, tostring(reason):format(adata.i)
end)
:Result(function(data,adata)
	return getentity(data, adata.activator)
end)
:AutoComplete(function(_,_,cmd,required)
	return "<entity>"
end)

fadm.cmds.AddArgument("STEAMID") -- steamid
:Valid(function(activator,data,adata)
	if IsValid(activator) and activator:IsPlayer() and data=="@me" then
		return activator:SteamID()
	end
	if IsValid(activator) and activator:IsPlayer() and data=="@eye" then
		local ent = activator:GetEyeTrace().Entity
		if IsValid(ent) and ent:IsPlayer() then
			return activator:SteamID()
		end
	end

	return fadm.util:IsSteamID32(data) or fadm.util:IsSteamID64(data)
end)
:Result(function(data,adata)
	local activator = adata.activator
	if IsValid(activator) and activator:IsPlayer() and data=="@me" then
		return activator:SteamID()
	end
	if IsValid(activator) and activator:IsPlayer() and data=="@eye" then
		local ent = activator:GetEyeTrace().Entity
		if IsValid(ent) and ent:IsPlayer() then
			return activator:SteamID()
		end
	end
	if fadm.util:IsSteamID64(data) then
		return util.SteamIDFrom64(data)
	end

	return data
end)
:AutoComplete(function(_,_,cmd,required)
	return "<steamid32>"
end)

fadm.cmds.AddArgument("STEAMID64") -- steamid64
:Valid(function(activator,data,adata)
	if IsValid(activator) and activator:IsPlayer() and data=="@me" then
		return activator:SteamID64()
	end
	if IsValid(activator) and activator:IsPlayer() and data=="@eye" then
		local ent = activator:GetEyeTrace().Entity
		if IsValid(ent) and ent:IsPlayer() then
			return activator:SteamID64()
		end
	end

	return fadm.util:IsSteamID64(data) or fadm.util:IsSteamID32(data)
end)
:Result(function(data,adata)
	local activator = adata.activator
	if IsValid(activator) and activator:IsPlayer() and data=="@me" then
		return activator:SteamID64()
	end
	if IsValid(activator) and activator:IsPlayer() and data=="@eye" then
		local ent = activator:GetEyeTrace().Entity
		if IsValid(ent) and ent:IsPlayer() then
			return activator:SteamID64()
		end
	end

	if fadm.util:IsSteamID64(data) then
		return util.SteamIDTo64(data)
	end
	return data
end)
:AutoComplete(function(_,_,cmd,required)
	return "<steamid64>"
end)


fadm.cmds.__commands = fadm.cmds.__commands or {}
function fadm.cmds:Add(uid)
	uid = tostring(uid)
	local cmd = {}

	cmd.__isfadmcommand = true -- for check this is command
	cmd.uid = uid
	cmd.nicename = uid
	cmd.commands = {}
	cmd.access = {}
	cmd.args = {}
	cmd.svfunc = function()end
	cmd.clfunc = function()end

	function cmd:NiceName(name)
		self.nicename = name or self.nicename

		return name and self or self.nicename
	end
	function cmd:Argument(argtype, require, onnil)
		table.insert(self.args, {
			type = argtype,
			require = require~=false,
			onnil = onnil
		})

		return self
	end
	function cmd:OnActivate(func, side)
		side = side or fadm.cmds.fside.SERVER
		if (side == fadm.cmds.fside.SERVER) or (side == fadm.cmds.fside.SHARED) then
			self.svfunc = func
		elseif (side == fadm.cmds.fside.CLIENT) or (side == fadm.cmds.fside.SHARED) then
			self.clfunc = func
		end

		return self
	end
	function cmd:SetAccess(atype, value)
		self.access[atype] = value

		return self
	end
	function cmd:CommandForActivate(command)
		self.commands[command] = command

		return self
	end
	function cmd:Run(activator, args)
		self[CLIENT and "clfunc" or "svfunc"](activator, unpack(args))

		return self
	end

	self.__commands[uid] = cmd
	return cmd
end
function fadm.cmds:Get(uid)
	return self.__commands[uid]
end
function fadm.cmds:GetByCommand(command)
	for k,v in pairs(self.__commands) do
		if v.commands[command]~=nil then
			return v
		end
	end
end
function fadm.cmds:HasAccess(player, cmd)
	if table.Count(cmd.access)<=0 then
		return true
	end

	if IsValid(player) and player:IsPlayer() then
		for k,v in pairs(cmd.access) do
			if fadm.cmds.AccessCheck(player, k, v) == true then
				return true
			end
		end

		local require = ""
		local first = false
		for k,v in pairs(cmd.access) do
			require = require ..(not first and " " or " or ").. k .."(".. v ..")"
			first = true
		end
		return false, require:Trim()
	end
	return true
end

-- clientside execute
if CLIENT then
	net.Receive('fanadmin.Execute', function() -- client side run
		local cmd = fadm.cmds:Get(net.ReadString())
		if not cmd then return end
		local activator, args = net.ReadEntity(), net.ReadTable()

		cmd:Run( activator, args )
	end)
end

if SERVER then
	function fadm.cmds:CommandNotify(...)
		local args = {...}
		local filter = function()return true end
		if isfunction(args[1]) then
			filter = args[1]
			table.remove(args, 1)
		end
		local _args = {''}
		local color = Color(255,255,255)
		for k,v in pairs(args) do
			if isnumber(v) then
				table.insert(_args, Color(100,100,255))
				table.insert(_args, tostring(v))
			elseif IsColor(v) then
				color = v
			elseif tostring(v)=="[NULL Entity]" then
				table.insert(_args, Color(150,150,255))
				table.insert(_args, "CONSOLE")
			elseif IsValid(v) then
				if v:IsPlayer() then
					table.insert(_args, team.GetColor(v:Team()))
					table.insert(_args, ('%s(%s)'):format(v:Name(), v:SteamID()))
				else
					table.insert(_args, Color(30,30,30))
					table.insert(_args, tostring(v))
				end
			else
				table.insert(_args, color)
				table.insert(_args, tostring(v))
			end
		end
		fadm.util:ChatPrint(filter, unpack(_args))
	end

	function fadm.cmds:ExecuteClient(activator, player, commandid, args)
		if IsValid(player) and player:IsPlayer() and self:Get(commandid) then
			net.Start('fanadmin.Execute')
				net.WriteString(tostring(commandid))
				net.WriteEntity(activator or Entity(0))
				net.WriteTable(args or {})
			net.Send(player)
		end
	end

	function fadm.cmds:ParseArgs(cmd, args, activator)
		local e = {}
		for k,v in pairs(cmd.args) do
			if not args[k] then
				if v.require then
					return false, "Not require argument(".. k ..")"
				end
			end

			local arg =	fadm.cmds._argument[v.type]
			if arg then
				local status, reason = arg.isvalid(activator, args[k], {args = args,i = k})
				-- print(status, reason, args[k], arg.name)
				if status==false then
					if (v.require) then
						return false, tostring(reason or "Argument(".. k .."): invalid")
					else
						e[k] = v.onnil or nil
					end
				else
					e[k] = arg.get(args[k], {args = args,i = k,activator=activator})
				end
			else
				return false, 'argument '.. k .." not exists arg type"
			end
		end
		return e
	end

	function fadm.cmds:CommandRun(activator, cmd, args, full_text)
		if not istable(cmd) or not cmd.__isfadmcommand then return "Not Exist" end

		local acs, acs_reason = self:HasAccess(activator, cmd)
		if not acs then
			return "Access Denied, require: ".. tostring(acs_reason)
		end

		local args, reason = self:ParseArgs(cmd, args, activator)
		if args==false then
			return reason
		end

		cmd:Run(activator, args)
		self:ExecuteClient(activator, activator, cmd.uid, args)
		return "Executed"
	end

	hook.Add('PlayerSay', 'я_fadmin_cmds', function(player, text)

		text = text:Trim()
		if table.HasValue(fadm.cmds.command_tags, text[1]) then
			text = text:sub(2)
			local text_ex = string.Explode(' ', text)
			local cmd = fadm.cmds:GetByCommand(text_ex[1])
			if cmd then
				table.remove(text_ex,1)
				local result = fadm.cmds:CommandRun(player, cmd, text_ex, string.Implode(" ", text_ex))
				if result ~= "Executed" then
					fadm.util:ChatPrint(function(a)return a==player end, Color(255,100,100), ('Command "%s" error: '):format(cmd:NiceName()), Color(255,0,0), result)
				end
			else
				fadm.util:ChatPrint(function(a)return a==player end, Color(255,100,100), ('Command "%s" not exist'):format(text_ex[1]))
			end
			return ''
		end

	end)

	fadm.cmds.ConCommand = function(player, _, args, args_str)
		local cmd = fadm.cmds:GetByCommand(args[1])
		if cmd then
			table.remove(args,1)
			local result = fadm.cmds:CommandRun(player, cmd, args, args_str)
			if result ~= "Executed" then
				fadm.util:ChatPrint(function(a)return a==player end, Color(255,100,100), ('Command "%s" error: '):format(cmd:NiceName()), Color(255,0,0), result)
			end
		else
			fadm.util:ChatPrint(function(a)return a==player end, Color(255,100,100), ('Command "%s" not exist'):format(args[1]))
		end
	end
	concommand.Add('_fanadmin_cmd', fadm.cmds.ConCommand)
end
fadm.cmds.ConAutoComplete = function(command, str)
	local tbl = {}
	local args = string.Explode(' ', str)
	table.remove(args,1)
	local commands = {}
	for k,v in pairs(fadm.cmds.__commands) do
		for i,val in pairs(v.commands) do
			if fadm.cmds:HasAccess(CLIENT and LocalPlayer() or Entity(0), v) then
				if args[1]==' ' or string.find(i, args[1]) then
					table.insert(commands, command .." ".. i)
				end
			end
		end
	end
	tbl = commands
	if (#commands==1 and args[2]) then
		tbl = commands
		table.remove(args, 1)

		local cmd = fadm.cmds:GetByCommand(tbl[1]:Trim():Replace(command .." ", ""))
		if cmd then
			local _args = {}
			for k,v in pairs(cmd.args) do
				if args[k] and args[k]~="" then
					table.insert(_args, tostring(args[k]))
				else
					--table.insert(_args, ("<%s>"):format(tostring(fadm.cmds.argument_nicename[v.type])))
					local arg = fadm.cmds._argument[v.type]
					if (arg) then
						table.insert(_args, arg.autocomplete(command, args, cmd, v.require))
					else
						table.insert(_args, "<?>")
					end
				end
			end
			tbl = {tbl[1] .." ".. string.Implode(" ", _args)}
		end
	end

	return tbl
end
local run = (SERVER) and fadm.cmds.ConCommand or function(p, c, a, str) p:ConCommand('_fanadmin_cmd ' .. str) end
concommand.Add('adm', run, fadm.cmds.ConAutoComplete)
concommand.Add('admin', run, fadm.cmds.ConAutoComplete)

fadm.cmds:Add('credits')
:CommandForActivate('_')
:CommandForActivate('acredits')
:Argument(fadm.cmds.argument.INT, false, 1)
:OnActivate(function(activator, num)
	fadm.cmds:CommandNotify(function(p) return p==activator end, ([[
FAN Admin Module Credits
> Author: fanca.smrtcommunity.com
> Version: %s(%s)
	]]):format(fadm.version, fadm.version_date))
end)