SystemLogger            = {}
SystemLogger.name       = "SCARSystemLogger"
SystemLogger.container  = 1
SystemLogger.tabId      = 1
SystemLogger.tabs       = {}
SystemLogger.tabsByName = {}

local damageColors      = { "|c00FF00",
                            "|c999999",
                            "|cFFFFFF",
                            "|cAA0000",
                            "|c9ec3ff",
                            "|c880088",
                            "|c0000FF",
                            "|c714500",
                            "|c530088",
                            "|c356bc6",
                            "|c9aa777",
                            "|c139480",
                          }

function GetValidName( name )
    local index = string.find( name, "%^" )
    if ( not index ) then
        index = 0
    end
    return name:sub( 0, index - 1 )
end

function TitleCase( first, rest )
   return first:upper()..rest:lower()
end

function SystemLogger.PrintLoot( event, receiver, item, quantity, sound, itemType, self )
    local msg = "|cFFFF00"
    if ( SystemLogger.savedVars.timeStamp ) then
        msg = msg .. "[" .. GetTimeString() .. "] "
    end
    if ( self ) then
        msg = msg .. "You received "
    else
        msg = msg .. receiver:sub( 1, string.find( receiver, "%^" ) ) .. " received "
    end
    
    local text = item:match( "|h(.-)|h" )
    local textStart, textEnd = string.find( item, text, 1 )
    if ( text and textStart and textEnd ) then
        text = GetValidName( text )
        text = string.gsub( text, "(%a)([%w_']*)", TitleCase )
        local newItem = string.sub( item, 1, textStart - 1 ) .. text .. string.sub( item, textEnd + 1, -1 )
        
        msg = msg .. "[" .. newItem .. "] x" ..  quantity
        CHAT_SYSTEM.containers[SystemLogger.container].windows[SystemLogger.tabId].buffer:AddMessage( msg )
    end
end

function SystemLogger.SetLoot( state )
    SystemLogger.savedVars.loot = state
    
    if ( state ) then
        EVENT_MANAGER:RegisterForEvent( SystemLogger.name,  EVENT_LOOT_RECEIVED, SystemLogger.PrintLoot  )
    else
        EVENT_MANAGER:UnregisterForEvent( SystemLogger.name,  EVENT_LOOT_RECEIVED )
    end
end

function SystemLogger.PrintDamage( event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, logged )
    local msg = "|cFFCC00"
    local dmg = "|cFF0000"
    local hls = "|c00FF00"
    local stm = "|c0000FF"
    if ( SystemLogger.savedVars.timeStamp ) then
        msg = msg .. "[" .. GetTimeString() .. "] "
    end
    if ( string.len( sourceName ) > 0 and string.len( targetName ) > 0 and string.len( abilityName ) > 0 ) then
        damageType = damageType + 1
        if ( sourceName == targetName ) then
            if ( hitValue > 0 ) then
                msg = msg .. "|cFFFFFF" .. GetValidName( sourceName ) .. " |cFFCC00uses |cFFFFFF" .. GetValidName( abilityName ) .. damageColors[damageType] .. "(" .. hitValue .. ")"
                CHAT_SYSTEM.containers[SystemLogger.container].windows[SystemLogger.tabId].buffer:AddMessage( msg )
            end
        else
            msg = msg .. "|cFFFFFF" .. GetValidName( sourceName ) .. " |cFFCC00hits |cFFFFFF" .. GetValidName( targetName ) .. " |cFFCC00with |cFFFFFF" .. GetValidName( abilityName ) .. damageColors[damageType] .. "(" .. hitValue .. ")"
            CHAT_SYSTEM.containers[SystemLogger.container].windows[SystemLogger.tabId].buffer:AddMessage( msg )
        end
    end  
end

function SystemLogger.SetDamage( state )
    SystemLogger.savedVars.damage = state
    
    if ( state ) then
        EVENT_MANAGER:RegisterForEvent( SystemLogger.name,  EVENT_COMBAT_EVENT, SystemLogger.PrintDamage  )
    else
        EVENT_MANAGER:UnregisterForEvent( SystemLogger.name,  EVENT_COMBAT_EVENT )
    end
end

function SystemLogger.PrintCombat( event, state )
    local msg = "|cFFCC00"
    if ( SystemLogger.savedVars.timeStamp ) then
        msg = msg .. "[" .. GetTimeString() .. "] "
    end
    if ( state ) then
        msg = msg .. "Entering Combat..."
    else
        msg = msg .. "Exiting Combat..."
    end
    CHAT_SYSTEM.containers[SystemLogger.container].windows[SystemLogger.tabId].buffer:AddMessage( msg )
end

function SystemLogger.SetCombat( state )
    SystemLogger.savedVars.combat = state
    
    if ( state ) then
        EVENT_MANAGER:RegisterForEvent( SystemLogger.name,  EVENT_PLAYER_COMBAT_STATE, SystemLogger.PrintCombat  )
    else
        EVENT_MANAGER:UnregisterForEvent( SystemLogger.name,  EVENT_PLAYER_COMBAT_STATE )
    end
