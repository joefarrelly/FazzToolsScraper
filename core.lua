local fs = {}
local alt
local frame, events = CreateFrame("Frame"), {}

local templateSavedVar = {
    alts = {},
}

function events.ADDON_LOADED(_, name)
    fs:Initialize(name)
end
function events.PLAYER_LOGOUT(_)
    fs:UpdateAlt()
end

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...); -- call one of the functions above
end);

for k in pairs(events) do
    frame:RegisterEvent(k); -- Register all events for which handlers have been defined
end


function fs.Initialize(_, name)
    if name == "FazzToolsScraper" then
        if FazzToolsScraperDB == nil then
            FazzToolsScraperDB = templateSavedVar
        end

        local altKey = UnitName("player") .. "-" .. GetRealmName()

        alt = FazzToolsScraperDB.alts[altKey] or {}
        FazzToolsScraperDB.alts[altKey] = alt

        alt.ridingSkill = 0
    end
end


function fs.UpdateAlt(_)
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
