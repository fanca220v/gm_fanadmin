--[[-------------------------------------------------------------------------
Setup your ranks =)
---------------------------------------------------------------------------]]
fadm.rank:Add('core'):NiceName('Server Lord'):Immune(696)
:SetAccess('flag', "*")
:SetAccess('meta', {
	'vip', 'admin', 'superadmin', 'root', 'core'
})

fadm.rank:Add('root'):NiceName('root'):Immune(5)
:SetAccess('flag', "*")
:SetAccess('meta', {
	'vip', 'admin', 'superadmin', 'root'
})

fadm.rank:Add('superadmin'):NiceName('Super-Administrator'):Immune(4)
:SetAccess('flag', "aAS")
:SetAccess('meta', {
	'vip', 'admin', 'superadmin'
})

fadm.rank:Add('admin'):NiceName('Administrator'):Immune(3)
:SetAccess('flag', "aA")
:SetAccess('meta', {
	'vip', 'admin'
})

fadm.rank:Add('operator'):NiceName('Operator'):Immune(2)
:SetAccess('flag', "a")
:SetAccess('meta', {
	'vip', 'admin'
})

fadm.rank:Add('vip'):NiceName('VIP'):Immune(1)
:SetAccess('meta', {
	'vip'
})