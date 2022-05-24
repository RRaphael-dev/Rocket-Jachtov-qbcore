QBCore = exports['qb-core']:GetCoreObject()

local rob = false
local robbers = {}


QBCore.Functions.CreateCallback("rocket-jachtoverval:getCops", function(source, cb) 

    local Players = QBCore.Functions.GetPlayers()
	CopsConnected = 0

	for i = 1, #Players, 1 do
		local Player = QBCore.Functions.GetPlayer(Players[i])

		if Player.PlayerData.job.name  == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end

	cb(CopsConnected)
	SetTimeout(120 * 1000, CountCops)
end)

QBCore.Functions.CreateCallback('rocket-jachtoverval:getitem', function(source, cb, item)
	local Player = QBCore.Functions.GetPlayer(source)
		local items = Player.Functions.GetItemByName(item)
		if item == 1 then
			cb(0)
		else
			cb(items.count)
	end
end)

QBCore.Functions.CreateUseableItem(Rocket.Startitem, function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemByName(Rocket.Startitem) ~= nil then
        TriggerClientEvent("rocket-jactoverval:GebruikSleutel", source)
    else
        TriggerClientEvent('QBCore:Notify', source, "You're missing ignition source ", "error")
    end
end)

RegisterServerEvent('rocket-jachtoverval:sync')
AddEventHandler('rocket-jachtoverval:sync', function()
	TriggerClientEvent('rocket-jachtoverval:clientsync', -1, Rocket.Cooldown)
end)

RegisterServerEvent('rocket-jachtov:teverweg')
AddEventHandler('rocket-jachtov:teverweg', function()
	local source = source
	local Players = QBCore.Functions.GetPlayers()
	rob = false
	for i=1, #Players, 1 do
		local Player = QBCore.Functions.GetPlayer(Players[i])
		if Player.job.name == 'police' then
			TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'De overval op de jacht is gestopt'})
		end
	end
	if(robbers[source])then
		TriggerClientEvent('rocket-jachtov:teverweg')
		robbers[source] = nil
	end
end)

RegisterServerEvent('rocket-jachtoverval:verwijderitem')
AddEventHandler('rocket-jachtoverval:verwijderitem', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(source)
	local item = Rocket.Startitem
	local hasitem = Player.Functions.GetItemByName(item).count

	Player.Functions.RemoveItem(item, 1)
end)

RegisterServerEvent('rocket-jachtov:beeindigoverval')
AddEventHandler('rocket-jachtov:beeindigoverval', function(robb)
	local source = source
	local Players = QBCore.Functions.GetPlayers()
	rob = false
	for i=1, #Players, 1 do
 		local Player = QBCore.Functions.GetPlayer(Players[i])
 		if Player.job.name == 'police' then
			TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'De overval op de jacht is succesvol gelukt'})
		end
	end
	if(robbers[source])then
		TriggerClientEvent('rocket-jachtov:geslaagd', source)
		robbers[source] = nil
	end
end)

RegisterServerEvent('rocket-jachtov:geefbuit')
AddEventHandler('rocket-jachtov:geefbuit', function(geld)
	local src = source
	local Player = QBCore.Functions.GetPlayer(source)
	local geld = Rocket.Buit

	Player.Functions.AddMoney('cash', geld, "Jacht Overval")
	TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'Je hebt '..geld..' euro gevonden'})
end)