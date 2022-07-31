local QBCore, territories = exports['qb-core']:GetCoreObject(), {}

CreateThread(function()
    MySQL.query('SELECT * FROM tomic_territories', {}, function(data)
        if data then
            territories = {}
            for i = 1, #data, 1 do
                table.insert(territories, {id = data[i].id, name = data[i].name, owner = data[i].owner, radius = data[i].radius, label = data[i].label, type = data[i].type, coords = json.decode(data[i].coords), isTaking = false, progress = 0, cooldown = false, spawnano = false, radi = false} )
                -- exports.ox_inventory:RegisterStash('devTomic-Ter['..data[i].name..']['..data[i].id..']', 'devTomic | Territory: '..data[i].name, 50, 100000)
                -- print('devTomic | Registered stash: devTomic-'..data[i].id..' | Territory: '..data[i].name..'')
            end
        end
    end)
end)

QBCore.Functions.CreateCallback('tomic_territories:getTerritories', function(source, cb)
	cb(territories)
end)

if shared.rankings then
    -- QBCore.Functions.CreateCallback('tomic_territories:povucipoene', function(source, cb)
    --     MySQL.query('SELECT * FROM management_funds', {}, function(poeni)
    --         if poeni then
    --             cb(poeni)
    --         end
    --     end)
    -- end)
end

-- command to create
RegisterCommand(shared.command, function(source, args)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if source == 0 then
        return print('devTomic | Command can only be used in-game!')
    end
    if QBCore.Functions.HasPermission(source, shared.group) then
        if args[1] == 'create' then
            TriggerClientEvent('tomic_territories:createTerritory', source)
        elseif args[1] == 'delete' then
            TriggerClientEvent('tomic_territories:deleteTerritory', source)
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "devTomic | You are not allowed to use this command!")
    end
end)

RegisterNetEvent('tomic_territories:createTerritory')
AddEventHandler('tomic_territories:createTerritory', function(territoryInfo)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local territory = {
        id = #territories + 1,
        name = territoryInfo.name,
        owner = 'noone',
        radius = territoryInfo.radius,
        label = 'NoOne',
        type = territoryInfo.type,
        coords = json.encode({x = territoryInfo.coords.x, y = territoryInfo.coords.y, z = territoryInfo.coords.z}),
        isTaking = false,
        progress = 0,
        cooldown = false,
        spawnano = false,
        radi = false
    }
    MySQL.Async.execute('INSERT INTO tomic_territories (id, name, type, coords, radius) VALUES (@id, @name, @type, @coords, @radius)', {
        ['@id'] = territory.id,
        ['@name'] = territory.name,
        ['@type'] = territory.type,
        ['@radius'] = territory.radius,
        ['@coords'] = territory.coords,
    }, function(rowsChanged)
        if rowsChanged > 0 then
            table.insert(territories, {
                id = #territories + 1,
                name = territoryInfo.name,
                owner = 'noone',
                radius = territoryInfo.radius,
                label = 'NoOne',
                type = territoryInfo.type,
                coords = json.decode(territory.coords),
                isTaking = false,
                progress = 0,
                cooldown = false,
                spawnano = false,
                radi = false
            })
            -- exports.ox_inventory:RegisterStash('devTomic-Ter['..territory.name..']['..territory.id..']', 'devTomic | Territory: '..territory.name, 50, 100000)
        end
    end)
    Wait(500)
    TriggerClientEvent('tomic_territories:updateTerritories', -1, territories)
    TriggerClientEvent('QBCore:Notify', source, 'devTomic | Territory created!')
end)

RegisterNetEvent('tomic_territories:deleteTerritory')
AddEventHandler('tomic_territories:deleteTerritory', function(territoryName)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    MySQL.Async.execute('DELETE FROM tomic_territories WHERE name = @name', {
        ['@name'] = territoryName,
    }, function(rowsChanged)
        if rowsChanged > 0 then
            for i = 1, #territories, 1 do
                if territories[i].name == territoryName then
                    table.remove(territories, i)
                    break
                end
            end
            Wait(500)
            TriggerClientEvent('tomic_territories:updateTerritories', -1, territories)
            TriggerClientEvent('QBCore:Notify', source, 'devTomic | Territory deleted!')
        end
    end)
end)

