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

SLASH_FAZZTOOLSSCRAPER1 = "/fts"
SlashCmdList.FAZZTOOLSSCRAPER = function()
    fs:UpdateAlt()
    print("FazzToolsScraper: alt data refreshed.")
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

    alt.gold = GetMoney()
    fs:UpdateCurrencies()
    fs:UpdateLockouts()
end

function fs.UpdateCurrencies(_)
    local currencies = {}
    for i = 1, C_CurrencyInfo.GetCurrencyListSize() do
        local info = C_CurrencyInfo.GetCurrencyListInfo(i)
        if info and not info.isHeader then
            local link = C_CurrencyInfo.GetCurrencyListLink(i)
            local currencyID = link and tonumber(link:match("currency:(%d+)"))
            if currencyID then
                currencies[currencyID] = {
                    name = info.name,
                    quantity = info.quantity,
                    maxQuantity = info.maxQuantity,
                }
            end
        end
    end
    alt.currencies = currencies
end

function fs.UpdateLockouts(_)
    local lockouts = {}
    for i = 1, GetNumSavedInstances() do
        local name, id, reset, _, locked, extended, _, isRaid, _, difficultyName, numEncounters, encounterProgress =
            GetSavedInstanceInfo(i)
        if locked or extended then
            lockouts[#lockouts + 1] = {
                id = id,
                name = name,
                difficultyName = difficultyName,
                reset = reset,
                extended = extended,
                isRaid = isRaid,
                numEncounters = numEncounters,
                encounterProgress = encounterProgress,
            }
        end
    end
    alt.lockouts = lockouts
end
