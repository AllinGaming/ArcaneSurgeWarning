local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_TEXT_UPDATE")
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")

local warningFrame = CreateFrame("Button", "WarningIconFrame", UIParent)
warningFrame:SetWidth(50)
warningFrame:SetHeight(50)
warningFrame:SetPoint("CENTER", UIParent, "CENTER")

-- Add a backdrop for easier interaction
warningFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
warningFrame:SetBackdropColor(0, 0, 0, 0.5)

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
warningIcon:SetTexture("Interface\\Icons\\INV_Enchant_EssenceMysticalLarge") -- Default icon, can be changed

-- Always show the icon, initially greyed out
warningFrame:Show()
warningIcon:SetDesaturated(true)

-- Create a FontString to display the countdown
local countdownText = warningFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
countdownText:SetPoint("CENTER", warningFrame, "CENTER")
countdownText:SetText("")  -- Initially empty
-- Set the font size and color
countdownText:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")  -- Font, size 20, outline
countdownText:SetTextColor(1, 0, 0, 1)  -- Red color (r, g, b, a)
local activeSurge = false
local surgeTimer = 0

local function ActivateIcon()
    warningIcon:SetDesaturated(false)
    activeSurge = true
    surgeTimer = 4 -- Reset timer to 4 seconds
end

local function DeactivateIcon()
    warningIcon:SetDesaturated(true)
    activeSurge = false
    countdownText:SetText("")  -- Clear the countdown when the icon is deactivated
end

-- OnUpdate handler to manage timing and update countdown
warningFrame:SetScript("OnUpdate", function()
    if activeSurge then
        surgeTimer = surgeTimer - arg1
        if surgeTimer <= 0 then
            DeactivateIcon()
        else
            -- Update the countdown text
            countdownText:SetText(string.format("%.1f", surgeTimer))
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
    if event == "COMBAT_TEXT_UPDATE" then
        if arg1 == "SPELL_ACTIVE" and arg2 == "Arcane Surge" then
            ActivateIcon()
        end
    end
    if event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
        if string.find(arg1, "Your Arcane Surge") then
            DeactivateIcon()
        end
    end
end)
