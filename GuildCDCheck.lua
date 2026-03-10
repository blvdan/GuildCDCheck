local ADDON_PREFIX = "G_CD_CHECK"
C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)

RAID_DATA_CACHE = {} 
local CURRENT_VIEW = "ALL"
local updateTimer = nil
local L = (GetLocale() == "ruRU") and "ru" or "en"

local function GetRaidID(fullName)
    -- Если имя пустое или база не загружена, молча выходим
    if not fullName or type(fullName) ~= "string" or not GuildCD_RaidIDs then 
        return nil 
    end
    
    for name, id in pairs(GuildCD_RaidIDs) do
        -- Используем pcall или проверку, чтобы find не упал
        if fullName:find(name, 1, true) then 
            return id 
        end
    end
    return nil
end

-- ФУНКЦИЯ СБОРА ДАННЫХ
local function GetMyDataRaw()
    local allData = {}
    local _, class = UnitClass("player")
    local instName, _, _, instDiff = GetInstanceInfo()
    local currentProg = "0/0"
    -- УДАЛИТЕ ИЛИ ЗАКОММЕНТИРУЙТЕ СТРОКУ НИЖЕ (она здесь не нужна)
    -- local rID = GetRaidID(instName) or "UNKNOWN"

    for i = 1, GetNumSavedInstances() do
        local name, _, _, _, locked, _, _, isRaid, _, diff, max, p = GetSavedInstanceInfo(i)
        if name and isRaid and locked then
            -- ОСТАВЬТЕ ОПРЕДЕЛЕНИЕ rID ТОЛЬКО ЗДЕСЬ
            local rID = GetRaidID(name) 
            
            if rID then
                local bStr = ""
                for j = 1, max do
                    local _, _, isK = GetSavedInstanceEncounterInfo(i, j)
                    bStr = bStr .. (isK and "1" or "0")
                end
                table.insert(allData, rID .. ":" .. diff .. ":" .. bStr)
                if name == instName then currentProg = p .. "/" .. max end
            end
        end
    end

    local dataStr = table.concat(allData, "@")
    if #dataStr > 200 then dataStr = dataStr:sub(1, 200) end 

    return class, dataStr, currentProg
end

-- ОКНО АДДОНА
local MainFrame = CreateFrame("Frame", "GuildCDMainFrame", UIParent, "BackdropTemplate")
MainFrame:SetSize(650, 500); MainFrame:SetPoint("CENTER"); MainFrame:Hide()
tinsert(UISpecialFrames, "GuildCDMainFrame")
MainFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" }); MainFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)

local Header = CreateFrame("Frame", nil, MainFrame, "BackdropTemplate")
Header:SetPoint("TOPLEFT", 0, 0); Header:SetPoint("TOPRIGHT", 0, 0); Header:SetHeight(25)
Header:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"}); Header:SetBackdropColor(0.1, 0.1, 0.1, 1)

MainFrame.title = Header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
MainFrame.title:SetPoint("LEFT", 10, 0); MainFrame.title:SetText("GUILD CD MONITOR")

local CloseButton = CreateFrame("Button", nil, Header, "BackdropTemplate")
CloseButton:SetSize(25, 25); CloseButton:SetPoint("RIGHT", 0, 0)
CloseButton:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"}); CloseButton:SetBackdropColor(0.6, 0.2, 0.2, 0.8)
local CloseText = CloseButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
CloseText:SetPoint("CENTER", 0, 0); CloseText:SetText("X")
CloseButton:SetScript("OnClick", function() MainFrame:Hide() end)

MainFrame:SetMovable(true); MainFrame:EnableMouse(true); MainFrame:RegisterForDrag("LeftButton")
MainFrame:SetScript("OnDragStart", MainFrame.StartMoving); MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing)

local function CreateTab(text, xOffset, viewType)
    local btn = CreateFrame("Button", nil, MainFrame, "BackdropTemplate")
    btn:SetSize(140, 25); btn:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", xOffset, -30)
    btn:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"}); btn:SetBackdropColor(0.15, 0.15, 0.15, 1)
    local t = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    t:SetPoint("CENTER"); t:SetText(text)
    btn:SetScript("OnClick", function() CURRENT_VIEW = viewType; MainFrame.Refresh() end)
    return btn
