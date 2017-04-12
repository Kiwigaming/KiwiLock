function Initialize( Plugin )
	PLUGIN = Plugin
	Plugin:SetName( "KiwiLock" )
	Plugin:SetVersion( 1 )
	PluginManager = cRoot:Get():GetPluginManager()
	PluginManager:AddHook(cPluginManager.HOOK_PLAYER_USING_BLOCK, OnPlayerUsingBlock);
	PluginManager:AddHook(cPluginManager.HOOK_PLAYER_BREAKING_BLOCK, OnPlayerBreakingBlock);
	PluginManager:AddHook(cPluginManager.HOOK_UPDATING_SIGN, OnUpdatingSign);
	
	if LoadSettings(PLUGIN:GetLocalFolder() .. "/Config.ini") == true then
		LOGWARN( "Error while loading settings" )
	end
	LOG("Initialized " .. PLUGIN:GetName() .. " v" .. PLUGIN:GetVersion())
	return true
end

function OnDisable()
	LOG( PLUGIN:GetName() .. " v" .. PLUGIN:GetVersion() .. " is shutting down..." )
end

switch = function(cases,arg)
	return assert (loadstring ('return ' .. cases[arg]))()
end