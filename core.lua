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
        alt.spell = alt.spell or {}
        alt.macro = alt.macro or {}
        alt.item = alt.item or {}

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
            alt.kb[name][tostring(i)] = actionType .. ":" .. tostring(id)
            if actionType == 'macro' then
                local macroname,macroicon,macrobody = GetMacroInfo(id)
                if macroname then
                    alt.macro[tostring(id)] = {macroname, macroicon, macrobody}
                end
            elseif actionType == 'item' then
                local itemname,_,_,_,_,itemtype,_,_,_,itemicon = GetItemInfo(id)
                if itemname then
                    alt.item[tostring(id)] = {itemname, itemicon, itemtype}
                end
            end
        end
    end
    id, specname = GetSpecializationInfo(GetSpecialization())
    alt.spell[specname] = {}
    alt.spell[specname]["base"] = {}
    alt.spell[specname]["talent"] = {}
    for i = 1, 3 do
        local name,_,offset,numSpells = GetSpellTabInfo(i)
        for j = offset + 1, offset + numSpells do
            if not IsPassiveSpell(j, BOOKTYPE_SPELL) then
                local spell,subspell,spellid = GetSpellBookItemName(j, BOOKTYPE_SPELL)
                if spellid then
                    local spelldesc = GetSpellDescription(spellid)
                    local spellicon = GetSpellTexture(spellid)
                    alt.spell[specname]["base"][spellid] =  {spell, subspell, spelldesc, spellicon}
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