end

local TabCurrent = CreateTab("ТЕКУЩИЙ РЕЙД", 10, "CURRENT")
local TabAll = CreateTab("ВСЕ СОХРАНЕНИЯ", 155, "ALL")
local InfoText = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
InfoText:SetPoint("TOP", 0, -65)

local ScrollFrame = CreateFrame("ScrollFrame", nil, MainFrame, "UIPanelScrollFrameTemplate")
ScrollFrame:SetPoint("TOPLEFT", 10, -95); ScrollFrame:SetPoint("BOTTOMRIGHT", -30, 20)
local Content = CreateFrame("Frame", nil, ScrollFrame)
Content:SetSize(610, 1); ScrollFrame:SetScrollChild(Content)

local rows = {}
local function ClearRows()
    for _, row in ipairs(rows) do row:Hide() end
    rows = {}; MainFrame:SetWidth(650)
end

local function CreateTooltipZone(parent, xOffset, width, rName, bData, pName)
    local zone = CreateFrame("Button", nil, parent)
    zone:SetSize(width, 20); zone:SetPoint("LEFT", parent, "LEFT", xOffset, 0)
    zone:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines()
        GameTooltip:AddLine(pName .. ": " .. rName, 1, 1, 1); GameTooltip:AddLine(" ")
        for bP in string.gmatch(bData, "([^,]+)") do
            local bN, st = bP:match("^(.*)=(.*)$")
            if bN then
                local r, g, b = (st == "1" and 1 or 0.2), (st == "1" and 0.2 or 1), 0.2
                GameTooltip:AddDoubleLine("  "..bN, (st == "1" and "Убит" or "Доступен"), 0.8, 0.8, 0.8, r, g, b)
            end
        end
        GameTooltip:Show()
    end)
    zone:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function AddRow(name, class, mainText, subText, bossData)
    local row = CreateFrame("Frame", nil, Content)
    row:SetSize(Content:GetWidth(), 22); row:SetPoint("TOPLEFT", 10, -#rows * 22)
    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", 0, 0); text:SetJustifyH("LEFT")
    local color = RAID_CLASS_COLORS[class] or {r=0.7, g=0.7, b=0.7} -- Серый для ожидания
    local hex = string.format("ff%02x%02x%02x", color.r*255, color.g*255, color.b*255)
    local fStr = string.format("|c%s%s|r", hex, name)
    if mainText and mainText ~= "" and mainText ~= " " then fStr = fStr .. " [" .. mainText .. "]" end
    text:SetText(fStr .. " ")
    local cX = text:GetStringWidth()
    
    if subText and subText ~= "" then
        print("DEBUG: Получены данные от " .. name .. ": " .. subText)
    end

    if subText and subText ~= "" and CURRENT_VIEW == "ALL" then
        local entries = { strsplit("@", subText) }
        for i, entry in ipairs(entries) do
            local rID, rDiff, bStatus = strsplit(":", entry)
            local db = GuildCD_Database[rID]
            
            if bStatus then
                local dispName = db and db.name or ("ID: " .. rID)
                
                -- 1. Название рейда (Кнопка с тултипом)
                local rT = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                rT:SetPoint("LEFT", row, "LEFT", cX, 0)
                rT:SetText(dispName)
                local nameWidth = rT:GetStringWidth()

                -- Создаем интерактивную зону для тултипа
                local zone = CreateFrame("Button", nil, row)
                zone:SetSize(nameWidth, 20); zone:SetPoint("LEFT", row, "LEFT", cX, 0)
                zone:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:ClearLines()
                    
                    -- Получаем цвет класса для тултипа
                    local c = RAID_CLASS_COLORS[class] or {r=1, g=1, b=1}
                    -- Окрашиваем ник в цвет класса, а остальной заголовок оставляем белым
                    local coloredName = string.format("|cff%02x%02x%02x%s|r", c.r*255, c.g*255, c.b*255, name)
                    
                    GameTooltip:AddLine(coloredName .. ": " .. dispName .. " (" .. rDiff .. ")", 1, 1, 1)
                    GameTooltip:AddLine(" ")

                    for j = 1, #bStatus do
                        local killed = bStatus:sub(j,j) == "1"
                        local bossEntry = db.bosses[j]
                        -- Проверяем, таблица это (новый формат) или строка (старый формат)
                        local bName = type(bossEntry) == "table" and (bossEntry[L] or bossEntry.en) or bossEntry or ("Босс " .. j)
                        local r, g, b = (killed and 1 or 0.2), (killed and 0.2 or 1), 0.2
                        GameTooltip:AddDoubleLine(bName, (killed and "DEAD" or "ALIVE"), 0.8, 0.8, 0.8, r, g, b)
                    end
                    GameTooltip:Show()
                end)
                zone:SetScript("OnLeave", function() GameTooltip:Hide() end)
                
                cX = cX + nameWidth

                -- 2. Сложность (Не интерактивная)
                local dT = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
                dT:SetPoint("LEFT", row, "LEFT", cX, 0)
                dT:SetText(" (" .. rDiff .. ")")
                cX = cX + dT:GetStringWidth()

                if i < #entries then
                    local comma = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    comma:SetPoint("LEFT", row, "LEFT", cX, 0); comma:SetText(", ")
                    cX = cX + comma:GetStringWidth()
                end
            end
        end
    else
        local fT = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fT:SetPoint("LEFT", row, "LEFT", cX, 0); fT:SetText(subText or ""); cX = cX + fT:GetStringWidth()
    end
    table.insert(rows, row)
    if cX + 60 > MainFrame:GetWidth() then MainFrame:SetWidth(cX + 60); Content:SetWidth(cX + 20) end
