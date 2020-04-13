--
-- GUI Variables
--

local onion_window = gui.Tab(gui.Reference("Settings"), 'onion_window_hud', "Onion's HUD")
local onion_groupbox_1 = gui.Groupbox(onion_window, 'Settings', 15, 15)
local onion_huds_enabled = gui.Checkbox(onion_groupbox_1, 'onion_huds_enabled', 'HUDs', true)
local onion_groupbox_2 = gui.Groupbox(onion_groupbox_1, 'Enabled HUDs', 0, 35)
local onion_huds_damagelog = gui.Checkbox(onion_groupbox_2, 'onion_huds_damagelog', 'Damage Logs', true)
local onion_huds_damagelog_max = gui.Slider(onion_groupbox_2, 'onion_huds_damagelog_max', 'HUD Log Max', 5, 1, 20)

--
-- Some rando vars
--

local barFont = draw.CreateFont( "Tahoma", 14 )
local textFont = draw.CreateFont( "Tahoma", 12 )

local scrW, scrH = 0, 0
local localPlayer, playerResources
local initialize = false
local hitboxIDTable = { "0", "1", "2", "3", "4", "5", "6", "7", "10" }
local hitboxNameTable = { "Body", "Head", "Chest", "Stummy", "Arms", "Arms", "Legs", "Legs", "Body" }
local recentHits = { }

local mouseState
local mouseX, mouseY = 0, 0
local mouseDownPosX, mouseDownPosY = 0, 0

local damageLogX, damageLogY = 0, 0
local damageLogW, damageLogH = 10, 15

--
-- dumb drawing functions for lazy people
--

function drawFilledRect(r, g, b, a, x, y, width, height)
	draw.Color(r, g, b, a)
	draw.FilledRect(x, y, x + width, y + height)
end

function drawText(r, g, b, a, x, y, font, str)
	draw.Color(r, g, b, a)
	draw.SetFont(font)
	draw.Text(x, y, str)
end

function drawCenteredText(r, g, b, a, x, y, font, str)
	draw.Color(r, g, b, a)
	draw.SetFont(font)
	local textW, textH = draw.GetTextSize(str)
	draw.Text(x - (textW / 2), y - (textH / 2), str)
end

--
-- Reeree functions
--

function whereTFDidIHit(hitBox)
    for i = 1, #hitboxIDTable do
        if (hitboxIDTable[i] == tostring(hitBox)) then
            return hitboxNameTable[i]
        end
    end
    -- Remember hitting stummy is for pros
end

function addToTable(id, name, damage, hitBox, tableMax)
    table.insert(recentHits, { tostring(id), tostring(name), tostring(damage), tostring(hitBox) })

    if (tableMax > #recentHits) then
        local removals = tableMax - #recentHits

        for i = 1, removals do
            table.remove(recentHits, 0)
        end
    end
    -- pretty code is a no go anymore so smd :clown:
end

--
-- Some callback functions
--

function gatherVariables()
	if (initialize == false) then
		initialize = true
        scrW, scrH = draw.GetScreenSize()
    end
    
    mouseX, mouseY = input.GetMousePos()
	localPlayer = entities.GetLocalPlayer()
    playerResources = entities.GetPlayerResources()

    if (localPlayer == nil) then
        recentHits = {}
    end

    if (input.IsButtonDown("Mouse1")) then
        mouseState = "down"
        if (mouseDownPosX == 0 and mouseDownPosY == 0) then
            mouseDownPosX, mouseDownPosY = mousePosX, mousePosY
        end
    elseif (input.IsButtonReleased("Mouse1")) then
        mouseState = "released"
        mouseDownPosX, mouseDownPosY = 0, 0
        mouseDown = false
    else
        mouseState = "none"
        mouseDownPosX, mouseDownPosY = 0, 0
        mouseDown = false
    end
end

function drawHUDs()
    if (onion_huds_enabled:GetValue()) then
        if (onion_huds_damagelog:GetValue()) then
            
        end


    end
end

callbacks.Register( 'FireGameEvent', function(penis)
    local entity = penis:GetName()

    if (entity ~= 'player_hurt' or localPlayer == nil) then
        return
    end

    local entityID = entities.GetByUserID(penis:GetInt('userid'))

    if (entityID == nil) then
        return
    end

    local attacker = entities.GetByUserID(penis:GetInt('attacker'))
    local damage = penis:GetInt('dmg_health')

    if (attacker == nil or localPlayer:GetIndex() ~= attacker:GetIndex()) then
        return
    end

    addToTable(entityID:GetIndex(), entityID:GetName(), damage, whereTFDidIHit(penis:GetInt('hitgroup')), onion_huds_damagelog_max:GetValue())

    for i = 1, #recentHits do
        for i2 = 1, #recentHits[i] do
            print(recentHits[i][i2])
        end
    end
end);

-- the callbacks :clown:
callbacks.Register('Draw', gatherVariables);
callbacks.Register('Draw', drawHUDs);
