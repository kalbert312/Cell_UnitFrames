---@class CUF
local CUF = select(2, ...)

local Cell = CUF.Cell
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs
local B = Cell.bFuncs

---@class CUF.widgets
local W = CUF.widgets
---@class CUF.uFuncs
local U = CUF.uFuncs

--! AI followers, wrong value returned by UnitClassBase
local UnitClassBase = function(unit)
    return select(2, UnitClass(unit))
end

-------------------------------------------------
-- MARK: Button Update HealthBar
-------------------------------------------------

---@param button CUFUnitButton
function U:UnitFrame_UpdateHealthColor(button)
    local unit = button.states.unit
    if not unit then return end

    button.states.class = UnitClassBase(unit) --! update class

    local barR, barG, barB
    local lossR, lossG, lossB
    local barA, lossA = 1, 1

    if Cell.loaded then
        barA = CellDB["appearance"]["barAlpha"]
        lossA = CellDB["appearance"]["lossAlpha"]
    end

    if not UnitIsConnected(unit) then
        barR, barG, barB = 0.4, 0.4, 0.4
        lossR, lossG, lossB = 0.4, 0.4, 0.4
    elseif UnitIsCharmed(unit) and UnitIsEnemy("player", unit) then
        barR, barG, barB, barA = 0.5, 0, 1, 1
        lossR, lossG, lossB, lossA = barR * 0.2, barG * 0.2, barB * 0.2, 1
    elseif button.states.inVehicle then
        barR, barG, barB, lossR, lossG, lossB = F:GetHealthBarColor(button.states.healthPercent,
            button.states.isDeadOrGhost or button.states.isDead, 0, 1, 0.2)
    else
        barR, barG, barB, lossR, lossG, lossB = F:GetHealthBarColor(button.states.healthPercent,
            button.states.isDeadOrGhost or button.states.isDead, CUF.Util:GetUnitClassColor(button.states.unit))
    end

    button.widgets.healthBar:SetStatusBarColor(barR, barG, barB, barA)
    button.widgets.healthBarLoss:SetVertexColor(lossR, lossG, lossB, lossA)

    --[[ if Cell.loaded and CellDB["appearance"]["healPrediction"][2] then
        self.widgets.incomingHeal:SetVertexColor(CellDB["appearance"]["healPrediction"][3][1], CellDB["appearance"]["healPrediction"][3][2], CellDB["appearance"]["healPrediction"][3][3], CellDB["appearance"]["healPrediction"][3][4])
    else
        self.widgets.incomingHeal:SetVertexColor(barR, barG, barB, 0.4)
    end ]]
end