RegisterNetEvent('tomic_territories:capturestart')
AddEventHandler('tomic_territories:capturestart', function(id, job, label, name, currentOwner)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    local xPlayers = QBCore.Functions.GetPlayers()
    local vrijeme = os.date('%H')
    for i = 1, #xPlayers, 1 do
        local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])
        if xPlayer.PlayerData.gang.name == currentOwner then
            TriggerClientEvent('QBCore:Notify', source, 'devTomic | Territory: '..name..' is being attacked by another gang!')
        end
        if xPlayer.PlayerData.gang.name == job then
            TriggerClientEvent('QBCore:Notify', source, 'devTomic | Your gang started attacking territory '..name..'!')
        end
    end

    for k, v in pairs(territories) do
        if v.id == id then
            v.isTaking = true
            v.cooldown = true
            datakey = k
            data = territories[k]
            TriggerClientEvent('tomic_territories:updateTerritories', -1, territories)
            TriggerClientEvent('tomic_territories:blipblink', -1, id, job, label)
            TriggerClientEvent('tomic_territories:captureprogress', source, datakey, data)
            print(GetPlayerName(source)..' started capturing: '..name)
        end
    end
end)

RegisterNetEvent('tomic_territories:MethServer')
AddEventHandler('tomic_territories:MethServer', function(infoX, vozilo)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    voziloInfo = vozilo
    for i, v in pairs(territories) do
        if v.id == infoX.data.id then
            v.spawnano = true
            v.radi = true
            TriggerClientEvent('tomic_territories:updateTerritories', -1, territories)
            TriggerClientEvent('tomic_territories:MethClient', source, voziloInfo)
        end
    end
end)

RegisterNetEvent('tomic_territories:sellDealer')
AddEventHandler('tomic_territories:sellDealer', function(allInfo)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    amountx = allInfo.xWorth * allInfo.xCount
    local ix = QBCore.Functions.HasItem(allInfo.i)
    if ix and xPlayer.Functions.GetItemByName(allInfo.i).amount >= allInfo.xCount then
        if allInfo.xType == true then
            xPlayer.Functions.RemoveItem(allInfo.i, allInfo.xCount)
            xPlayer.Functions.AddMoney('crypto', tonumber(amountx))
        else
            xPlayer.Functions.RemoveItem(allInfo.i, allInfo.xCount)
            xPlayer.Functions.AddMoney('cash', tonumber(amountx))
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'devTomic | You do not have that amount!')
    end
end)

RegisterNetEvent('tomic_territories:buyMarket')
AddEventHandler('tomic_territories:buyMarket', function(allInfo)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    amountx = allInfo.xWorth * allInfo.xCount
    if allInfo.xType == true then
        if xPlayer.PlayerData.money["crypto"] >= allInfo.xWorth then
            xPlayer.Functions.RemoveMoney('crypto', tonumber(amountx))
            xPlayer.Functions.AddItem(allInfo.i, allInfo.xCount)
        else
            TriggerClientEvent('QBCore:Notify', source, 'devTomic | You do not have enough crypto!')
        end
    else
        if xPlayer.PlayerData.money["cash"] >= allInfo.xWorth then
            xPlayer.Functions.RemoveMoney('cash', tonumber(amountx))
            xPlayer.Functions.AddItem(allInfo.i, allInfo.xCount)
        else
            TriggerClientEvent('QBCore:Notify', source, 'devTomic | You do not have enough money!')
        end
    end
end)

-- not working, but keep it.. xd (you can remove it if you want.. this was just for testing, it is not in use)
-- RegisterNetEvent('tomic_territories:captureprogress')
-- AddEventHandler('tomic_territories:captureprogress', function(id)
--     for i, v in pairs(territories) do
--         if v.id == id then
--             TriggerClientEvent('tomic_territories:updateTerritories', -1, territories)
--             TriggerClientEvent('tomic_territories:captureprogress', source)
--             if v.progress == 100 then
--                 v.isTaking = false
--                 MySQL.query('UPDATE tomic_territories SET owner = @owner WHERE id = @id', {id = id, owner = v.owner})
--                 TriggerClientEvent('tomic_territories:updateTerritories', -1, territories)
--             end
--         end
--     end
-- end)

