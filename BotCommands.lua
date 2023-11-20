NpcBotCommands = {}

local requireGMForItemCommands = true -- Require gm rank. This is only for items. Set to false to disable.

local args = {}
local bot_script_names = {
    "mage_bot", "shaman_bot", "priest_bot", "warrior_bot", "hunter_bot", "rogue_bot",
    "warlock_bot", "paladin_bot", "druid_bot", "dreadlord_bot",
    "sphynx_bot", "blademaster_bot", "spellbreaker_bot", "seawitch_bot", "necromancer_bot",
    "dreadlord_bot", "death_knight_bot"
}

local function IsValidBotScriptName(scriptName)
    for _, validScriptName in ipairs(bot_script_names) do
        if scriptName == validScriptName then
            return true
        end
    end
    return false
end

local function GetCommandArgs(command)
    local args = {}
    for word in command:gmatch("%w+") do table.insert(args, word) end
    
    if args[1] == "bot" then
        return args
    end

    return false
end

local function GetTargetScriptName(target)
    local script_name = nil

    -- Check if target exists and if GetScriptName is a callable method on target
    if target and type(target.GetScriptName) == "function" then
        script_name = target:GetScriptName()
    end

    return script_name
end

local function GenerateItems(player)
    local usage_string = "\nUsage:\n .bot items [class] [spec] [rarity]"

    -- assign command arguments
    local class     = args[3] or ""
    local spec      = args[4] or ""
    local rarity    = args[5] or ""
    local rarity_query_string = ""

    -- Check player's GM rank
    local gm_rank = player:GetGMRank()

    if requireGMForItemCommands == true and gm_rank == 0 then
        player:SendBroadcastMessage("You do not have permission to use this command.")
        return false
    end

    if class == "" or spec == "" then
        player:SendBroadcastMessage("You must specify a class and spec."..usage_string)
        return false
    end

    local player_level = player:GetLevel()
    local level = math.floor(player_level / 5) * 5
    if level < 10 then level = 10 end

    if player_level == 80 then
        if rarity ~= "epic" and rarity ~= "rare" then
            player:SendBroadcastMessage("At level 80, you must specify either 'epic' or 'rare' quality."..usage_string)
            return false
        end

        rarity_query_string = string.format("AND rarity = '%s'", rarity)
    end

    local item_list = nil

    local query = string.format("SELECT head, neck, shoulders, back, chest, wrists, hands, waist, legs, feet, ring1, ring2, trinket1, trinket2, weapon1, weapon2, weapon3 FROM creature_template_npcbot_itemsets WHERE level = %d AND class = '%s' AND spec = '%s' %s LIMIT 1", level, class, spec, rarity_query_string)
    local result = WorldDBQuery(query)

    if result then
        item_list = {}
        local row = result:GetRow()
        
        for k, v in pairs(row) do
            table.insert(item_list, v)
        end
    end

    if not item_list or not result then
        player:SendBroadcastMessage(string.format("No items found for \"%s %s %s\"."..usage_string, class, spec, rarity))
        return false
    end

    for _, item_id in ipairs(item_list) do
        player:AddItem(item_id, 1)
    end

    --player:SendBroadcastMessage(#item_list .. " items added.")
    player:SendBroadcastMessage(string.format("%d items added for \"%s %s %s\".", #item_list, class, spec, rarity))
    return false
end

local function ClearTransmog(player)
    local target = player:GetSelection()
    local scriptName = nil  -- Initialize to nil

    -- Check if target exists and if GetScriptName is a callable method on target
    if target and type(target.GetScriptName) == "function" then
        scriptName = target:GetScriptName()
    end

    -- Handle .bot cleartmog command
    if scriptName == nil or not IsValidBotScriptName(scriptName) then
        player:SendBroadcastMessage("Invalid target for .bot cleartmog command. Make sure you have an NPC Bot targeted.")
        return false
    end

    local creatureId = target:GetEntry()
    local sqlQuery = string.format("DELETE FROM characters_npcbot_transmog WHERE entry = %d", creatureId)
    
    CharDBExecute(sqlQuery)
    
    player:SendBroadcastMessage("Transmog for NPC Bot has been cleared. Changes will take effect upon server reset.")
    return false
end

local function SetName(player)
    -- assign command arguments
    local new_name = args[3] or ""
    
    local target = player:GetSelection()
    local script_name = GetTargetScriptName(target)
    
    -- check that it is actually a bot that is targeted
    if script_name == nil or not IsValidBotScriptName(script_name) then
        player:SendBroadcastMessage("Invalid target for .bot nameset command. Make sure you have an NPC Bot targeted.")
        return false
    end

    -- check that a new name has been specified
    if new_name == "" then
        player:SendBroadcastMessage("You must specify a new name of no longer than 15 characters:\n .bot nameset [newname]")
        return false
    end

    -- check that the new name is not too long
    if #new_name > 15 then
        player:SendBroadcastMessage("New name is too long. It must be no longer than 15 characters.")
        return false
    end
    
    -- at this point, should be good to change the name
    local creature_id = target:GetEntry()

    local sql_query1 = string.format("UPDATE creature_template SET name = '%s' WHERE entry = %d", new_name, creature_id)
    local sql_query2 = string.format("UPDATE creature_template_npcbot_appearance SET `name*` = '%s' WHERE entry = %d", new_name, creature_id)
    
    WorldDBExecute(sql_query1)
    WorldDBExecute(sql_query2)
    
    player:SendBroadcastMessage("Name for NPC Bot has been updated to " .. new_name .. ". Changes will take effect upon server reset.")
    
    return false
end

local function OnBotCommandHandler(event, player, command)
    -- gather command arguments, returns false and bails out if the first word isn't "bot"
    args = GetCommandArgs(command)
    if args == false then return false end

    -- assign the subcommand
    local subcmd = args[2] or ""    
    
    if subcmd == "items" then
        GenerateItems(player)
    elseif subcmd == "cleartmog" then
        ClearTransmog(player)
    elseif subcmd == "nameset" then
        SetName(player)
    else
        player:SendBroadcastMessage("Usage:\n .bot items [class] [spec] [rarity]\n .bot cleartmog\n .bot nameset [newname]")
    end

    return false
end

RegisterPlayerEvent(42, OnBotCommandHandler)