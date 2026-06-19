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
function events.PLAYER_SPECIALIZATION_CHANGED(_)
    fs:SpecScan()
end

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...); -- call one of the functions above
end);

for k in pairs(events) do
    frame:RegisterEvent(k); -- Register all events for which handlers have been defined
end


function fs:Initialize(name)
    if name == "FazzToolsScraper" then
        if FazzToolsScraperDB == nil then
            FazzToolsScraperDB = templateSavedVar
        end

        local altKey = UnitName("player") .. "-" .. GetRealmName()

        alt = FazzToolsScraperDB.alts[altKey] or {}
        FazzToolsScraperDB.alts[altKey] = alt

        alt.ridingSkill = 0
        alt.kb = alt.kb or {}
        alt.kbConfig = alt.kbConfig or {}
        alt.kbConfig.map = alt.kbConfig.map or {}
        alt.spell = alt.spell or {}
        alt.macro = alt.macro or {}
        alt.item = alt.item or {}

        local dominos = select(4, GetAddOnInfo("Dominos"))
        local bartender = select(4, GetAddOnInfo("Bartender4"))
        local elvui = select(4, GetAddOnInfo("|cff1784d1ElvUI|r"))
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
    local _, name = GetSpecializationInfo(GetSpecialization())
    alt.kb[name] = {}
    local numKeyBindings = GetNumBindings()
    for j = 1, numKeyBindings do
        local command = GetBinding(j)
        local hasAction = string.find(command, "ACTION") or string.find(command, "Action")
        local hasButton = string.find(command, "BUTTON") or string.find(command, "Button")
        if hasAction and hasButton then
            local keybind = GetBindingKey(command)
            if keybind then
                alt.kbConfig.map[command] = keybind
            end
        end
    end
    for i = 1, 120 do
        local actionType, actionId, _ = GetActionInfo(i)
        local nilCheck = GetActionTexture(i)
        if nilCheck then
            alt.kb[name][tostring(i)] = actionType .. ":" .. tostring(actionId)
            if actionType == 'macro' then
                local macroname,macroicon,macrobody = GetMacroInfo(actionId)
                if macroname then
                    alt.macro[tostring(actionId)] = {macroname, macroicon, macrobody}
                end
            elseif actionType == 'item' then
                local itemname,_,_,_,_,itemtype,_,_,_,itemicon = GetItemInfo(actionId)
                if itemname then
                    alt.item[tostring(actionId)] = {itemname, itemicon, itemtype}
                end
            end
        end
    end
    local _, specname = GetSpecializationInfo(GetSpecialization())
    alt.spell[specname] = {}
    alt.spell[specname]["base"] = {}
    alt.spell[specname]["talent"] = {}
    for i = 1, 3 do
        local _,_,offset,numSpells = GetSpellTabInfo(i)
        for j = offset + 1, offset + numSpells do
            if not IsPassiveSpell(j, BOOKTYPE_SPELL) then
                local spell,subspell,spellid = GetSpellBookItemName(j, BOOKTYPE_SPELL)
                if spellid then
                    local spelldesc = GetSpellDescription(spellid)
                    local spellicon = GetSpellTexture(spellid)
                    alt.spell[specname]["base"][spellid] = {spell, subspell, spelldesc, spellicon}
                end
            end
        end
    end
    for i = 1, 7 do
        for j = 1, 3 do
            local _,spell,spellicon,_,_,spellid = GetTalentInfo(i, j, 1)
            if spellid then
                if not IsPassiveSpell(spellid) then
                    local spelldesc = GetSpellDescription(spellid)
                    alt.spell[specname]["talent"][spellid] = {spell, "", spelldesc, spellicon}
                end
            end
        end
    end
end
