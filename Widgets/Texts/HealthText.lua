---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

local Handler = CUF.Handler
local Builder = CUF.Builder
local menu = CUF.Menu
local const = CUF.constants
local DB = CUF.DB

-------------------------------------------------
-- MARK: AddWidget
-------------------------------------------------

menu:AddWidget(const.WIDGET_KIND.HEALTH_TEXT, "Health",
    Builder.MenuOptions.TextColor,
    Builder.MenuOptions.HealthFormat,
    Builder.MenuOptions.Anchor,
    Builder.MenuOptions.Font,
    Builder.MenuOptions.FrameLevel)

---@param button CUFUnitButton
---@param unit Unit
---@param setting string
---@param subSetting string
function W.UpdateHealthTextWidget(button, unit, setting, subSetting, ...)
    local widget = button.widgets.healthText
    local styleTable = DB.GetWidgetTable(const.WIDGET_KIND.HEALTH_TEXT, unit) --[[@as HealthTextWidgetTable]]

    if not setting or setting == const.OPTION_KIND.FORMAT then
        widget:SetFormat(styleTable.format)
    end
    if not setting or setting == const.OPTION_KIND.TEXT_FORMAT then
        widget:SetTextFormat(styleTable.textFormat)
        widget:SetFormat(styleTable.format)
    end

    U:UnitFrame_UpdateHealthText(button)
end

Handler:RegisterWidget(W.UpdateHealthTextWidget, const.WIDGET_KIND.HEALTH_TEXT)

-------------------------------------------------
-- MARK: UpdateHealthText
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdateHealthText(button)
    if button.states.displayedUnit then
        U:UpdateUnitHealthState(button)

        button.widgets.healthText:UpdateTextColor()
        button.widgets.healthText:UpdateValue()
    end
end

-------------------------------------------------
-- MARK: Format
-------------------------------------------------