end

function MainFrame.Refresh()
    ClearRows()
    local myName = UnitName("player")
    local isIn, iType = IsInInstance(); local instN, _, _, instD = GetInstanceInfo()
    if isIn and iType == "raid" then TabCurrent:Show(); TabAll:SetPoint("TOPLEFT", 155, -30)
    else TabCurrent:Hide(); TabAll:SetPoint("TOPLEFT", 10, -30); CURRENT_VIEW = "ALL" end
    TabCurrent:SetBackdropColor(CURRENT_VIEW == "CURRENT" and 0.4 or 0.15, 0.15, 0.15, 1)
    TabAll:SetBackdropColor(CURRENT_VIEW == "ALL" and 0.4 or 0.15, 0.15, 0.15, 1)
    InfoText:SetText((CURRENT_VIEW == "CURRENT" and isIn) and ("|cffffff00"..instN.." ("..instD..")|r") or "Все рейдовые КД группы")
    
    C_ChatInfo.SendAddonMessage(ADDON_PREFIX, (CURRENT_VIEW == "CURRENT" and "!REQ_RAID" or "!REQ_WORLD"), "GUILD")
    
    local players = {}
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do table.insert(players, GetRaidRosterInfo(i)) end
    elseif IsInGroup() then
        table.insert(players, myName)
        for i = 1, GetNumGroupMembers() - 1 do table.insert(players, GetUnitName("party"..i, false)) end
    elseif not IsInGroup() and not IsInRaid() then
        table.insert(players, myName)
        --table.insert(players, "ВасяПал")
        --table.insert(players, "ПетяВар")
        --table.insert(players, "ТестИгрок")
        --table.insert(players, myName .. "-SelfTest")
    end
    if GetNumGroupMembers() > 1 then
        local pref = IsInRaid() and "raid" or "party"
        for i = 1, GetNumGroupMembers() do
            local n = GetUnitName(pref..i, true)
            if n then 
                local shortN = n:match("([^-]+)")
                if shortN ~= myName then table.insert(players, shortN) end
            end
        end
    end

    -- ВРЕМЕННЫЙ ТЕСТОВЫЙ КЭШ
