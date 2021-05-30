local _, ns = ...
local ycc = ns.ycc

local WHITE = {r = 1, g = 1, b = 1}
local FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub('%%d', '%%s')
FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub('%$d', '%$s') -- '%2$s %1$d-го Level'

-- luacheck: globals FriendsListFrameScrollFrame FRIENDS_BUTTON_TYPE_WOW FRIENDS_BUTTON_TYPE_BNET BNET_CLIENT_WOW FRIENDS_WOW_NAME_COLOR_CODE C_BattleNet

local function updateFriends_Retail()
    local scrollFrame = FriendsListFrameScrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons

    local playerArea = GetRealZoneText()

    for i = 1, #buttons do
        local nameText, infoText
        local button = buttons[i]
        local index = i
        if(button:IsShown()) then
            if(button.buttonType == FRIENDS_BUTTON_TYPE_WOW) then
                local name, level, class, areaName, connected, status, note = GetFriendInfo(button.id)
                if(connected) then
                    nameText = ycc.classColor[class] .. name.."|r, "..format(FRIENDS_LEVEL_TEMPLATE, ycc.diffColor[level] .. level .. '|r', class)
                    if(areaName == playerArea) then
                        infoText = format('|cff00ff00%s|r', areaName)
                    end
                end
            elseif(button.buttonType == FRIENDS_BUTTON_TYPE_BNET) then
                local IsFriend, isDND, IsFavorite, _, accountName, battleTag, note, rafLinkType, bnetAccountID, appearOffline, customMessage, lastOnlineTime, customMessageTime, isAFK, isBattleTagFriend = C_BattleNet.GetFriendAccountInfo(button.id)
                for gameIndex = 1, C_BattleNet.GetFriendNumGameAccounts(button.id) do
                    local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(button.id, gameIndex)
                    local isOnline = gameAccountInfo.isOnline
                    local client = gameAccountInfo.clientProgram
                    if(client == BNET_CLIENT_WOW) then
                        local accountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
                        local presenceName = accountInfo.accountName
                        local toonName = gameAccountInfo.characterName
                        local class = gameAccountInfo.className
                        local zoneName = gameAccountInfo.zoneName
                        if(presenceName and toonName and class) then
                            nameText = presenceName .. ' ' .. FRIENDS_WOW_NAME_COLOR_CODE..'('..
                                ycc.classColor[class] .. toonName .. FRIENDS_WOW_NAME_COLOR_CODE .. ')'
                            if(zoneName == playerArea) then
                                infoText = format('|cff00ff00%s|r', zoneName)
                            end
                        else
                            --print(zoneName)
                        end

                    end
                end
            end
        end

        if(nameText) then
            button.name:SetText(nameText)
        end
        if(infoText) then
            button.info:SetText(infoText)
        end
    end
end

local function updateFriends_Classic()
    local scrollFrame = FriendsFrameFriendsScrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons

    local playerArea = GetRealZoneText()

    for i = 1, #buttons do
        local nameText, infoText
        local button = buttons[i]
        local index = offset + i
        if(button:IsShown()) then
            if(button.buttonType == FRIENDS_BUTTON_TYPE_WOW) then
                local name, level, class, areaName, connected, status, note = GetFriendInfo(button.id)
                if(connected) then
                    nameText = ycc.classColor[class] .. name.."|r, "..format(FRIENDS_LEVEL_TEMPLATE, ycc.diffColor[level] .. level .. '|r', class)
                    if(areaName == playerArea) then
                        infoText = format('|cff00ff00%s|r', areaName)
                    end
                end
            elseif(button.buttonType == FRIENDS_BUTTON_TYPE_BNET) then
                local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, messageTime, canSoR = BNGetFriendInfo(button.id)
                if(isOnline and client == BNET_CLIENT_WOW) then
                    local hasFocus, toonName, client, realmName, realmID, faction, race, class, guild, zoneName, level, gameText, broadcastText, broadcastTime = BNGetGameAccountInfo(toonID)
                    if(presenceName and toonName and class) then
                        nameText = presenceName .. ' ' .. FRIENDS_WOW_NAME_COLOR_CODE..'('..
                            ycc.classColor[class] .. toonName .. FRIENDS_WOW_NAME_COLOR_CODE .. ')'
                        if(zoneName == playerArea) then
                            infoText = format('|cff00ff00%s|r', zoneName)
                        end
                    end
                end
            end
        end

        if(nameText) then
            button.name:SetText(nameText)
        end
        if(infoText) then
            button.info:SetText(infoText)
        end
    end
end

if not ycc.IsRetail() then
    hooksecurefunc(FriendsFrameFriendsScrollFrame, 'update', updateFriends_Classic)
    hooksecurefunc('FriendsFrame_UpdateFriends', updateFriends_Classic)
else
    hooksecurefunc(FriendsListFrameScrollFrame, 'update', updateFriends_Retail)
    hooksecurefunc('FriendsFrame_UpdateFriends', updateFriends_Retail)
end
