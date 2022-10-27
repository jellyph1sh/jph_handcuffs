local function SendChatMessage(src, prefix, msg, choosenColor)
    TriggerClientEvent("chat:addMessage", src, {
        args = {
            prefix,
            msg
        },
        color = choosenColor
    })
end

RegisterCommand("handcuff", function(src, args)
    if #args == 0 then
        SendChatMessage(src, "[ERROR]", "Missing arguments!", {255, 0, 0})
    elseif #args > 1 then
        SendChatMessage(src, "[ERROR]", "Too many arguments!", {255, 0, 0})
    elseif GetPlayerPed(args[1]) == 0 then
        SendChatMessage(src, "[ERROR]", "Invalid target id!", {255, 0, 0})
    else
        local targetId = args[1]
        TriggerClientEvent("txp_handcuffs:handcuff", targetId)
    end
end, false)
