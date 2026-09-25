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

local addFilter = (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter)
    or ChatFrame_AddMessageEventFilter
addFilter("CHAT_MSG_GUILD", FilterGuildMessage)
