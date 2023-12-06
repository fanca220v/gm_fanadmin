--[[-------------------------------------------------------------------------
Initilize ui
---------------------------------------------------------------------------]]

timer.Simple(1, function()
	fadm.ui = {}
	function fadm.ui:Open()
		chat.AddText('opened')
	end
end)

fadm.cmds:Add('menu')
:CommandForActivate('menu')
:OnActivate(function(activator)
	if fadm.ui then
		fadm.ui:Open()
	end
end, fadm.cmds.fside.CLIENT)