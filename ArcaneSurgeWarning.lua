local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_TEXT_UPDATE")
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")

local warningFrame = CreateFrame("Button", "WarningIconFrame", UIParent)
warningFrame:SetWidth(50)
warningFrame:SetHeight(50)
warningFrame:SetPoint("CENTER", UIParent, "CENTER")

-- -- Add a backdrop for easier interaction
-- warningFrame:SetBackdrop({
--     bgFile = "Interface/Tooltips/UI-Tooltip-Background",
--     edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
--     tile = true,
--     tileSize = 16,
--     edgeSize = 16,
--     insets = { left = 4, right = 4, top = 4, bottom = 4 }
-- })
-- warningFrame:SetBackdropColor(0, 0, 0, 0.5)

warningFrame:SetFrameStrata("HIGH")
warningFrame:SetMovable(true)
warningFrame:EnableMouse(true)
warningFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

-- Dragging functionality for WoW 1.12.1
warningFrame:SetScript("OnMouseDown", function()
    if IsShiftKeyDown() then
        warningFrame:StartMoving()
    end
end)

warningFrame:SetScript("OnMouseUp", function()
    warningFrame:StopMovingOrSizing()
end)

local warningIcon = warningFrame:CreateTexture(nil, "OVERLAY")
warningIcon:SetAllPoints(warningFrame)
warningIcon:SetTexture("Interface\\Icons\\INV_Enchant_EssenceMysticalLarge") -- Default icon

-- Cooldown Progress Bar
local cooldownBar = CreateFrame("StatusBar", nil, warningFrame)
cooldownBar:SetWidth(50)
cooldownBar:SetHeight(5)
cooldownBar:SetPoint("BOTTOM", warningFrame, "TOP", 0, 2)
cooldownBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
cooldownBar:SetStatusBarColor(0, 0.6, 1)
cooldownBar:SetMinMaxValues(0, 1)
cooldownBar:SetValue(0)

-- Cooldown Timer Text
local cooldownText = warningFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
cooldownText:SetPoint("CENTER", warningFrame, "CENTER")
cooldownText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
cooldownText:SetTextColor(1, 1, 1, 1)

-- Surge Duration Progress Bar
local surgeBar = CreateFrame("StatusBar", nil, warningFrame)
surgeBar:SetWidth(50)
surgeBar:SetHeight(5)
surgeBar:SetPoint("TOP", warningFrame, "BOTTOM", 0, -2)
surgeBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
surgeBar:SetStatusBarColor(1, 0.4, 0.4)
surgeBar:SetMinMaxValues(0, 4)
surgeBar:SetValue(0)

local activeSurge = false
local surgeTimer = 0
local cooldownActive = false
local lastKnownState = false  -- Track the last known state of Arcane Surge
-- Find the action slot with the specific texture
local function FindActionSlotByTexture(texture)
    for slot = 1, 120 do -- Check action bar slots 1 to 120
        local actionTexture = GetActionTexture(slot)
        if actionTexture == texture then
            return slot
        end
    end
    return nil
end

local actionSlot = FindActionSlotByTexture("Interface\\Icons\\INV_Enchant_EssenceMysticalLarge")
--local actionSlot = 12 -- Change this to the slot number where Arcane Surge is located on your action bar

local function IsActionUsable()
    local isUsable, notEnoughMana = IsUsableAction(actionSlot)
    return isUsable and not notEnoughMana
end

local function GetCooldown()
    local start, duration, enable = GetActionCooldown(actionSlot)
    if enable == 1 then
        return start, duration
    end
    return 0, 0
end

local function ActivateIcon()
    --warningIcon:SetDesaturated(false)
    activeSurge = true
    surgeTimer = 4 -- Always reset timer to 4 seconds
    --warningFrame:Show() -- Show icon only when active
    --print("[ActivateIcon] surgeTimer:", surgeTimer)
end

local function DeactivateIcon()
    --warningIcon:SetDesaturated(true)
    activeSurge = false
    surgeBar:SetValue(0)
    --warningFrame:Hide() -- Hide icon when inactive
    --print("[DeactivateIcon] Icon deactivated")
end

-- OnUpdate handler to manage timing and update countdown
warningFrame:SetScript("OnUpdate", function()
    if activeSurge then
        surgeTimer = surgeTimer - arg1
        if surgeTimer <= 0 then
            DeactivateIcon()
        else
            surgeBar:SetValue(surgeTimer)
        end
    end

    -- Cooldown tracking
    local start, duration = GetCooldown()
    if duration > 0 then
        local remaining = (start + duration) - GetTime()
        cooldownBar:SetMinMaxValues(0, duration)
        cooldownBar:SetValue(remaining)
        cooldownText:SetText(string.format("%.1f", remaining)) -- Display cooldown
    else
        cooldownBar:SetValue(0)
        cooldownText:SetText("") -- Clear cooldown when ready
    end
    local remaining = (start + duration) - GetTime()
    -- Check action usability status
    if IsActionUsable() and remaining < surgeTimer then
        warningIcon:SetDesaturated(false)
        warningIcon:Show()
        surgeBar:Show()
        cooldownBar:Show()
        cooldownText:Show()
    else
        warningIcon:SetDesaturated(true)
        if not activeSurge then
            warningIcon:Hide() 
            surgeBar:Hide() 
            cooldownText:Hide()
            cooldownBar:Hide() -- Ensure icon stays hidden when not active and not procced
        end
    end
end)

-- Function to lock/unlock the icon position
SLASH_LOCKICON1 = "/lockicon"
SlashCmdList["LOCKICON"] = function(msg)
    if warningFrame:IsMovable() then
        warningFrame:EnableMouse(false)
        warningFrame:SetMovable(false)
        DEFAULT_CHAT_FRAME:AddMessage("Icon locked.")
    else
        warningFrame:EnableMouse(true)
        warningFrame:SetMovable(true)
        DEFAULT_CHAT_FRAME:AddMessage("Icon unlocked. Hold Shift + Drag to move.")
    end
end

frame:SetScript("OnEvent", function()
    if event == "COMBAT_TEXT_UPDATE" and arg1 == "SPELL_ACTIVE" and arg2 == "Arcane Surge" then
        --print("[Event] Arcane Surge activated")
        ActivateIcon()
    end

    if event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
        if string.find(arg1, "resist") or string.find(arg1, "Resist") then
            --print("[Event] Spell resisted on target")
            ActivateIcon()
        end
    end

    if event == "CHAT_MSG_SPELL_SELF_DAMAGE" and string.find(arg1, "Your Arcane Surge") then
        --print("[Event] Arcane Surge hit")
        DeactivateIcon()
    end
end)
