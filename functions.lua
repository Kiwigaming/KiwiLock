function LoadSettings(Path)
    SettingsIni = cIniFile()
    SettingsIni:ReadFile(Path)
    ShowAdminBreach = SettingsIni:GetValueSetB("General", "ShowAdminBreach", false)

    if ShowAdminBreach == nil then
        return true
    end
end

function getAllSideCoords(BlockX, BlockY, BlockZ)
    local sides = {}
    sides['+x'] = { x = BlockX + 1, y = BlockY, z = BlockZ, f = 4, s = '+x' }
    sides['-x'] = { x = BlockX - 1, y = BlockY, z = BlockZ, f = 5, s = '-x' }
    sides['+z'] = { x = BlockX, y = BlockY, z = BlockZ + 1, f = 2, s = '+z' }
    sides['-z'] = { x = BlockX, y = BlockY, z = BlockZ - 1, f = 3, s = '-z' }
    return sides;
end

function getSignMeta()
    return { 2, 3, 4, 5 }
end

function SetSide(BlockX, BlockY, BlockZ, Side, World)
    local sides getAllSideCoordss(BlockX, BlockY, BlockZ)

    if Side == "+X" then
        World:SetBlock(BlockX, BlockY, BlockZ, 68, 4)
    end
    if Side == "-X" then
        World:SetBlock(BlockX, BlockY, BlockZ, 68, 5)
    end
    if Side == "+Z" then
        World:SetBlock(BlockX, BlockY, BlockZ, 68, 2)
    end
    if Side == "-Z" then
        World:SetBlock(BlockX, BlockY, BlockZ, 68, 3)
    end
end

function CheckBlock(SideBlock)
    if SideBlock == 54 then
        return true
    end
end

function CheckProtect(BlockX, BlockY, BlockZ, World)
    local sides = getAllSideCoords(BlockX, BlockY, BlockZ)
    for value in pairs(sides) do
        if World:GetBlock(value['x'], value['y'], value['z']) == 68 then
            if World:GetBlockMeta(value['x'], value['y'], value['z']) == 4 then
                local Read, Line1 = World:GetSignLines(value['x'], value['y'], value['z'])
                if Line1 == "[P]" or Line1 == "[Private]" then
                    return true
                end
            end
        end
    end
end

function CheckSignPermission(Sign, Player)
    local playerName = Player:GetName();
    if (Sign[2] == "[P]" or Sign[2] == "[Private]") then
        if Sign[3] == playerName or Sign[4] == playerName or Sign[5] == playerName then
            return true
        end
        if Player:HasPermission("SignLock.Bypass") then
            cRoot:Get():BroadcastChat(cChatColor.Rose .. "Player " .. Player:GetName() .. " bypassed a block owned by somebody else")
            return true
        end
        return false;
    end
end

function PlayerHasBlockAccess(Player, BlockX, BlockY, BlockZ)
    local World = Player:GetWorld()
    local sides = getAllSideCoords(BlockX, BlockY, BlockZ)
    for key, value in pairs(sides) do
        local blockMeta = World:GetBlockMeta(value['x'], value['y'], value['z'])
        if World:GetBlock(value['x'], value['y'], value['z']) == 68
                and (value['s'] == '+x' and blockMeta == 5
                or value['s'] == '-x' and blockMeta == 4
                or value['s'] == '+z' and blockMeta == 3
                or value['s'] == '-z' and blockMeta == 2) then

            local sign = { World:GetSignLines(value['x'], value['y'], value['z']) }
            return CheckSignPermission(sign, Player)
        end
    end
    return nil
end