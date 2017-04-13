

function LoadSettings(Path)
    SettingsIni = cIniFile()
    SettingsIni:ReadFile(Path)
    ShowAdminBreach = SettingsIni:GetValueSetB("General", "ShowAdminBreach", false)

    if ShowAdminBreach == nil then
        return true
    end
end

function isAtChest(BlockX, BlockY, BlockZ, World)
	local sides = getAllSideCoords(BlockX, BlockY, BlockZ)
	local i
	for key, value in pairs(sides) do
		if World:GetBlock(value['x'], value['y'], value['z']) == 54 then
			i = World:GetBlockMeta(BlockX, BlockY, BlockZ) + value['f']
			if World:GetBlockMeta(BlockX, BlockY, BlockZ) + value['f'] == 9 or 5 then
				return true
			end
		end
	end
	return false
end

function getChestFromSign(BlockX, BlockY, BlockZ, World)
	local sides = getAllSideCoords(BlockX, BlockY, BlockZ)
	local i
	local chest = {}
	for key, value in pairs(sides) do
		if World:GetBlock(value['x'], value['y'], value['z']) == 54 then
			i = World:GetBlockMeta(BlockX, BlockY, BlockZ) + value['f']
			if World:GetBlockMeta(BlockX, BlockY, BlockZ) + value['f'] == 9 or 5 then
				chest[1] = { x = BlockX, y = BlockY, z = BlockZ } 
				print("test")
				print(chest[1]['x'], chest[1]['y'], chest[1]['z'])
				return chest
			end
		end
	end
end

function getSigns(BlockX, BlockY, BlockZ, World)
--	alle Schilder des Komplexes	
--  signs = x y z f(Ausrichtung/Meta)
	local signs = {}
	local i = 1
	local sides = {}
	local chests = getChests(BlockX, BlockY, BlockZ, World)
	local signLines = {}
	for key, value in pairs(chests) do
		sides = getAllSideCoords(value['x'], value['y'], value['z'])
		for key, value in pairs(sides) do
			if World:GetBlock(value['x'], value['y'], value['z']) == 68 and 
			   World:GetBlockMeta(value['x'], value['y'], value['z']) == value['f'] then
				signLines = { World:GetSignLines(value['x'], value['y'], value['z']) }
				if signLines[2] == "[P]" or signLines[2] == "[Private]" then
					print("getSigns")
					print(value['x'], value['y'], value['z'])
					signs[i] = { x = value['x'], y = value['y'], z = value['z'], f = World:GetBlockMeta(value['x'], value['y'], value['z']) }
					i = i + 1
				end
			end
		end
	end
	return signs
end

function getChests(BlockX, BlockY, BlockZ, World)
--	alle Truhen des Komplexes
	local chests = {}
--	chests = x y z
	
	local sides = {}
	if World:GetBlock(BlockX, BlockY, BlockZ) == 54 then -- Block ist Truhe
		chests[1] = { x = BlockX, y = BlockY, z = BlockZ }
	else -- Block ist Schild
		chests = getChestFromSign(BlockX, BlockY, BlockZ, World)
 if chests[1] ~= nil then print(chests[1]['x'], chests[1]['y'], chests[1]['z']) end
--		sides = getAllSideCoords(BlockX, BlockY, BlockZ)
--		for key, value in pairs(sides) do
--			if World:GetBlock(value['x'], value['y'], value['z']) == 54 then
--				chests[1] = { x = value['x'], y = value['y'], z = value['z'] }
--			end
--		end
	end
	sides = getAllSideCoords(chests[1]['x'], chests[1]['y'], chests[1]['z']) -- Zweite Truhe
		for key, value in pairs(sides) do
		

			if World:GetBlock(value['x'], value['y'], value['z']) == 54 then
--				if value['x'] ~= chests[1]['x'] or value['y'] ~= chests[1]['y'] or value['z'] ~= chests[1]['z'] then
					chests[2] = { x = value['x'], y = value['y'], z = value['z'] }
--				end
			end
		end
 print("getChests")
 if chests[1] ~= nil then print(chests[1]['x'], chests[1]['y'], chests[1]['z']) end
 if chests[2] ~= nil then print(chests[2]['x'], chests[2]['y'], chests[2]['z']) end
	return chests
end

function getAllSideCoords(BlockX, BlockY, BlockZ)
    local sides = {}
    sides['+x'] = { x = BlockX + 1, y = BlockY, z = BlockZ, f = 5, s = '+x' }
    sides['-x'] = { x = BlockX - 1, y = BlockY, z = BlockZ, f = 4, s = '-x' }
    sides['+z'] = { x = BlockX, y = BlockY, z = BlockZ + 1, f = 3, s = '+z' }
    sides['-z'] = { x = BlockX, y = BlockY, z = BlockZ - 1, f = 2, s = '-z' }
--	print(sides['-x']['x'], sides['-x']['y'], sides['-x']['z'], sides['-x']['f'], sides['-x']['s'])
    return sides;
end



-- 4 Anwendungsfälle: Schild wird gesetzt, Schild wird zerstört, Truhe wird benutzt, Truhe wird zerstört 

-- REMINDER: Damit Owner immer gleich force: Line2 = User + destroy: nur von User in Line2

function PlayerHasBlockAccess(Player, BlockX, BlockY, BlockZ, World, PermissionType)
	local signs = getSigns(BlockX, BlockY, BlockZ, World)
	if	signs[1] == nil then
		return true
	end
	local sign = {}
    for key, value in pairs(signs) do
		sign = { World:GetSignLines(value['x'], value['y'], value['z']) }
		if PermissionType == 'Owner' then
			if CheckSignOwner(sign, Player) then
				return true
			end
		elseif PermissionType == 'User' then				
			if CheckSignPermission(sign, Player) then
				return true
			end
		end
    end
    return false
end

function CheckProtectedSign(BlockX, BlockY, BlockZ, World)
	if World:GetBlock(BlockX, BlockY, BlockZ) == 68 then
		local Read, Line1 = World:GetSignLines(BlockX, BlockY, BlockZ)
		if Line1 == "[P]" or Line1 == "[Private]" then
			return true
		end
	end
	return false
end

function CheckSignOwner(Sign, Player)
    local playerName = Player:GetName();
    if (Sign[2] == "[P]" or Sign[2] == "[Private]") then
        if Sign[3] == playerName then
            return true
        end
        if Player:HasPermission("KiwiLock.Bypass") then
            cRoot:Get():BroadcastChat(cChatColor.Rose .. "Player " .. Player:GetName() .. " bypassed a block owned by somebody else")
            return true
        end
        return false;
    end
end

function CheckSignPermission(Sign, Player)
    local playerName = Player:GetName();
    if (Sign[2] == "[P]" or Sign[2] == "[Private]") then
        if Sign[3] == playerName or Sign[4] == playerName or Sign[5] == playerName then
            return true
        end
        if Player:HasPermission("KiwiLock.Bypass") then
            cRoot:Get():BroadcastChat(cChatColor.Rose .. "Player " .. Player:GetName() .. " bypassed a block owned by somebody else")
            return true
        end
        return false;
    end
end
