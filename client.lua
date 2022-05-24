local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

QBCore = exports['qb-core']:GetCoreObject()

local holdingup = false
local goodnight = false
local initialCooldownSeconds = Rocket.Cooldown
local NuBezig   = false
local zoekRotte = 0
local cooldownSecondsRemaining = Rocket.StartCooldown
local canRob = true


local CopsConnected = 0

RegisterNetEvent('rocket-jachtov:SyncCops')
AddEventHandler('rocket-jachtov:SyncCops', function(amount)
    CopsConnected = amount
end)


RegisterNetEvent('rocket-jachtov:setcooldown')
AddEventHandler('rocket-jachtov:setcooldown', function(time)
	cooldown = time
end)

RegisterNetEvent('rocket-jachtov:teverweg')
AddEventHandler('rocket-jachtov:teverweg', function(robb)
	holdingup = false
    NuBezig = false
    exports['mythic_notify']:DoHudText('error', 'Je was te ver weg en daarom is de overval nu geannuleerd.')
end)

RegisterNetEvent('rocket-jachtov:geslaagd')
AddEventHandler('rocket-jachtov:geslaagd', function(robb)
    holdingup = false
    exports['mythic_notify']:DoHudText('inform', 'Je hebt alles doorzocht dus de jacht is succesvol overvallen')   
    NuBezig = false
--    cooldown = Rocket.Cooldown
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        local pos = GetEntityCoords(GetPlayerPed(-1), true)
        goodnight = true
        for i=1, #Rocket.StartLocation, 1 do
            if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Rocket.StartLocation[i].x, Rocket.StartLocation[i].y, Rocket.StartLocation[i].z, true) < 7 then
                goodnight = false
                DrawMarker(20, vector3(Rocket.StartLocation[i].x, Rocket.StartLocation[i].y, Rocket.StartLocation[i].z), 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.3, 0.3, 0.2, 147, 112, 219, 100, false, true, 2, true, false, false, false)
                if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Rocket.StartLocation[i].x, Rocket.StartLocation[i].y, Rocket.StartLocation[i].z, true) < 2.5 then
                    if cooldownSecondsRemaining <= 0 then
                        DrawScriptText(vector3(Rocket.StartLocation[i].x, Rocket.StartLocation[i].y, Rocket.StartLocation[i].z), '~p~E~w~ · Start Jacht Overval')
                        if IsControlJustReleased(0, Keys["E"]) then
                            QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
                                if result then
                                QBCore.Functions.TriggerCallback('rocket-jachtoverval:getCops', function(CopsConnected)
                                    if CopsConnected >= Rocket.CopsNeeded then
                                        if not NuBezig then
                                            politieMelding()
                                            startoverval()
                                            TriggerServerEvent('rocket-jachtoverval:verwijderitem')
                                            TriggerServerEvent('rocket-jachtoverval:sync')
                                        else
                                        exports['mythic_notify']:DoHudText('error', 'Je bent al bezig met een overval')   
                                        end
                                    else
                                        exports['mythic_notify']:DoHudText('error', 'Er is niet genoeg polisie aanwezig. ('..CopsConnected..'/'..Rocket.CopsNeeded..')')
                                    end
                                end)
                            else
                                exports['mythic_notify']:DoHudText('error', 'Je hebt niet het juiste item bij!')
                            end
                            end, Rocket.Startitem)
                        end
                    else
                        local seconds = cooldownSecondsRemaining
                        DrawScriptText(vector3(Rocket.StartLocation[i].x, Rocket.StartLocation[i].y, Rocket.StartLocation[i].z), 'Overval Cooldown: '..seconds..' sec')
                    end
                else
                    if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Rocket.StartLocation[i].x, Rocket.StartLocation[i].y, Rocket.StartLocation[i].z, true) < 4 then
                        DrawScriptText(vector3(Rocket.StartLocation[i].x, Rocket.StartLocation[i].y, Rocket.StartLocation[i].z), 'Jacht Overval')
                    end
                end
            end
            if goodnight then
                Wait(500)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        local pos = GetEntityCoords(GetPlayerPed(-1), true)
        goodnight = true
        for i,v in pairs(Rocket.StartLocation) do 
            if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z, true) >= 60 and holdingup then
                goodnight = false
                TriggerEvent('rocket-jachtov:teverweg', robb)
            end
            if goodnight then
                Wait(500)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        local pos = GetEntityCoords(GetPlayerPed(-1), true)
        if holdingup then
            drawTxt(5.3, 3.4, 0.45, '~r~ ' .. zoekRotte .. '/' .. Rocket.Maxzoekloc, 185, 185, 185, 255)
            for i,v in pairs(Rocket.Zoeklocaties) do 
                if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z, true) < 5 and not v.isOpen then 
                    DrawMarker(20, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.3, 0.3, 0.2, 147, 112, 219, 100, false, true, 2, true, false, false, false)
                    if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z, true) < 2 and not v.isOpen then 
                        DrawScriptText(vector3(v.x, v.y, v.z), '~p~E~w~ · Zoeken')
                        if IsControlJustReleased(0, Keys["E"]) then
                            --    SetEntityCoords(GetPlayerPed(-1), vector3(v.x, v.y, v.z))
                                SetEntityHeading(GetPlayerPed(-1), v.heading)
                                        Progressbar("zoeken_jacht_overval", "Zoeken..", 13000, false, true, {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                        disableanim = true,
                                        }, {
                                            animDict = "mini@repair",
                                            anim = "fixing_a_ped",
                                        flags = 16,
                                        }, {}, {}, function()
                                            v.isOpen = true 
                                            zoekRotte = zoekRotte + 1
                                            TriggerServerEvent('rocket-jachtov:geefbuit')
                                            if zoekRotte == Rocket.Maxzoekloc then
                                                zoekRotte = 0
                                                TriggerEvent('rocket-jachtov:geslaagd')
                                            end
                                end, function()
                            end)
                        end
                    else
                        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, v.x, v.y, v.z, true) < 3 and not v.isOpen then 
                        DrawScriptText(vector3(v.x, v.y, v.z), 'Zoeken')
                        end
                    end
                end
            end
        end      
    end
