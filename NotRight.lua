local function IsSecret(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

local function ContainsYeahRight(message)
    if IsSecret(message) or type(message) ~= "string" then
        return false
    end

    -- Same matching as YeahRight: case-insensitive, ignores punctuation and
    -- spacing, and catches the joined "yeahright" but not "yeahrightly".
    local normalized = string.lower(message)
    normalized = string.gsub(normalized, "[^%w]+", " ")
    normalized = " " .. normalized .. " "

    return string.find(normalized, "%syeah%s*right%s") ~= nil
end

local function FilterGuildMessage(chatFrame, event, message, ...)
    -- Returning true hides the message from the chat frame.
    return ContainsYeahRight(message)
end

local REPLY_EVERY = 1000

-- Counted from the event rather than the filter, because filters run once per
-- chat frame that shows guild chat.
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_GUILD")
frame:SetScript("OnEvent", function(self, event, message)
    if event == "ADDON_LOADED" then
        if message == "NotRight" then
            NotRightDB = NotRightDB or {}
            NotRightDB.count = NotRightDB.count or 0
        end
        return
    end

    if not NotRightDB or not ContainsYeahRight(message) then
        return
    end

    NotRightDB.count = NotRightDB.count + 1
    if NotRightDB.count % REPLY_EVERY ~= 0 then
        return
    end

    local send = C_ChatInfo and C_ChatInfo.SendChatMessage
    if type(securecallfunction) == "function" then
        securecallfunction(send, "yeah right", "GUILD")
    else
        send("yeah right", "GUILD")
    end
end)

local addFilter = (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter)
    or ChatFrame_AddMessageEventFilter
addFilter("CHAT_MSG_GUILD", FilterGuildMessage)
