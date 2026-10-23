--[[
    Nullgate's Action Bars - Config.lua
    Data Layer: Database Defaults, Get/Set Accessors, Slash Commands & Hub Registration
]]

local addonName, BAB = ...

local ADDON_NAME = "NullgatesActionBars"
local FULL_TITLE = "Nullgate's Action Bars"
local DISPLAY_TITLE = "Action Bars"

local Config = {}
BAB.Config = Config
_G["NullgatesActionBarsConfig"] = Config

local _, playerClass = UnitClass("player")
local petClasses = { HUNTER = true, WARLOCK = true, MAGE = true }
local stanceClasses = { WARRIOR = true, DRUID = true, ROGUE = true, PRIEST = true, PALADIN = true }

local defaultPetEnabled = petClasses[playerClass] or false
local defaultStanceEnabled = stanceClasses[playerClass] or false

-- Database Defaults
local DB_DEFAULTS = {
    general = {
        enabled = true,
        buttonSize = 36,
        spacing = 4,
        fadeOutOfCombat = false,
        outOfCombatAlpha = 0.35,
        mouseoverFade = false,
        abbreviateHotkey = true,
        zoomIcons = true,
        font = "Nata Sans Regular",
        headerFont = "Nata Sans Bold",
        hotkeyFontSize = 14,
        countFontSize = 14,
        macroFontSize = 10,
        fontOutline = "OUTLINE",
        hideKeybindText = false,
        hideMacroText = false,
        hideCountText = false,
        lockPositions = false,
        rangeColor = { r = 0.8, g = 0.1, b = 0.1 },
        rangeDesaturate = false,
        manaColor = { r = 0.2, g = 0.4, b = 0.9 },
        unusableColor = { r = 0.4, g = 0.4, b = 0.4 },
        globalFade = false,
        globalFadeAlpha = 0,
        flyoutDirection = "UP",
        cooldownText = true,
        cooldownFont = "Nata Sans Bold",
        cooldownFontSize = 16,
        cooldownThresholdLow = 3,
        cooldownLowColor = { r = 1.0, g = 0.2, b = 0.2 },
        cooldownSecColor = { r = 1.0, g = 0.9, b = 0.1 },
        cooldownMinColor = { r = 1.0, g = 1.0, b = 1.0 },
        cooldownHourColor = { r = 0.7, g = 0.7, b = 0.7 },
        castOnKeyDown = true,
        cooldownPulse = true,
        cooldownPulseScale = 1.3,
        procGlow = true,
    },
    extraBar = {
        enabled = true,
        scale = 100,
        alpha = 100,
        backdrop = true,
        frameStrata = "LOW",
        frameLevel = 1,
        clickThrough = false,
        inheritGlobalFade = false,
    },
    vehicleLeave = {
        enabled = true,
        scale = 100,
        alpha = 100,
        backdrop = true,
        frameStrata = "LOW",
        frameLevel = 1,
        clickThrough = false,
        inheritGlobalFade = false,
    },
    stanceBar = {
        enabled = defaultStanceEnabled,
        orientation = "HORIZONTAL",
        buttonSize = 28,
        buttonSpacing = 4,
        buttonsPerRow = 10,
        mouseover = false,
        fadeOutOfCombat = false,
        outOfCombatAlpha = 35,
        alpha = 100,
        scale = 100,
        backdrop = true,
        frameStrata = "LOW",
        frameLevel = 1,
        clickThrough = false,
        inheritGlobalFade = false,
        visibilityCondition = "",
    },
    totemBar = {
        enabled = (playerClass == "SHAMAN"),
        orientation = "HORIZONTAL",
        buttonSize = 30,
        buttonSpacing = 4,
        alpha = 100,
        scale = 100,
        backdrop = true,
        frameStrata = "LOW",
        frameLevel = 1,
        clickThrough = false,
        inheritGlobalFade = false,
    },
    petBar = {
        enabled = defaultPetEnabled,
        buttonSize = 28,
        buttonSpacing = 4,
        buttonsPerRow = 10,
        mouseover = false,
        fadeOutOfCombat = false,
        outOfCombatAlpha = 35,
        alpha = 100,
        scale = 100,
        backdrop = true,
        frameStrata = "LOW",
        frameLevel = 1,
        clickThrough = false,
        inheritGlobalFade = false,
        visibilityCondition = "",
    },
    microBar = {
        enabled = true,
        numButtons = 20,
        buttonWidth = 28,
        buttonHeight = 36,
        buttonSpacing = 2,
        buttonsPerRow = 20,
        mouseover = false,
        fadeOutOfCombat = false,
        outOfCombatAlpha = 35,
        alpha = 100,
        scale = 100,
        backdrop = true,
        frameStrata = "LOW",
        frameLevel = 1,
        clickThrough = false,
        inheritGlobalFade = false,
    },
    bagsBar = {
        enabled = true,
        orientation = "HORIZONTAL",
        buttonsPerRow = 6,
        buttonSize = 32,
        buttonSpacing = 4,
        mouseover = false,
        fadeOutOfCombat = false,
        outOfCombatAlpha = 35,
        alpha = 100,
        scale = 100,
        backdrop = true,
        frameStrata = "LOW",
        frameLevel = 1,
        clickThrough = false,
        inheritGlobalFade = false,
        showBackpack = true,
        showBagSlots = true,
        showReagentBag = true,
        showKeyRing = true,
    },
    movers = {},
}