end)

function startoverval()
    for i,v in pairs(Rocket.StartLocation) do 
        SetEntityHeading(GetPlayerPed(-1), v.heading)
        Progressbar("zoeken_jacht_overval", "Overvalstarten..", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
            disableanim = true
            }, {
                animDict = "mp_prison_break",
                anim = "hack_loop",
                flags = 16,
            }, {}, {}, function()
            end, function() 
        end)
        exports['mythic_notify']:DoHudText('success', 'Je hebt een overval op de jacht gestart!')
        NuBezig = true
        holdingup = true
    end
end

function DrawScriptText(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords["x"], coords["y"], coords["z"])

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)

    local factor = string.len(text) / 370

    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 65)
end

Citizen.CreateThread(function()
    blipjacht = AddBlipForCoord(-2068.7, -1023.05, 3.06)
    SetBlipSprite (blipjacht, 308)
    SetBlipDisplay(blipjacht, 4)
    SetBlipScale  (blipjacht, 1.0)
    SetBlipColour (blipjacht, 83)
    SetBlipAsShortRange(blipjacht, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Jacht Overval')
    EndTextCommandSetBlipName(blipjacht)
end)

Progressbar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    exports['progressbar']:Progress({
        name = name:lower(),
        duration = duration,
        label = label,
        useWhileDead = useWhileDead,
        canCancel = canCancel,
        controlDisables = disableControls,
        animation = animation,
        prop = prop,
        propTwo = propTwo,
    }, function(cancelled)
        if not cancelled then
            if onFinish ~= nil then
                onFinish()
            end
        else
            if onCancel ~= nil then
                onCancel()
            end
        end
    end)
end

function politieMelding()
    print('d')
    local title = 'Overval'
    local description = 'Er word een Jacht overval gepleegd'
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    local plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
    local streetName, crossing = Citizen.InvokeNative( 0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt() )
    local streetName, crossing = GetStreetNameAtCoord(x, y, z)
    streetName = GetStreetNameFromHashKey(streetName)
    crossing = GetStreetNameFromHashKey(crossing)
    alertData = {
        title = 'Overval',
        description = 'Er word een Jacht overval gepleegd',
        coords = vector3(Rocket.StartLocation[1].x, Rocket.StartLocation[1].y, Rocket.StartLocation[1].z)
    }
      TriggerEvent('qb-phone:client:addPoliceAlert', alertData)
end

RegisterNetEvent('rocket-jachtoverval:clientsync')
AddEventHandler('rocket-jachtoverval:clientsync', function(nigger)
cooldownSecondsRemaining = nigger
end)

Citizen.CreateThread(function()
    while true do
        if cooldownSecondsRemaining > 0 then
            Citizen.Wait(1000)
            cooldownSecondsRemaining = cooldownSecondsRemaining - 1
        else
            Citizen.Wait(500)
        end
    end
end)

drawTxt = function(x, y, scale, text, red, green, blue, alpha)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextScale(0.64, 0.64)
	SetTextColour(red, green, blue, alpha)
	SetTextDropShadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
    DrawText(0.155, 0.935)
end