---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local Util = CUF.Util
local Handler = CUF.Handler
local Builder = CUF.Builder
local menu = CUF.Menu
local const = CUF.constants

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------
menu:AddWidget(const.WIDGET_KIND.LEVEL_TEXT,
    Builder.MenuOptions.TextColor,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.Font,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting OPTION_KIND
---@param subSetting string
function W.UpdateLevelTextWidget(button, unit, setting, subSetting)
    button.widgets.levelText.Update(button)
end

Handler:RegisterWidget(W.UpdateLevelTextWidget, const.WIDGET_KIND.LEVEL_TEXT)

-------------------------------------------------
-- MARK: Button Update Level
-------------------------------------------------

---@param button CUFUnitButton
local function Update(button)
    local unit = button.states.unit
    if not unit then return end

    if not button.widgets.levelText.enabled then return end

    local level = tostring(UnitLevel(unit))
    if level == "-1" then
        level = "??"
    end

    button.widgets.levelText:SetText(level)
end

---@param self LevelTextWidget
local function Enable(self)
    self:Show()

    return true
end

---@param self LevelTextWidget
local function Disable(self)
end

-------------------------------------------------
-- MARK: CreateLevelText
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateLevelText(button)
    ---@class LevelTextWidget: TextWidget
    local levelText = W.CreateBaseTextWidget(button, const.WIDGET_KIND.LEVEL_TEXT)
    button.widgets.levelText = levelText

    levelText.Update = Update
    levelText.Enable = Enable
    levelText.Disable = Disable
end

W:RegisterCreateWidgetFunc(const.WIDGET_KIND.LEVEL_TEXT, W.CreateLevelText)
