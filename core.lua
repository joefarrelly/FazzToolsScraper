local fs = {}
local alt
local frame = CreateFrame("FRAME")

local templateSavedVar = {
    alts = {},
}

local frame, events = CreateFrame("Frame"), {}

function events:ADDON_LOADED(name)
    fs:Initialize(name)
end
-- function events:MERCHANT_SHOW()
--     fs:Test()
-- end
function events:PLAYER_LOGOUT()
    fs:UpdateAlt()
end
function events:PLAYER_SPECIALIZATION_CHANGED()
    fs:SpecScan()
end

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...); -- call one of the functions above
end);

for k, v in pairs(events) do
    frame:RegisterEvent(k); -- Register all events for which handlers have been defined
end


function fs:Initialize(name)
    if name == "FazzToolsScraper" then
        if FazzToolsScraperDB == nil then
            FazzToolsScraperDB = templateSavedVar
        end

        altKey = UnitName("player") .. "-" .. GetRealmName()

        alt = FazzToolsScraperDB.alts[altKey] or {}
        FazzToolsScraperDB.alts[altKey] = alt

        alt.ridingSkill = 0
        alt.kb = alt.kb or {}
        alt.kbConfig = alt.kbConfig or {}
        alt.kbConfig.map = alt.kbConfig.map or {}

        _,_,_,dominos = GetAddOnInfo("Dominos")
        _,_,_,bartender = GetAddOnInfo("Bartender4")
        _,_,_,elvui = GetAddOnInfo("|cff1784d1ElvUI|r")
        if dominos then
            alt.kbConfig.addon = "Dominos"
        elseif bartender then
            alt.kbConfig.addon = "Bartender"
        elseif elvui then
            alt.kbConfig.addon = "Elvui"
        else
            alt.kbConfig.addon = "Default"
        end
    end
end


-- function fs:Test()
--     print("works")
--     for i = 1, 120 do
--         local actionType, id, _ = GetActionInfo(i)
--         local nilCheck = GetActionTexture(i)
--         if nilCheck then
--             print(i .. ": " .. actionType .. "-" .. id .. "-")
--         end
--     end

--     local numKeyBindings = GetNumBindings()
--     for j = 1, numKeyBindings do
--         local command = GetBinding(j)
--         if (string.find(command, "ACTION") or string.find(command, "Action")) and (string.find(command, "BUTTON") or string.find(command, "Button")) then
--             local keybind = GetBindingKey(command)
--             if keybind then
--                 print(j .. ": " .. command .. "-" .. keybind)
--             end
--         end
--     end
-- end

function fs:UpdateAlt()
    if IsSpellKnown(33388) then
        alt.ridingSkill = 1
    elseif IsSpellKnown(33391) then
        alt.ridingSkill = 2
    elseif IsSpellKnown(34090) then
        alt.ridingSkill = 3
    elseif IsSpellKnown(34091) then
        alt.ridingSkill = 4
    elseif IsSpellKnown(90265) then
        alt.ridingSkill = 5
    end
end

function fs:SpecScan()
    id, name = GetSpecializationInfo(GetSpecialization())
    alt.kb[name] = {}
    local numKeyBindings = GetNumBindings()
    for j = 1, numKeyBindings do
        local command = GetBinding(j)
        if (string.find(command, "ACTION") or string.find(command, "Action")) and (string.find(command, "BUTTON") or string.find(command, "Button")) then
            local keybind = GetBindingKey(command)
            if keybind then
                alt.kbConfig.map[command] = keybind
            end
        end
    end
    for i = 1, 120 do
        local actionType, id, _ = GetActionInfo(i)
        local nilCheck = GetActionTexture(i)
        if nilCheck then
            alt.kb[name][tostring(i)] = id
        end
    end
end