-- Bars 1 through 15 defaults
for i = 1, 15 do
    DB_DEFAULTS["bar" .. i] = {
        enabled = (i <= 5),
        numButtons = 12,
        buttonsPerRow = 12,
        buttonSize = 36,
        buttonSpacing = 4,
        mouseover = false,
        fadeOutOfCombat = false,
        outOfCombatAlpha = 35,
        showEmptyButtons = true,
        alpha = 100,
        scale = 100,
        backdrop = true,
        anchorPoint = "BOTTOMLEFT",
        frameStrata = "LOW",
        frameLevel = 1,
        clickThrough = false,
        inheritGlobalFade = false,
        flyoutDirection = "UP",
        visibilityCondition = "",
        stancePaging = (i == 1),
        shiftPaging = (i == 1 and 2 or 0),
        ctrlPaging = (i == 1 and 3 or 0),
        altPaging = (i == 1 and 4 or 0),
    }
end

Config.DEFAULTS = DB_DEFAULTS

--[[-----------------------------------------------------------------------------
    Deep Copy Utility
-------------------------------------------------------------------------------]]
local function DeepCopy(orig)
    if type(orig) ~= "table" then return orig end
    local copy = {}
    for k, v in pairs(orig) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

--[[-----------------------------------------------------------------------------
    Database Initialization & Multi-Profile Support
-------------------------------------------------------------------------------]]
local function EnsureProfileDefaults(profileTable)
    if type(profileTable) ~= "table" then return end
    for section, secDefaults in pairs(DB_DEFAULTS) do
        if type(secDefaults) == "table" then
            if type(profileTable[section]) ~= "table" then
                profileTable[section] = {}
            end
            for k, v in pairs(secDefaults) do
                if profileTable[section][k] == nil then
                    profileTable[section][k] = DeepCopy(v)
                end
            end
        elseif profileTable[section] == nil then
            profileTable[section] = secDefaults
        end
    end
end

function Config:InitDB()
    if type(NullgatesActionBarsDB) ~= "table" then
        NullgatesActionBarsDB = {}
    end

    -- Multi-profile initialization & automatic migration of flat settings
    if type(NullgatesActionBarsDB.profiles) ~= "table" then
        local defaultProfile = {}
        for section, secDefaults in pairs(DB_DEFAULTS) do
            if NullgatesActionBarsDB[section] ~= nil then
                defaultProfile[section] = DeepCopy(NullgatesActionBarsDB[section])
            end
        end
        if NullgatesActionBarsDB.movers ~= nil then
            defaultProfile.movers = DeepCopy(NullgatesActionBarsDB.movers)
        end
        EnsureProfileDefaults(defaultProfile)

        NullgatesActionBarsDB.profiles = {
            ["Default"] = defaultProfile
        }
        NullgatesActionBarsDB.activeProfile = "Default"
    end

    local active = NullgatesActionBarsDB.activeProfile or "Default"
    if not NullgatesActionBarsDB.profiles[active] then
        NullgatesActionBarsDB.profiles[active] = DeepCopy(DB_DEFAULTS)
    end
    EnsureProfileDefaults(NullgatesActionBarsDB.profiles[active])

    -- Point active profile tables directly to root NullgatesActionBarsDB for seamless backward compatibility
    for section in pairs(DB_DEFAULTS) do
        NullgatesActionBarsDB[section] = NullgatesActionBarsDB.profiles[active][section]
    end
    if not NullgatesActionBarsDB.profiles[active].movers then
        NullgatesActionBarsDB.profiles[active].movers = {}
    end
    NullgatesActionBarsDB.movers = NullgatesActionBarsDB.profiles[active].movers

    -- Wire reference to BAB.db for seamless access
    BAB.db = NullgatesActionBarsDB
    if not BAB.db.profile then
        BAB.db.profile = {}
    end
    BAB.db.profile.actionbars = NullgatesActionBarsDB
    BAB.db.profile.general = NullgatesActionBarsDB.general
