function OnPlayerUsingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ, BlockType)
--	open chest
	local World = Player:GetWorld()
	local getAccess = PlayerHasBlockAccess(Player, BlockX, BlockY, BlockZ, World, 'User')
	if getAccess == false then
		Player:SendMessage(cChatColor.Rose .. "You do not have permission to open this")
		return true
	end
end

function OnPlayerBreakingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ, BlockType)
	local World = Player:GetWorld()	
	if not CheckProtectedSign(BlockX, BlockY, BlockZ, World) then
		return false
	end
	local getAccess = PlayerHasBlockAccess(Player, BlockX, BlockY, BlockZ, World, 'Owner')
	if getAccess == false then
		Player:SendMessage(cChatColor.Rose .. "You do not have permission to destroy this");
		return true;
	end
end

function OnUpdatingSign(World, BlockX, BlockY, BlockZ, Line1, Line2, Line3, Line4, Player)
	if Line1 == "[P]" or Line1 == "[Private]" then
		if not Player:HasPermission("KiwiLock.Create") then
			Player:SendMessage(cChatColor.Rose .. "You are not allowed to protect chests")
			World:DigBlock(BlockX, BlockY, BlockZ)
			return false
		end
		if not PlayerHasBlockAccess(Player, BlockX, BlockY, BlockZ, World, 'Owner') then
			Player:SendMessage(cChatColor.Yellow .. "You are not the owner of this chest")
			return false
		end
		if PlayerHasBlockAccess(Player, BlockX, BlockY, BlockZ, World, 'Owner') then
			Player:SendMessage(cChatColor.Green .. "You successfully protected your block")
			if Line2 == "" and Line3 == "" and Line4 == "" then
				return false, Line1, Player:GetName(), Line3, Line4
			end
		end
	end
	if Player:HasPermission("KiwiLock.Create") and World:GetBlock(BlockX, BlockY, BlockZ) == 68 and isAtChest(BlockX, BlockY, BlockZ, World) then
		if PlayerHasBlockAccess(Player, BlockX, BlockY, BlockZ, World, 'Owner') then
			if Line1 == "" and Line2 == "" and Line3 == "" and Line4 == "" then
				return false, "[Private]", Player:GetName(), Line3, Line4
			end
		end
	end
end