--[[-------------------------------------------------------------------------
test commands
---------------------------------------------------------------------------]]

fadm.cmds:Add('setrank')
:CommandForActivate('setgroup')
:CommandForActivate('setrank')
:Argument(fadm.cmds.argument.STEAMID64)
:Argument(fadm.cmds.argument.STRING)
:OnActivate(function(activator, sid, rank)
	fadm.rank:Set(sid, rank, nil, function(b, t)
		if b==false then
			fadm.cmds:CommandNotify(function(p) return p==activator end, "Ошибка при выдачи ранга: ", Color(255,0,0), t)
		else
			fadm.cmds:CommandNotify(activator, " поставил ранг ", Color(150,150,150), rank, Color(255,255,255), " игроку ", fadm.util:GetPlayer(sid:Trim()))
		end
	end)
end)

fadm.cmds:Add('getrank')
:CommandForActivate('getgroup')
:CommandForActivate('getrank')
:OnActivate(function(activator)
	fadm.cmds:CommandNotify(function(p) return p==activator end, activator:GetUserGroup())
end)

fadm.cmds:Add('addbots')
:CommandForActivate('bots')
:SetAccess('meta', 'core')
:Argument(fadm.cmds.argument.INT, false, 1)
:OnActivate(function(activator, num)
	for i=1,num do
		RunConsoleCommand('bot')
	end
	fadm.cmds:CommandNotify(activator, " добавил ", num, " ботов(а)")
end)

fadm.cmds:Add('kill')
:CommandForActivate('kill')
:SetAccess('flag', 'S')
:Argument(fadm.cmds.argument.PLAYER)
:OnActivate(function(activator, target)
	target:Kill()
	fadm.cmds:CommandNotify(activator, " убил ", target)
end)

fadm.cmds:Add('tellall')
:CommandForActivate('tellall')
:SetAccess('flag', '*')
:Argument(fadm.cmds.argument.TEXT)
:OnActivate(function(activator, text)
	fadm.cmds:CommandNotify(Color(255,0,0), "ВНИМАНИЕ! ", Color(255,255,255), text)
end)

fadm.cmds:Add('sethealth')
:CommandForActivate('hp')
:CommandForActivate('sethealth')
:SetAccess('flag', 'S')
:Argument(fadm.cmds.argument.PLAYER)
:Argument(fadm.cmds.argument.INT)
:OnActivate(function(activator, player, i)
	player:SetHealth(i)
	fadm.cmds:CommandNotify(activator, " поставил ", player, i, " хп")
end)

fadm.cmds:Add('scale')
:CommandForActivate('scale')
:SetAccess('flag', '*')
:SetAccess('meta', 'ivent')
:Argument(fadm.cmds.argument.ENTITY)
:Argument(fadm.cmds.argument.INT)
:OnActivate(function(activator, ent, i)
	ent:SetModelScale(i)
	fadm.cmds:CommandNotify(activator, " поставил ", ent, " размер ", i)
end)

fadm.cmds:Add('concommand')
:Argument(fadm.cmds.argument.TEXT)
:CommandForActivate('console')
:NiceName('КОНСОЛЬ')
:SetAccess('meta', 'core')
:OnActivate(function(activator, command)
	RunConsoleCommand(unpack(string.Explode(" ",command)))
end)

-- test
fadm.cmds:Add('test')
:Argument(fadm.cmds.argument.PLAYER, true, "Плеера нету")
:Argument(fadm.cmds.argument.STRING, false, "Стринга нету")
:Argument(fadm.cmds.argument.INT, false, "Интеджера нету")
:Argument(fadm.cmds.argument.STEAMID, false, "steamdi32 нету")
:Argument(fadm.cmds.argument.STEAMID64, false, "steamdi64 нету")
:Argument(fadm.cmds.argument.TEXT, false, "Текста нету")
:CommandForActivate('testcmd')
:NiceName('ТЕСТОВАЯ')
:SetAccess('meta', 'core')
:OnActivate(function(activator, player, string, int, sid, sid64, text)
	chat.AddText(
		team.GetColor(activator:Team()), tostring(activator),
		Color(255,0,0), tostring(player),
		Color(255,255,255), tostring(string),
		Color(100,100,255), tostring(int),
		Color(255,100,100), tostring(sid),
		Color(255,100,255), tostring(sid64),
		Color(100,255,100), tostring(text)
	)
end, fadm.cmds.fside.CLIENT)