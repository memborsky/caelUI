local private = unpack(select(2, ...))

--[[    Put a shadow edge around the screen    ]]

local shadowedge = CreateFrame("Frame", nil, UIParent)

shadowedge:SetPoint("TOPLEFT")
shadowedge:SetPoint("BOTTOMRIGHT")
shadowedge:SetFrameLevel(0)
shadowedge:SetFrameStrata("BACKGROUND")
shadowedge.tex = shadowedge:CreateTexture()
shadowedge.tex:SetTexture(private.database.get("media")["files"]["largeshadertex1"])

shadowedge.tex:SetAllPoints()
shadowedge.tex:SetVertexColor(0, 0, 0, 0.5)

local SetUpAnimGroup = function(self)
    self.anim = self:CreateAnimationGroup("Flash")

    self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
    self.anim.fadeout:SetChange(-0.5)
    self.anim.fadeout:SetOrder(1)

    self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
    self.anim.fadein:SetChange(0.5)
    self.anim.fadein:SetOrder(2)

    self.anim:SetLooping("BOUNCE")
end

local Flash = function(self, duration)
    if not self.anim then
        SetUpAnimGroup(self)
    end

    if not self.anim:IsPlaying() or duration ~= self.anim.fadein:GetDuration() then
        self.anim.fadein:SetDuration(duration)
        self.anim.fadeout:SetDuration(duration)
        self.anim:Play()
    end
end

local StopFlash = function(self)
    if self.anim then
        self.anim:Finish()
    end
end

private.events:RegisterEvent("UNIT_HEALTH", function(self, event, unit)
    if (unit ~= "player") then
        return
    end

    if UnitIsDeadOrGhost(unit) then
        shadowedge.tex:SetVertexColor(0, 0, 0, 0.5)
        StopFlash(shadowedge.tex)
        return
    end

    local currentHealth, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
    local healthPercent = (currentHealth/maxHealth)

    if (currentHealth > 0 and healthPercent < 0.25) then
        shadowedge.tex:SetVertexColor(0.69, 0.31, 0.31, 0.5)
        Flash(shadowedge.tex, 0.25)
    elseif (healthPercent > 0.25 and healthPercent < 0.5)then
        shadowedge.tex:SetVertexColor(0.65, 0.63, 0.35, 0.5)
        Flash(shadowedge.tex, 0.5)
    else
        shadowedge.tex:SetVertexColor(0, 0, 0, 0.5)
        StopFlash(shadowedge.tex)
    end
end)