---@param button CUFUnitButton
local function UpdateUnitHealthState(button)
    local unit = button.states.displayedUnit

    local health = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)
    health = min(health, healthMax) --! diff

    button.states.health = health
    button.states.healthMax = healthMax
    button.states.totalAbsorbs = UnitGetTotalAbsorbs(unit)

    if healthMax == 0 then
        button.states.healthPercent = 0
    else
        button.states.healthPercent = health / healthMax
    end

    button.states.wasDead = button.states.isDead
    button.states.isDead = health == 0
    if button.states.wasDead ~= button.states.isDead then
        --UnitButton_UpdateStatusText(self)
        --I.UpdateStatusIcon_Resurrection(self)
        if not button.states.isDead then
            button.states.hasSoulstone = nil
            --I.UpdateStatusIcon(self)
        end
    end

    button.states.wasDeadOrGhost = button.states.isDeadOrGhost
    button.states.isDeadOrGhost = UnitIsDeadOrGhost(unit)
    if button.states.wasDeadOrGhost ~= button.states.isDeadOrGhost then
        --I.UpdateStatusIcon_Resurrection(self        U:UnitFrame_UpdateHealthColor(self)
    end
end

---@param button CUFUnitButton
local function UpdateHealth(button)
    UpdateUnitHealthState(button)
    local healthPercent = button.states.healthPercent

    if CellDB["appearance"]["barAnimation"] == "Smooth" then
        button.widgets.healthBar:SetSmoothedValue(button.states.health)
    else
        button.widgets.healthBar:SetValue(button.states.health)
    end

    if Cell.vars.useGradientColor or Cell.vars.useFullColor or Cell.vars.useDeathColor then
        U:UnitFrame_UpdateHealthColor(button)
    end

    button.states.healthPercentOld = healthPercent

    --[[ if UnitIsDeadOrGhost(unit) then
        button.widgets.deadTex:Show()
    else
        button.widgets.deadTex:Hide()
    end ]]
end

---@param button CUFUnitButton
local function UpdateHealthMax(button)
    UpdateUnitHealthState(button)

    if CellDB["appearance"]["barAnimation"] == "Smooth" then
        button.widgets.healthBar:SetMinMaxSmoothedValue(0, button.states.healthMax)
    else
        button.widgets.healthBar:SetMinMaxValues(0, button.states.healthMax)
    end

    if Cell.vars.useGradientColor or Cell.vars.useFullColor or Cell.vars.useDeathColor then
        U:UnitFrame_UpdateHealthColor(button)
    end
end

---@param button CUFUnitButton
function U:UnitFrame_UpdateHealthTexture(button)
    button.widgets.healthBar:SetStatusBarTexture(F:GetBarTexture())
    button.widgets.healthBarLoss:SetTexture(F:GetBarTexture())
end

---@param button CUFUnitButton
local function Update(button)
    UpdateHealthMax(button)
    UpdateHealth(button)
end

---@param self HealthBarWidget
local function Enable(self)
    local unitLess
    if self._owner.states.unit == CUF.constants.UNIT.TARGET_TARGET then
        unitLess = true
    end

    self._owner:AddEventListener("UNIT_HEALTH", UpdateHealth, unitLess)
    self._owner:AddEventListener("UNIT_MAXHEALTH", UpdateHealthMax, unitLess)

    self:Show()

    return true
end

---@param self HealthBarWidget
local function Disable(self)
    self._owner:RemoveEventListener("UNIT_HEALTH", UpdateHealth)
    self._owner:RemoveEventListener("UNIT_MAXHEALTH", UpdateHealthMax)

    return true
end

-------------------------------------------------
-- MARK: CreateHealthBar
-------------------------------------------------

---@param button CUFUnitButton
function W:CreateHealthBar(button)
    ---@class HealthBarWidget: StatusBar, SmoothStatusBar
    local healthBar = CreateFrame("StatusBar", button:GetName() .. "_HealthBar", button)
    button.widgets.healthBar = healthBar
    healthBar._owner = button
    healthBar.enabled = true

    healthBar:SetStatusBarTexture(Cell.vars.texture)
    healthBar:SetFrameLevel(button:GetFrameLevel() + 1)
    healthBar:SetPoint("TOPLEFT", button, "TOPLEFT", P:Scale(1), P:Scale(-1))
    healthBar:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", P:Scale(-1), P:Scale(1))

    -- smooth
    Mixin(healthBar, SmoothStatusBarMixin)

    local healthBarLoss = healthBar:CreateTexture(button:GetName() .. "_HealthBarLoss", "ARTWORK", nil, -7)
    button.widgets.healthBarLoss = healthBarLoss
    healthBarLoss:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    healthBarLoss:SetPoint("BOTTOMRIGHT")
    healthBarLoss:SetTexture(Cell.vars.texture)

    healthBar.Update = Update
    healthBar.Enable = Enable
    healthBar.Disable = Disable

    --[[ -- dead texture
    local deadTex = healthBar:CreateTexture(nil, "OVERLAY")
    button.widgets.deadTex = deadTex
    deadTex:SetAllPoints(healthBar)
    deadTex:SetTexture(Cell.vars.whiteTexture)
    deadTex:SetGradient("VERTICAL", CreateColor(0.545, 0, 0, 1), CreateColor(0, 0, 0, 1))
    deadTex:Hide() ]]
end