end

--[[-----------------------------------------------------------------------------
    Profile Accessors & Management
-------------------------------------------------------------------------------]]
function Config:GetActiveProfile()
    return (NullgatesActionBarsDB and NullgatesActionBarsDB.activeProfile) or "Default"
end

function Config:GetProfiles()
    local list = {}
    if NullgatesActionBarsDB and NullgatesActionBarsDB.profiles then
        for name in pairs(NullgatesActionBarsDB.profiles) do
            table.insert(list, name)
        end
    end
    if #list == 0 then table.insert(list, "Default") end
    table.sort(list)
    return list
end

function Config:SetActiveProfile(name)
    if not name or name == "" then return end
    self:InitDB()

    if not NullgatesActionBarsDB.profiles[name] then
        local current = self:GetActiveProfile()
        NullgatesActionBarsDB.profiles[name] = DeepCopy(NullgatesActionBarsDB.profiles[current] or DB_DEFAULTS)
    end
    EnsureProfileDefaults(NullgatesActionBarsDB.profiles[name])
    NullgatesActionBarsDB.activeProfile = name

    -- Re-link root section tables to the newly active profile
    for section in pairs(DB_DEFAULTS) do
        NullgatesActionBarsDB[section] = NullgatesActionBarsDB.profiles[name][section]
    end
    if not NullgatesActionBarsDB.profiles[name].movers then
        NullgatesActionBarsDB.profiles[name].movers = {}
    end
    NullgatesActionBarsDB.movers = NullgatesActionBarsDB.profiles[name].movers

    BAB.db = NullgatesActionBarsDB
    if not BAB.db.profile then BAB.db.profile = {} end
    BAB.db.profile.actionbars = NullgatesActionBarsDB
    BAB.db.profile.general = NullgatesActionBarsDB.general

    -- Live re-apply all bars and movers
    if BAB.Core and BAB.Core.UpdateAllBars then
        BAB.Core:UpdateAllBars()
    end
    if BAB.Core and BAB.Core.ApplyAllMoverPositions then
        BAB.Core:ApplyAllMoverPositions()
    end
    if BAB.UI and BAB.UI.Refresh then
        BAB.UI:Refresh()
    end
end

function Config:SaveCurrentAs(name)
    if not name or name == "" then return end
    self:InitDB()
    local curActive = self:GetActiveProfile()
    NullgatesActionBarsDB.profiles[name] = DeepCopy(NullgatesActionBarsDB.profiles[curActive] or NullgatesActionBarsDB or DB_DEFAULTS)
    EnsureProfileDefaults(NullgatesActionBarsDB.profiles[name])
    self:SetActiveProfile(name)
end

function Config:CreateProfile(name, fromName)
    if not name or name == "" then return end
    self:InitDB()
    -- Never overwrite existing profile!
    if not NullgatesActionBarsDB.profiles[name] then
        local source = fromName and NullgatesActionBarsDB.profiles[fromName]
        if not source then
            local curActive = self:GetActiveProfile()
            source = NullgatesActionBarsDB.profiles[curActive] or NullgatesActionBarsDB or DB_DEFAULTS
        end
        NullgatesActionBarsDB.profiles[name] = DeepCopy(source)
        EnsureProfileDefaults(NullgatesActionBarsDB.profiles[name])
    end
    self:SetActiveProfile(name)
end

function Config:DeleteProfile(name)
    if not name or name == "Default" then return end
    self:InitDB()
    NullgatesActionBarsDB.profiles[name] = nil
    if NullgatesActionBarsDB.activeProfile == name then
        self:SetActiveProfile("Default")
    end
end

function Config:CopyProfile(fromName, toName)
    self:InitDB()
    if NullgatesActionBarsDB.profiles[fromName] then
        NullgatesActionBarsDB.profiles[toName] = DeepCopy(NullgatesActionBarsDB.profiles[fromName])
        if NullgatesActionBarsDB.activeProfile == toName then
            self:SetActiveProfile(toName)
        end
    end
end