-- RAID_DATA_CACHE["ВасяПал"] = { class = "PALADIN", bosses = "KZ:10:10101010101@MC:1:1111111111", prog = "5/11" }
-- RAID_DATA_CACHE["ПетяВар"] = { class = "WARRIOR", bosses = "BT:25:000000001", prog = "1/9" }

    for _, p in ipairs(players) do
        if p == myName then
            local cl, bs, cp = GetMyDataRaw() -- Возвращает: class, dataStr (битовая маска), currentProg
            RAID_DATA_CACHE[p] = { class = cl, prog = cp, bosses = bs }
        end
        local d = RAID_DATA_CACHE[p]
        if d then
            if CURRENT_VIEW == "CURRENT" and isIn then
                local bL = ""
                local currentID = GetRaidID(instN) -- Получаем ID текущего рейда (напр. "KZ")
                
                -- Ищем данные по текущему рейду в присланной строке ID:Diff:Mask@...
                if d.bosses and d.bosses ~= "" then
                    local entries = { strsplit("@", d.bosses) }
                    for _, entry in ipairs(entries) do
                        local rID, rDiff, bStatus = strsplit(":", entry)
                        if rID == currentID then
                            local db = GuildCD_Database[rID]
                            if db and bStatus then
                                for j = 1, #bStatus do
                                    local killed = bStatus:sub(j,j) == "1"
                                    local bossEntry = db.bosses[j]
                                    local bName = type(bossEntry) == "table" and (bossEntry[L] or bossEntry.en) or bossEntry or ("B"..j)

                                    bL = bL .. (killed and "|cffff4444" or "|cff44ff44") .. bName .. "|r, "
                                end
                            end
                        end
                    end
                end
                AddRow(p, d.class, d.prog, (bL ~= "" and bL:sub(1, -3) or "|cff666666Нет КД|r"), d.bosses)
            else 
                AddRow(p, d.class, nil, d.bosses, d.bosses) 
            end
        else 
            AddRow(p, "PRIEST", "|cff666666Ожидание...|r") 
        end
    end
end

local E = CreateFrame("Frame")
E:RegisterEvent("CHAT_MSG_ADDON"); E:RegisterEvent("GROUP_ROSTER_UPDATE"); E:RegisterEvent("BOSS_KILL")
E:SetScript("OnEvent", function(self, event, prefix, msg, channel, sender)
    if event == "CHAT_MSG_ADDON" and prefix == ADDON_PREFIX then
        local myName = UnitName("player")
        local name = sender:match("([^-]+)")
        
        -- Специальная логика для Self-Test
       -- if name == myName then 
        --    name = name .. "-SelfTest" 
        -- end

        if msg == "!REQ_RAID" or msg == "!REQ_WORLD" then
            local cl, bs, cp = GetMyDataRaw()
            local dataToSend = string.format("!ANS\a%s\a%s\a%s", cl, bs, cp)
            C_ChatInfo.SendAddonMessage(ADDON_PREFIX, dataToSend, "GUILD")
        elseif msg:find("^!ANS\a") then
            local _, cl, bs, cp = strsplit("\a", msg)
            if cl and bs and cp then
                -- Теперь данные запишутся под именем "ВашНик-SelfTest"
                RAID_DATA_CACHE[name] = { class = cl, bosses = bs, prog = cp }
                if MainFrame:IsShown() then MainFrame.Refresh() end
            end
        end
-- ... остальной код ...
    elseif (event == "GROUP_ROSTER_UPDATE" or event == "BOSS_KILL") and MainFrame:IsShown() then
        if updateTimer then updateTimer:Cancel() end
        updateTimer = C_Timer.NewTimer(1.0, function() MainFrame.Refresh() end)
    end
end)

-- КНОПКА МИНИКАРТЫ 6.0
local MiniMapBtn = CreateFrame("Button", "GuildCDMinimapButton", Minimap)
MiniMapBtn:SetSize(32, 32); MiniMapBtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
MiniMapBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_GroupLooking")
MiniMapBtn:SetScript("OnClick", function() 
    if MainFrame:IsShown() then MainFrame:Hide() else 
        CURRENT_VIEW = IsInInstance() and "CURRENT" or "ALL"; MainFrame:Show(); MainFrame.Refresh() 
    end
end)

SLASH_GUILDCD1 = "/checkcd"
SlashCmdList["GUILDCD"] = function() 
    if MainFrame:IsShown() then MainFrame:Hide() else 
        CURRENT_VIEW = IsInInstance() and "CURRENT" or "ALL"; MainFrame:Show(); MainFrame.Refresh() 
    end
end

_G["MainFrame"] = MainFrame