-- TODO: make generic

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Percentage(self, current, max, totalAbsorbs)
    self:SetFormattedText("%d%%", current / max * 100)
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Percentage_Absorbs(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self:SetFormattedText("%d%%", current / max * 100)
    else
        self:SetFormattedText("%d%%+%d%%", current / max * 100, totalAbsorbs / max * 100)
    end
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Percentage_Absorbs_Merged(self, current, max, totalAbsorbs)
    self:SetFormattedText("%d%%", (current + totalAbsorbs) / max * 100)
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Percentage_Deficit(self, current, max, totalAbsorbs)
    self:SetFormattedText("%d%%", (current - max) / max * 100)
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number(self, current, max, totalAbsorbs)
    self:SetText(tostring(current))
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Short(self, current, max, totalAbsorbs)
    self:SetText(F:FormatNumber(current))
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Absorbs_Short(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self:SetText(F:FormatNumber(current))
    else
        self:SetFormattedText("%s+%s", F:FormatNumber(current), F:FormatNumber(totalAbsorbs))
    end
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Absorbs_Merged_Short(self, current, max, totalAbsorbs)
    self:SetText(F:FormatNumber(current + totalAbsorbs))
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Deficit(self, current, max, totalAbsorbs)
    self:SetText(tostring(current - max))
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Number_Deficit_Short(self, current, max, totalAbsorbs)
    self:SetText(F:FormatNumber(current - max))
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Current_Short_Percentage(self, current, max, totalAbsorbs)
    self:SetFormattedText("%s %d%%", F:FormatNumber(current), (current / max * 100))
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Absorbs_Only(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self:SetText("")
    else
        self:SetText(tostring(totalAbsorbs))
    end
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Absorbs_Only_Short(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self:SetText("")
    else
        self:SetText(F:FormatNumber(totalAbsorbs))
    end
end

---@param self HealthTextWidget
---@param current number
---@param max number
---@param totalAbsorbs number
local function SetHealth_Absorbs_Only_Percentage(self, current, max, totalAbsorbs)
    if totalAbsorbs == 0 then
        self:SetText("")
    else
        self:SetFormattedText("%d%%", totalAbsorbs / max * 100)
    end
end

-------------------------------------------------
-- MARK: Custom Format
-------------------------------------------------

---@param self HealthTextWidget
local function SetHealth_Custom(self)
    local formatFn = W.ProcessCustomTextFormat(self.textFormat)
    self.SetValue = function(_, current, max, totalAbsorbs)
        self:SetText(formatFn(current, max, totalAbsorbs))
    end
end

-------------------------------------------------
-- MARK: Setters
-------------------------------------------------

---@class HealthTextWidget
---@param self HealthTextWidget
---@param format HealthTextFormat
local function HealthText_SetFormat(self, format)
    if format == const.HealthTextFormat.PERCENTAGE then
        self.SetValue = SetHealth_Percentage
    elseif format == const.HealthTextFormat.PERCENTAGE_ABSORBS then
        self.SetValue = SetHealth_Percentage_Absorbs
    elseif format == const.HealthTextFormat.PERCENTAGE_ABSORBS_MERGED then
        self.SetValue = SetHealth_Percentage_Absorbs_Merged
    elseif format == const.HealthTextFormat.PERCENTAGE_DEFICIT then
        self.SetValue = SetHealth_Percentage_Deficit
    elseif format == const.HealthTextFormat.NUMBER then
        self.SetValue = SetHealth_Number
    elseif format == const.HealthTextFormat.NUMBER_SHORT then
        self.SetValue = SetHealth_Number_Short
    elseif format == const.HealthTextFormat.NUMBER_ABSORBS_SHORT then
        self.SetValue = SetHealth_Number_Absorbs_Short
    elseif format == const.HealthTextFormat.NUMBER_ABSORBS_MERGED_SHORT then
        self.SetValue = SetHealth_Number_Absorbs_Merged_Short
    elseif format == const.HealthTextFormat.NUMBER_DEFICIT then
        self.SetValue = SetHealth_Number_Deficit
    elseif format == const.HealthTextFormat.NUMBER_DEFICIT_SHORT then
        self.SetValue = SetHealth_Number_Deficit_Short
    elseif format == const.HealthTextFormat.CURRENT_SHORT_PERCENTAGE then
        self.SetValue = SetHealth_Current_Short_Percentage
    elseif format == const.HealthTextFormat.ABSORBS_ONLY then
        self.SetValue = SetHealth_Absorbs_Only
    elseif format == const.HealthTextFormat.ABSORBS_ONLY_SHORT then
        self.SetValue = SetHealth_Absorbs_Only_Short
    elseif format == const.HealthTextFormat.ABSORBS_ONLY_PERCENTAGE then
        self.SetValue = SetHealth_Absorbs_Only_Percentage
    elseif format == const.HealthTextFormat.CUSTOM then
        self.SetValue = SetHealth_Custom
    end
end

---@class HealthTextWidget
---@param self HealthTextWidget
---@param format string
local function HealthText_SetTextFormat(self, format)
    self.textFormat = format
end

-------------------------------------------------
-- MARK: CreateHealthText
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateHealthText(button)
    ---@class HealthTextWidget: TextWidget
    local healthText = W.CreateBaseTextWidget(button, const.WIDGET_KIND.HEALTH_TEXT)
    button.widgets.healthText = healthText

    healthText.textFormat = ""

    healthText.SetFormat = HealthText_SetFormat
    healthText.SetTextFormat = HealthText_SetTextFormat
    healthText.SetValue = SetHealth_Percentage

    function healthText:UpdateValue()
        if button.widgets.healthText.enabled and button.states.healthMax ~= 0 then
            button.widgets.healthText:SetValue(button.states.health, button.states.healthMax, button.states.totalAbsorbs)
            button.widgets.healthText:Show()
        else
            button.widgets.healthText:Hide()
        end
    end
end