RegisterNetEvent('tomic_territories:capturecomplete')
AddEventHandler('tomic_territories:capturecomplete', function(id, job, label, prvivlasnik)
    for i, v in pairs(territories) do
        if v.id == id then
            v.isTaking = false
            v.owner = job
            v.label = label
            tername = v.name
            MySQL.query('UPDATE tomic_territories SET owner = ? WHERE id = ?', {job, id})
            MySQL.query('UPDATE tomic_territories SET label = ? WHERE id = ?', {label, id})
            if shared.rewards.on then
                TriggerEvent('tomic_territories:reward', job, tername)
            end
            if shared.rankings then
                ---------------------------------------------------------------------------------------------------------
                -- MySQL.query('SELECT * FROM management_funds WHERE name = @name', { ['@name'] = prvivlasnik }, function(x)
                --     if x then
                --         local poeni = x[1].poeni
                --         novostanje = poeni - 2
                --         MySQL.query('UPDATE management_funds SET nedpoeni = @poeni WHERE name = @name', { ['@name'] = prvivlasnik, ['@poeni'] = novostanje })
                --         MySQL.query('UPDATE management_funds SET mespoeni = @poeni WHERE name = @name', { ['@name'] = prvivlasnik, ['@poeni'] = novostanje })
                --     end
                -- end)
                ---------------------------------------------------------------------------------------------------------
                -- MySQL.query('SELECT * FROM management_funds WHERE name = @name', { ['@name'] = job }, function(x)
                --     if x then
                --         local poeni = x[1].poeni
                --         novostanje = poeni + 3
                --         MySQL.query('UPDATE management_funds SET poeni = @poeni WHERE name = @name', { ['@name'] = job, ['@poeni'] = novostanje })
                --         MySQL.query('UPDATE management_funds SET nedpoeni = @x WHERE name = @name', { ['@name'] = job, ['@x'] = novostanje })
                --         MySQL.query('UPDATE management_funds SET mespoeni = @y WHERE name = @name', { ['@name'] = job, ['@y'] = novostanje })
                --     end
                -- end)
                ---------------------------------------------------------------------------------------------------------
            end
            TriggerClientEvent('tomic_territories:updateTerritories', -1, territories)
            Wait(shared.cooldown * 60000)
            v.cooldown = false
            TriggerClientEvent('tomic_territories:updateTerritories', -1, territories)
        end
    end
end)

RegisterNetEvent('tomic_territories:reward')
AddEventHandler('tomic_territories:reward', function(job, tername)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    local xPlayers = QBCore.Functions.GetPlayers()
    for i = 1, #xPlayers, 1 do
        local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])
        if xPlayer.PlayerData.gang.name == job then
            xPlayer.Functions.AddItem(shared.rewards.item, shared.rewards.count)
            TriggerClientEvent('QBCore:Notify', source, 'devTomic | You got $'..shared.rewards.count..' as a reward for capturing: '..tername..'!')
        end
    end
end)

RegisterNetEvent('tomic_territories:updateTerritories')
AddEventHandler('tomic_territories:updateTerritories', function(territories)
    for i, v in pairs(territories) do
        TriggerClientEvent('tomic_territories:updateTerritories', -1, territories)
    end
end)

RegisterNetEvent('tomic_territories:captureend')
AddEventHandler('tomic_territories:captureend', function(id)
    for i, v in pairs(territories) do
        if v.id == id then
            v.isTaking = false
            TriggerClientEvent('tomic_territories:updateTerritories', -1, territories)
            Wait(shared.cooldown * 60000)
            v.cooldown = false
            TriggerClientEvent('tomic_territories:updateTerritories', -1, territories)
        end
    end
end)

if shared.rankings then
    function Resetuj(d, h, m)
        if d == 1 then
            -- MySQL.query('UPDATE management_funds SET nedpoeni = @x', { ['@x'] = 0 })
        end
    end

    TriggerEvent('cron:runAt', 06, 00, Resetuj)
end