function Config:ResetProfile(name)
    name = name or self:GetActiveProfile()
    self:InitDB()
    NullgatesActionBarsDB.profiles[name] = DeepCopy(DB_DEFAULTS)
    if NullgatesActionBarsDB.activeProfile == name then
        self:SetActiveProfile(name)
    end
end

--[[-----------------------------------------------------------------------------
    Database Accessors with Instant Auto-Save
-------------------------------------------------------------------------------]]
function Config:Get(section, key, default)
    if not NullgatesActionBarsDB then return default end
    if section and key then
        local secTable = NullgatesActionBarsDB[section]
        if secTable and secTable[key] ~= nil then
            return secTable[key]
        end
    elseif section and not key then
        if NullgatesActionBarsDB[section] ~= nil then
            return NullgatesActionBarsDB[section]
        end
    end
    return default
end

function Config:Set(section, key, value)
    if not NullgatesActionBarsDB then
        self:InitDB()
    end

    local activeProf = self:GetActiveProfile()
    local profTable = NullgatesActionBarsDB.profiles and NullgatesActionBarsDB.profiles[activeProf]

    if section and key then
        if type(NullgatesActionBarsDB[section]) ~= "table" then
            NullgatesActionBarsDB[section] = {}
        end
        NullgatesActionBarsDB[section][key] = value

        if profTable then
            if type(profTable[section]) ~= "table" then
                profTable[section] = {}
            end
            profTable[section][key] = value
        end
    elseif section and not key then
        NullgatesActionBarsDB[section] = value
        if profTable then
            profTable[section] = value
        end
    end

    -- Notify Core logic of setting change
    if BAB.Core and BAB.Core.OnSettingChanged then
        BAB.Core:OnSettingChanged(section, key, value)
    end

    -- Live refresh UI if active
    if BAB.UI and BAB.UI.Refresh then
        BAB.UI:Refresh()
    end
end

function Config:ResetDB()
    NullgatesActionBarsDB = DeepCopy(DB_DEFAULTS)
    self:InitDB()

    if BAB.Core and BAB.Core.UpdateAllBars then
        BAB.Core:UpdateAllBars()
    end
    if BAB.Core and BAB.Core.ResetMovers then
        BAB.Core:ResetMovers()
    end
    if BAB.UI and BAB.UI.Refresh then
        BAB.UI:Refresh()
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cff3399ff[" .. FULL_TITLE .. "]|r All settings reset to defaults.")
end

function Config:CopyBarSettings(sourceKey, targetKey)
    local src = NullgatesActionBarsDB[sourceKey]
    local dest = NullgatesActionBarsDB[targetKey]
    if not src or not dest then return end

    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = DeepCopy(v)
        else
            dest[k] = v
        end
    end

    if BAB.Core and BAB.Core.UpdateAllBars then
        BAB.Core:UpdateAllBars()
    end
    if BAB.UI and BAB.UI.Refresh then
        BAB.UI:Refresh()
    end

    local srcName = sourceKey:gsub("bar", "Bar "):gsub("petBar", "Pet Bar"):gsub("stanceBar", "Stance Bar")
    local destName = targetKey:gsub("bar", "Bar "):gsub("petBar", "Pet Bar"):gsub("stanceBar", "Stance Bar")
    DEFAULT_CHAT_FRAME:AddMessage("|cff3399ff[" .. FULL_TITLE .. "]|r Copied settings from " .. srcName .. " to " .. destName .. ".")
end

--[[-----------------------------------------------------------------------------
    Open / Toggle Configuration Window
-------------------------------------------------------------------------------]]
function Config:Open(forceStandalone)
    if not forceStandalone and NullgatesAddonConfigForever and NullgatesAddonConfigForever.SelectModule then
        NullgatesAddonConfigForever:ShowUI()
        NullgatesAddonConfigForever:SelectModule(ADDON_NAME)
    else
        local ui = BAB.UI or _G["NullgatesActionBarsUI"]
        if ui and ui.ToggleStandaloneWindow then
            ui:ToggleStandaloneWindow()
        end
    end
end

--[[-----------------------------------------------------------------------------
    Slash Command Routing
-------------------------------------------------------------------------------]]
SLASH_NULLGATESACTIONBARS1 = "/nab"
SLASH_NULLGATESACTIONBARS2 = "/actionbars"

