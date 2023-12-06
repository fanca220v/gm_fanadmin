fadm.database = {}
--[[-------------------------------------------------------------------------
Database functions
---------------------------------------------------------------------------]]

function fadm.database:Query(q, callback)
	local result = sql.Query(q)
	callback(result)
end