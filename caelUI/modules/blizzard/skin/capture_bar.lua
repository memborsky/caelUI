local CaptureBar = unpack(select(2, ...)).NewModule("CaptureBar", true)

--[[    Reskin capture bar  ]]

local barTex = CaptureBar:GetMedia().files.statusbar_a

CaptureBar:SetSize(130, 15)
CaptureBar:SetPoint("TOP", 0, -100)

hooksecurefunc("UIParent_ManageFramePositions", function()
    for index = 1, NUM_EXTENDED_UI_FRAMES do
        local bar = _G["WorldStateCaptureBar" .. index]

        if bar and bar:IsVisible() then
            bar:ClearAllPoints()

            if index == 1 then
                bar:SetPoint("TOP", CaptureBar, "TOP")
            else
                CaptureBar.SetPoint(bar, "TOPLEFT", _G["WorldStateCaptureBar" .. index - 1], "BOTTOMLEFT", 0, -7)
            end

            if not bar.skinned then
                local name = bar:GetName()

                left   = _G[name .. "LeftBar"]
                right  = _G[name .. "RightBar"]
                middle = _G[name .. "MiddleBar"]

                left:SetTexture(barTex)
                right:SetTexture(barTex)
                middle:SetTexture(barTex)

                left:SetVertexColor(0.31, 0.45, 0.63)
                right:SetVertexColor(0.69, 0.31, 0.31)
                middle:SetVertexColor(0.84, 0.75, 0.65)

                for _, texture in pairs{
                    _G[name .. "LeftLine"],
                    _G[name .. "RightLine"],
                    _G[name .. "LeftIconHighlight"],
                    _G[name .. "RightIconHighlight"]
                } do
                    texture:SetAlpha(0)
                end

                select(4, bar:GetRegions()):Hide()

                CaptureBar.CreateBackdrop(bar)

                bar.skinned = true
            end
        end
    end
end)