end

function SystemLogger.PrintMount( event, state )
    local msg = "|cFFFF00"
    if ( SystemLogger.savedVars.timeStamp ) then
        msg = msg .. "[" .. GetTimeString() .. "] "
    end
    if ( state ) then
        msg = msg .. "Mounting..."
    else
        msg = msg .. "Dismounting..."
    end
    CHAT_SYSTEM.containers[SystemLogger.container].windows[SystemLogger.tabId].buffer:AddMessage( msg )
end

function SystemLogger.SetMount( state )
    SystemLogger.savedVars.mount = state
    
    if ( state ) then
        EVENT_MANAGER:RegisterForEvent( SystemLogger.name, EVENT_MOUNTED_STATE_CHANGED, SystemLogger.PrintMount  )
    else
        EVENT_MANAGER:UnregisterForEvent( SystemLogger.name, EVENT_MOUNTED_STATE_CHANGED )
    end
end

function SystemLogger.SetTab( tabId )
    SystemLogger.tabId = SystemLogger.tabsByName[tabId]
    SystemLogger.savedVars.tabId = SystemLogger.tabId
end

function SystemLogger.GetTab()
    return SystemLogger.savedVars.tabId
end

function SystemLogger.GetTabs()
    for i = 1,GetNumChatContainers() do
        for j = 1,GetNumChatContainerTabs( i ) do
            local name = GetChatContainerTabInfo( i, j )
            SystemLogger.tabs[j] = name
            SystemLogger.tabsByName[name] = j
        end
    end
end

function SystemLogger:Initialize()
    SystemLogger.LoadVariables()
  
    local LAMAddonName = "SCARSystemLoggerLAM"
    local panelData = {
        type = "panel",
        name = "|cFFA200[SCAR] |cFFFFFFSystem Logger|r",
        author = "|cFFA200Scarak|r",
        version = "|cFFFFFF0.0.1a|r",
        slashCommand = "/scarsl",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    local LAM2 = LibStub( "LibAddonMenu-2.0" )
    LAM2:RegisterAddonPanel( LAMAddonName, panelData )
    
    SystemLogger.GetTabs()
    
    local optionsData = {
        {
			type = 'description',
			text = "A simple system logger. This logger displays system information such as combat logs and loot logs.",
		},
        {
        	type = 'header',
        	name = "General Settings",
        },
        {
            type = "dropdown",
            name = "Chat Window",
            tooltip = "The Chat Window the Logger will print information to.",
            choices = SystemLogger.tabs,
            getFunc = function() return SystemLogger.tabs[SystemLogger.tabId] end,
            setFunc = SystemLogger.SetTab,
        },
        {
            type = "checkbox",
            name = "TimeStamp",
            tooltip = "If checked will add a time stamp to all logs.",
            getFunc = function() return SystemLogger.savedVars.timeStamp end,
            setFunc = function( state ) SystemLogger.savedVars.timeStamp = state end,
        },
        {
        	type = 'header',
        	name = "Logging Settings",
        },
        {
            type = "checkbox",
            name = "Mounting",
            tooltip = "Logs when the player mounts and dismounts.",
            getFunc = function() return SystemLogger.savedVars.mount end,
            setFunc = SystemLogger.SetMount,
        },
        {
            type = "checkbox",
            name = "Item Looting",
            tooltip = "Logs when the player picks up any items.",
            getFunc = function() return SystemLogger.savedVars.loot end,
            setFunc = SystemLogger.SetLoot,
        },
        {
            type = "checkbox",
            name = "Enter / Exit Combat",
            tooltip = "Logs when the player enters or Exits Combat",
            getFunc = function() return SystemLogger.savedVars.combat end,
            setFunc = SystemLogger.SetCombat,
        },
        {
            type = "checkbox",
            name = "Combat Logging",
            tooltip = "Logs different combat events.",
            getFunc = function() return SystemLogger.savedVars.damage end,
            setFunc = SystemLogger.SetDamage,
        },
    }
    LAM2:RegisterOptionControls( LAMAddonName, optionsData )
end

function SystemLogger.LoadVariables()
    SystemLogger.savedVars = ZO_SavedVars:New( "SCARSystemLoggerSettings", 1, nil, {} )
    SystemLogger.tabId = SystemLogger.savedVars.tabId
    SystemLogger.SetMount( SystemLogger.savedVars.mount )
    SystemLogger.SetCombat( SystemLogger.savedVars.combat )
    SystemLogger.SetLoot( SystemLogger.savedVars.loot )
    SystemLogger.SetDamage( SystemLogger.savedVars.damage )
end

function SystemLogger.OnAddonLoaded( event, addonName )
    if ( addonName == SystemLogger.name ) then
        SystemLogger:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent( SystemLogger.name, EVENT_ADD_ON_LOADED, SystemLogger.OnAddonLoaded )