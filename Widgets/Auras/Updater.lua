---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local P = Cell.pixelPerfectFuncs

local const = CUF.constants
local DB = CUF.DB
local U = CUF.uFuncs

---@class CUF.widgets
local W = CUF.widgets

---@param button CUFUnitButton
---@param unit Unit
---@param which "buffs" | "debuffs"
---@param setting AURA_OPTION_KIND
---@param subSetting string
function W.UpdateAuraWidget(button, unit, which, setting, subSetting, ...)
    ---@type CellAuraIcons
    local auras = button.widgets[which]

    local styleTable = DB.GetWidgetTable(which, unit) --[[@as AuraWidgetTable]]

    if not setting or setting == const.AURA_OPTION_KIND.FONT or const.AURA_OPTION_KIND.POSITION then
        auras:SetFont(styleTable.font)
    end
    if not setting or setting == const.AURA_OPTION_KIND.ORIENTATION then
        auras:SetOrientation(styleTable.orientation)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SIZE then
        P:Size(auras, styleTable.size.width, styleTable.size.height)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SHOW_DURATION then
        auras:ShowDuration(styleTable.showDuration)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SHOW_ANIMATION then
        auras:ShowAnimation(styleTable.showAnimation)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SHOW_STACK then
        auras:ShowStack(styleTable.showStack)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SHOW_TOOLTIP then
        auras:ShowTooltip(styleTable.showTooltip)
    end
    if not setting or setting == const.AURA_OPTION_KIND.SPACING then
        auras:SetSpacing({ styleTable.spacing.horizontal, styleTable.spacing.vertical })
    end
    if not setting or setting == const.AURA_OPTION_KIND.NUM_PER_LINE then
        auras:SetNumPerLine(styleTable.numPerLine)
    end
    if not setting or setting == const.AURA_OPTION_KIND.MAX_ICONS then
        auras:SetMaxNum(styleTable.maxIcons)
    end
    if not setting or setting == const.AURA_OPTION_KIND.FILTER then
        if not subSetting or subSetting == "hidePersonal" then
            auras:SetHidePersonal(styleTable.filter.hidePersonal)
        end
        if not subSetting or subSetting == "hideNoDuration" then
            auras:SetHideNoDuration(styleTable.filter.hideNoDuration)
        end
        if not subSetting or subSetting == "hideExternal" then
            auras:SetHideExternal(styleTable.filter.hideExternal)
        end
        if not subSetting or subSetting == "maxDuration" then
            auras:SetMaxDuration(styleTable.filter.maxDuration)
        end
        if not subSetting or subSetting == "minDuration" then
            auras:SetMinDuration(styleTable.filter.minDuration)
        end
        if not subSetting or subSetting == "blacklist" then
            auras:SetBlacklist(styleTable.filter.blacklist)
        end
        if not subSetting or subSetting == "whitelist" then
            auras:SetWhitelist(styleTable.filter.whitelist)
        end
        if not subSetting or subSetting == "useBlacklist" then
            auras:SetUseBlacklist(styleTable.filter.useBlacklist)
        end
        if not subSetting or subSetting == "useWhitelist" then
            auras:SetUseWhitelist(styleTable.filter.useWhitelist)
        end
    end

    if not setting or setting == const.OPTION_KIND.ENABLED then
        U:ToggleAuras(button)
    end

    U:UnitFrame_UpdateAuras(button)
end
