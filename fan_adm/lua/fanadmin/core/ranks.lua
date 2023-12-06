fadm.rank = {}
--[[-------------------------------------------------------------------------
player rank module


---------------------------------------------------------------------------]]

fadm.rank._ranks = {}
function fadm.rank:Add(uid)
	uid = tostring(uid)
	local rank = {}
	rank.uid = uid
	rank.nicename = uid
	rank.access = {}
	rank.immune = 0

	function rank:Immune(int)
		self.immune = int or self.immune

		return int and self or self.immune
	end
	function rank:NiceName(name)
		self.nicename = name or self.nicename

		return name and self or self.nicename
	end
	function rank:SetAccess(type, value)
		self.access[type] = value
		return self
	end

	self._ranks[rank.uid] = rank
	return rank
end
function fadm.rank:Get(uid)
	return self._ranks[uid]
end
--
if SERVER then
	if not fadm.database then include('_database_sv.lua') end
	fadm.database:Query('CREATE TABLE IF NOT EXISTS fandmin_player( sid BIGINT, name VARCHAR(255), first_seen INT, last_seen INT, playtime INT, ug_id VARCHAR(255), ug_expire INT, ug_toid VARCHAR(255), ug_time INT )', function()
		fadm:print("initilize player database")
	end)

	function fadm.rank:Load(pl, callback)
		if not IsValid(pl) then return end

		self:GetPlayer(pl:SteamID64(), function(data)
			data = data and data[1] or {}
			if (table.Count(data)>0) then
				local RANK = self:Get(data.ug_id)
				pl:SetUserGroup(RANK and data.ug_id or "user")
				pl:SetNW2Int('fanadm_expire_rank', tonumber(data.ug_expire or -1) or -1)
				pl:SetNW2Int('fanadm_last_seen', os.time())
				pl:SetNW2Int('fanadm_first_seen', tonumber(data.first_seen or 0) or 0)
				pl:SetNW2Int('playtime', tonumber(data.playtime or 0) or 0)
				fadm.database:Query(([[
UPDATE fandmin_player
SET last_seen = %s, name = %s
WHERE sid = %s
				]]):format(
					sql.SQLStr(os.time()),
					sql.SQLStr(pl:Name()),
					sql.SQLStr(steamid)
				), function()
					-- fadm:print("update player ".. steamid .." rank ".. pl:GetUserGroup())
				end)
			else
				fadm.rank:Set(pl:SteamID64(), 'user')
			end

			if isfunction(callback) then
				callback(data)
			end
		end)
	end
	function fadm.rank:GetPlayer(steamid, callback)
		local p = player.GetBySteamID(tostring(steamid)) or player.GetBySteamID64(tostring(steamid))
		if IsValid(p) and p:IsPlayer() then steamid=p end
		if IsValid(steamid) and steamid:IsPlayer() then
			name = steamid:Name()
			steamid = steamid:SteamID()
		end

		fadm.database:Query('SELECT * FROM fandmin_player WHERE sid='.. sql.SQLStr(steamid), function(data)
			if isfunction(callback) then
				callback(data)
			end
		end)
	end
	function fadm.rank:Set(steamid, rank, expire_data, callback)
		expire_data = expire_data or {}
		local name = "unknown"
		local p = player.GetBySteamID(tostring(steamid)) or player.GetBySteamID64(tostring(steamid))
		if IsValid(p) and p:IsPlayer() then steamid=p end
		if IsValid(steamid) and steamid:IsPlayer() then
			-- steamid:SetNW2String('usergroup', rank or "user")
			p = steamid
			name = steamid:Name()
			steamid = steamid:SteamID()
		end

		rank = self:Get(rank)
		if (rank) then
			fadm.database:Query('SELECT * FROM fandmin_player WHERE sid='.. sql.SQLStr(steamid), function(data)
				if (data) then
					fadm.database:Query(([[
UPDATE fandmin_player
SET ug_id = %s, ug_expire = %s, ug_toid = %s, last_seen = %s, name = %s, ug_time = %s
WHERE sid = %s
					]]):format(
						sql.SQLStr(rank.uid),
						sql.SQLStr(expire_data[1] or "-1"),
						sql.SQLStr(expire_data[2] or "user"),
						sql.SQLStr(os.time()),
						sql.SQLStr(name),
						sql.SQLStr(os.time()),
						sql.SQLStr(steamid)
					), function()
						fadm:print("update player ".. steamid .." rank ".. rank.uid)
						if IsValid(p) and p:IsPlayer() then
							fadm.rank:Load(p)
						end
					end)
				else
					fadm.database:Query(([[
INSERT INTO fandmin_player VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s)
					]]):format(
						sql.SQLStr(steamid),
						sql.SQLStr(name),
						sql.SQLStr(os.time()),
						sql.SQLStr(os.time()),
						sql.SQLStr(0),
						sql.SQLStr(rank.uid),
						sql.SQLStr(-1),
						sql.SQLStr('user'),
						sql.SQLStr(os.time())
					), function()
						fadm:print("set player ".. steamid .." rank ".. rank.uid)
						if IsValid(p) and p:IsPlayer() then
							fadm.rank:Load(p)
						end
					end)
				end

				if isfunction(callback) then
					callback(data)
				end
			end)
		else
			if isfunction(callback) then
				callback(false, "Rank not exists")
			end
		end
	end

	hook.Add('PlayerInitialSpawn', 'fanadmin_first_spawn', function(pl)
		fadm.rank:Load(pl)
		fadm:print(pl:Name() .." initilized")
	end)
end
--
local PLAYER = FindMetaTable('Player')
function PLAYER:GetUserGroup()
	return self:GetNW2String('usergroup', "user")
end
function PLAYER:SetUserGroup(group)
	return self:SetNW2String('usergroup', group)
end
function PLAYER:GetRank()
	return fadm.rank:Get(self:GetUserGroup())
end

local ismeta = function(pl, meta)
	local rank = pl:GetRank() or {access={}}
	rank.access['meta'] = rank.access['meta'] or {}

	return table.HasValue(rank.access['meta'], 'core') or table.HasValue(rank.access['meta'], meta)
end
function PLAYER:IsCore()
	return ismeta(self, 'core')
end
function PLAYER:IsRoot()
	return ismeta(self, 'root')
end
function PLAYER:IsSuperAdmin()
	return ismeta(self, 'superadmin')
end
function PLAYER:IsAdmin()
	return ismeta(self, 'admin')
end
function PLAYER:IsVIP()
	return ismeta(self, 'vip')
end
PLAYER.IsVip = PLAYER.IsVIP



fadm.rank:Add('user')