SlashCmdList["NULLGATESACTIONBARS"] = function(msg)
    msg = msg and string.trim and string.trim(msg:lower()) or (msg and msg:lower() or "")
    if msg == "move" or msg == "unlock" or msg == "movers" then
        local BAC = _G["NullgatesAddonConfigForever"] or _G["NullgatesAddonConfig"]
        if BAC and BAC.ToggleAllMovers then
            BAC:ToggleAllMovers(true)
        elseif BAB.Core and BAB.Core.ToggleMovers then
            BAB.Core:ToggleMovers(true)
        end
    elseif msg == "lock" then
        local BAC = _G["NullgatesAddonConfigForever"] or _G["NullgatesAddonConfig"]
        if BAC and BAC.ToggleAllMovers then
            BAC:ToggleAllMovers(false)
        elseif BAB.Core and BAB.Core.ToggleMovers then
            BAB.Core:ToggleMovers(false)
        end
    elseif msg == "bind" or msg == "keybind" then
        if BAB.Core and BAB.Core.ToggleKeybindMode then
            BAB.Core:ToggleKeybindMode()
        end
    elseif msg == "standalone" or msg == "ui" or msg == "panel" or msg == "solo" then
        Config:Open(true)
    elseif msg == "reset" then
        Config:ResetDB()
    else
        Config:Open()
    end
end

--[[-----------------------------------------------------------------------------
    Event Handling & Hub Registration
-------------------------------------------------------------------------------]]
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

local function ToggleMoversHook(state)
    local core = BAB.Core or _G["NullgatesActionBarsCore"]
    if core and core.ToggleMovers then
        core:ToggleMovers(state)
    end
end

local function ResetMoversHook()
    local core = BAB.Core or _G["NullgatesActionBarsCore"]
    if core and core.ResetMovers then
        core:ResetMovers()
    end
end

local function IsMoversUnlockedHook()
    local core = BAB.Core or _G["NullgatesActionBarsCore"]
    if core and core.IsMoversUnlocked then
        return core:IsMoversUnlocked()
    end
    return false
end

-- Global cross-addon movers registry for master HUD / config integration
_G.Nullgates_MoversRegistry = _G.Nullgates_MoversRegistry or {}
_G.Nullgates_MoversRegistry["ActionBars"] = {
    name = FULL_TITLE,
    sidebarName = DISPLAY_TITLE,
    Toggle = ToggleMoversHook,
    Reset = ResetMoversHook,
    IsUnlocked = IsMoversUnlockedHook,
}

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == addonName then
        Config:InitDB()
    end

    if arg1 == "NullgatesAddonConfig-Forever" or arg1 == addonName then
        if NullgatesAddonConfigForever and NullgatesAddonConfigForever.RegisterModule then
            NullgatesAddonConfigForever:RegisterModule(ADDON_NAME, {
                name = FULL_TITLE,
                sidebarName = DISPLAY_TITLE,
                author = "Nullgate Studios",
                isNullgate = true,
                description = "Modular, minimalist action bar suite for WoW Forever.",
                db = NullgatesActionBarsDB,
                profiles = {
                    GetCurrent = function() return Config:GetActiveProfile() end,
                    SetCurrent = function(p) Config:SetActiveProfile(p) end,
                    SaveCurrentAs = function(p) Config:SaveCurrentAs(p) end,
                    List       = function() return Config:GetProfiles() end,
                    Create     = function(p, from) Config:CreateProfile(p, from) end,
                    Delete     = function(p) Config:DeleteProfile(p) end,
                    Copy       = function(f, t) Config:CopyProfile(f, t) end,
                    Reset      = function(p) Config:ResetProfile(p) end,
                },
                toggleMovers = ToggleMoversHook,
                resetMovers = ResetMoversHook,
                isMoversUnlocked = IsMoversUnlockedHook,
                refresh = function()
                    local core = BAB.Core or _G["NullgatesActionBarsCore"]
                    if core and core.ApplyAllMoverPositions then
                        core:ApplyAllMoverPositions()
                    end
                    if core and core.LayoutBagsBar then
                        core:LayoutBagsBar()
                    end
                    if core and core.UpdateAllBars then
                        core:UpdateAllBars()
                    end
                    local ui = BAB.UI or _G["NullgatesActionBarsUI"]
                    if ui and ui.Refresh then ui:Refresh() end
                end,
                buildUI = function(container, isMasterHub)
                    local ui = BAB.UI or _G["NullgatesActionBarsUI"]
                    if ui and ui.BuildOptions then
                        ui:BuildOptions(container, isMasterHub)
                    end
                end,
            })
        end
    end
end)

