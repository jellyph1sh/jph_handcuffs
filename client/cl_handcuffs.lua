local isHandcuff, propsId = false, {}

local function IsHandcuffed(player)
    if isHandcuff then
        return true
    end
    return false
end

local function DisableControlActions(player, disableActions)
    Citizen.CreateThread(function()
        while IsHandcuffed(player) do
            for i, action in pairs(disableActions) do
                DisableControlAction(2, action, true)
            end
            Citizen.Wait(0)
        end
    end)
end

local function LoadAnimDict(dict)
    if not DoesAnimDictExist(dict) then
        return false
    end
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(25)
    end
    return true
end

local function LoadModel(model)
    local hash = GetHashKey(model)
    if not IsModelInCdimage(hash) then
        return false
    end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(250)
    end
    return hash
end

local function AddPropToPlayer(prop, player)
    local x, y, z = table.unpack(GetEntityCoords(player))
    local hash = LoadModel(prop)
    if not hash then
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = false,
            args = {"[ERROR]", "Invalid prop model!"}
        })
    else
        objProp = CreateObject(hash, x, y, z + 0.2, true, true, true)
        table.insert(propsId, objProp)
        AttachEntityToEntity(objProp, player, GetPedBoneIndex(player, 0xEEEB), 0.3, 0.04, 0.04, -25.0, 125.0, 140.0, true, true, false, true, 1, true)
        SetModelAsNoLongerNeeded(hash)
    end
end

local function SetHandcuffAnim(player)
    isLoaded = LoadAnimDict(Config.AnimDict)
    if not isLoaded then
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = false,
            args = {"[ERROR]", "Invalid anim dict!"}
        })
    else
        TaskPlayAnim(player, Config.AnimDict, Config.HandcuffAnim, 2.0, 2.0, -1, 51, 0, false, false, false)
        RemoveAnimDict(Config.AnimDict)
        AddPropToPlayer(Config.HandcuffsProp, PlayerPedId())
    end
end

local function DeleteProps(props)
    for i, id in pairs(props) do
        DeleteEntity(id)
    end
    props = {}
    return props
end

RegisterNetEvent("txp_handcuffs:handcuff")
AddEventHandler("txp_handcuffs:handcuff", function()
    local player = GetPlayerPed(-1)
    if IsHandcuffed(player) then
        ClearPedTasks(player)
        propsId = DeleteProps(propsId)
    else
        SetHandcuffAnim(player)
        DisableControlActions(player, Config.DisableActions)
    end
    isHandcuff = not isHandcuff
    SetEnableHandcuffs(player, isHandcuff)
end)

TriggerEvent('chat:addSuggestion', '/handcuff', 'Handcuff target player.', {{ name="Target ID", help="Target player ID" }})
