local _, caelQuest = ...

caelQuest.eventFrame = CreateFrame"Frame"

local questIndex

local QuestCompleted = ERR_QUEST_OBJECTIVE_COMPLETE_S
local ObjCompPattern = QuestCompleted:gsub("[()]", "%%%1"):gsub("%%s", "(%.%-)")

local UIErrorsFrame_OldOnEvent = UIErrorsFrame:GetScript("OnEvent")
UIErrorsFrame:SetScript("OnEvent", function(self, event, msg, ...)
    if event == "UI_INFO_MESSAGE" then
        if msg:find("(.-): (.-)/(.+)") or msg:find(ObjCompPattern) or msg:find("Objective Complete.") then
            -- return RaidNotice_AddMessage(RaidWarningFrame, msg, ChatTypeInfo["SYSTEM"])
            return
        end
    end

    return UIErrorsFrame_OldOnEvent(self, event, msg, ...)
end)

function MostValuable ()
    local bestPrice, bestItem = 0

    for i = 1, GetNumQuestChoices() do
        local link = GetQuestItemLink("choice", i)
        local quality = select(4, GetQuestItemInfo("choice", i))
        local price = link and select(11, GetItemInfo(link))

        if not price then
            return
        elseif (price * (quality or 1)) > bestPrice then
            bestPrice, bestItem = (price * (quality or 1)), i
        end
    end

    if bestItem then
        local button = _G["QuestInfoItem"..bestItem]
        if (button.type == "choice") then
            button:Click()
        end
    end
end

caelQuest.eventFrame:RegisterEvent"QUEST_DETAIL"
caelQuest.eventFrame:RegisterEvent"QUEST_COMPLETE"
caelQuest.eventFrame:RegisterEvent"QUEST_WATCH_UPDATE"
caelQuest.eventFrame:RegisterEvent"QUEST_ACCEPT_CONFIRM"
caelQuest.eventFrame:RegisterEvent"UNIT_QUEST_LOG_CHANGED"
caelQuest.eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "QUEST_WATCH_UPDATE" then
        questIndex = ...
    end

    if event == "UNIT_QUEST_LOG_CHANGED" then
        if questIndex then
            local description, finished, completed = nil, nil, 0

            for objective = 1, GetNumQuestLeaderBoards(questIndex) do
                description, _, finished = GetQuestLogLeaderBoard(objective, questIndex)
                copmpleted = completed + (finished or 0)
            end

            if completed == GetNumQuestLeaderBoards(questIndex) then
                if description then
                    RaidNotice_AddMessage(RaidWarningFrame, string.format("%s Complete", description), ChatTypeInfo["SYSTEM"])
                    PlaySoundFile([[Sound\Creature\Peon\PeonBuildingComplete1.wav]])
                end
            else
                local _, _, itemName, numCurrent, numTotal = strfind(description, "(.*):%s*([%d]+)%s*/%s*([%d]+)")

                if numCurrent == numTotal then
                    RaidNotice_AddMessage(RaidWarningFrame, string.format("%s: Objective Complete", itemName), ChatTypeInfo["SYSTEM"])
                    PlaySoundFile([[Sound\Creature\Peon\PeonReady1.wav]])
                else
                    RaidNotice_AddMessage(RaidWarningFrame, string.format("%s: %s/%s", itemName, numCurrent, numTotal), ChatTypeInfo["SYSTEM"])
                end
            end
        end

        questIndex = nil

    end

    if event == "QUEST_DETAIL" then
        AcceptQuest()
        CompleteQuest()
    elseif event == "QUEST_COMPLETE" then
        if GetNumQuestChoices() and GetNumQuestChoices() < 1 then
            GetQuestReward()
        else
            MostValuable()
        end
    elseif event == "QUEST_ACCEPT_CONFIRM" then
        ConfirmAcceptQuest()
    end

end)

local tags = {Elite = "+", Group = "G", Dungeon = "D", Raid = "R", PvP = "P", Daily = "•", Heroic = "H", Repeatable = "∞"}

local function GetTaggedTitle(i)
    local name, level, tag, group, header, _, complete, daily = GetQuestLogTitle(i)
    if header or not name then return end

    if not group or group == 0 then
        group = nil
    end

    return string.format("[%s%s%s%s] %s", level, tag and tags[tag] or "", daily and tags.Daily or "",group or "", name), tag, daily, complete
end

local QuestLog_Update = function()
    for i, button in pairs(QuestLogScrollFrame.buttons) do
        local QuestIndex = button:GetID()
        local title, tag, daily, complete = GetTaggedTitle(QuestIndex)

        if title then
            button:SetText("  "..title)
        end

        if (tag or daily) and not complete then
            button.tag:SetText("")
        end

        QuestLogTitleButton_Resize(button)
    end
end

hooksecurefunc("QuestLog_Update", QuestLog_Update)
hooksecurefunc(QuestLogScrollFrame, "update", QuestLog_Update)
