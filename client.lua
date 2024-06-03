-----------------------------------------------------------------------------------
local target = exports.ox_target
local jobStation, jobVehicle, jobItems, isHolding = nil
local entities = {}
-----------------------------------------------------------------------------------

-- Create blips
CreateThread(function()
	for k,v in pairs(Config.DeliveryStations) do
        if v.Blip.blipToggle == true then
            local title = tostring(v.Blip.blipLabel)
            local blip = AddBlipForCoord(v.Blip.blipCoords)

            SetBlipDisplay(blip, 6)
            SetBlipSprite(blip, v.Blip.blipID)
            SetBlipScale(blip, v.Blip.blipScale)
            SetBlipColour(blip, v.Blip.blipColor)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(title)
            EndTextCommandSetBlipName(blip)
        end
	end
end)

-- Create Peds
CreateThread(function()
    for k,v in pairs(Config.StarterPeds.Supervisors) do
        local modelHash = GetHashKey(v.pedModel)
        local heading = type(v.pedCoords) == 'vector4' and v.pedCoords.w or v.pedCoords.h
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(1)
        end

        local ped = CreatePed(4, modelHash, v.pedCoords.x, v.pedCoords.y, v.pedCoords.z, heading, false, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        TaskStartScenarioInPlace(ped, v.pedAnims, 0, 0)
    end
end)

-- Create Entity
CreateBox = function(entity, coords, timer)
    CreateThread(function()
        local entityID = #entities+1
        ESX.Game.SpawnLocalObject(entity, vector3(coords.x, coords.y, coords.z-0.5), function(object)
            local ms = 3
            entities[entityID] = object
            while DoesEntityExist(object) do
                local ped = GetPlayerPed(-1)
                local coords = GetEntityCoords(ped)
                local loc = GetEntityCoords(object)
                if GetDistanceBetweenCoords(coords, loc) <= 1.5 then
                    ms = 3
                    ESX.Game.Utils.DrawText3D(vector3(loc.x, loc.y, loc.z+0.5), '[E] Steal box', 0.5)
                else
                    ms = 3000
                end
                Wait(ms)
            end
        end)
        Wait(timer)
        ESX.Game.DeleteObject(entities[entityID])
    end)
end

CreateThread(function()
    if not Config.ox_target then
    else
        for k,v in pairs(Config.StarterPeds.Supervisors) do
            target:addModel(v.pedModel, {
                {
                    name = 'open_menu',
                    event = 'chao-delivery:createMenu',
                    icon = 'fa fa-postal',
                    label = 'Postal Station',
                    canInteract = function(entity)
                        return true
                    end
                }
            })
        end
    end
end)

RegisterNetEvent('chao-delivery:createMenu', function()
    lib.registerContext({
        id = 'postal_menu',
        title = 'Postal Station',
        options = {
            {
                title = "Start a delivery job",
                description = "Deliver packages to houses",
                arrow = false,
                event = 'chao-delivery:startJob',
            },
            {
                title = "Get a truck",
                description = "Spawns a delivery truck from garage",
                arrow = true,
                event = 'chao-delivery:getVehicle',
            },
        },
    })
    lib.showContext('postal_menu')
end)

AddEventHandler('chao-delivery:startJob', function()
    if jobVehicle then
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped)

        for k,v in pairs(Config.DeliveryStations) do
            if not jobStation then jobStation = v else
                if GetDistanceBetweenCoords(coords, v.SpawnPoint.coords) < GetDistanceBetweenCoords(coords, jobStation.SpawnPoint.coords) then
                    jobStation = v
                end
            end
        end

        if jobStation then
            local title = 'Collect packages'
            local blip = AddBlipForCoord(jobStation.JobPoint.coords)

            SetBlipDisplay(blip, 6)
            SetBlipSprite(blip, jobStation.JobPoint.blip)
            SetBlipColour(blip, 5)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(title)
            EndTextCommandSetBlipName(blip)
            -----------------------------------------
            SetVehicleDoorOpen(jobVehicle, GetEntityBoneIndexByName(jobVehicle, 'door_dside_r'), false, true)
            SetVehicleDoorOpen(jobVehicle, GetEntityBoneIndexByName(jobVehicle, 'door_dside_l'), false, true)

            CreateThread(function()
                while true do
                    if jobItems == #jobStation.Jobs then
                        RemoveBlip(blip)
                        StartDelivery(jobItems)
                        break
                    else
                        trunk = GetWorldPositionOfEntityBone(jobVehicle, GetEntityBoneIndexByName(jobVehicle, 'door_dside_r'))
                        coords = GetEntityCoords(ped)
                        if GetDistanceBetweenCoords(coords, jobStation.JobPoint.coords) <= 1.5 then
                            DrawMarker(jobStation.JobPoint.marker, jobStation.JobPoint.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 255, 255, 155, 0, 0, 0, 1, 0, 0, 0)
                            if IsControlJustPressed(0, 38) and not isHolding then
                                isHolding = true
                                exports['dpemotes']:EmoteCommandStart(ped, {'box'})
                            end
                        elseif GetDistanceBetweenCoords(coords, trunk) <= 1.5 then
                            DrawMarker(jobStation.JobPoint.marker, trunk, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 255, 255, 155, 0, 0, 0, 1, 0, 0, 0)
                            if IsControlJustPressed(0, 38) and isHolding then
                                isHolding = false
                                if not jobItems then jobItems = 1 else jobItems = jobItems + 1 end
                                ESX.ShowNotification(jobItems..'/'..#jobStation.Jobs)
                                exports['dpemotes']:EmoteCommandStart(ped, {'cancel'})
                            end
                        end
                    end
                    Wait(3)
                end
            end)
        end
    else
        ESX.ShowNotification('You do not have a job vehicle', nil, 'error')
    end
end)

StartDelivery = function(items)
    local ped = GetPlayerPed(-1)
    local delivery = Config.DeliveryPoints[math.random(#Config.DeliveryPoints)]

        local title = 'Deliver package'
        local blip = AddBlipForCoord(delivery)

        SetBlipDisplay(blip, 6)
        SetBlipSprite(blip, 478)
        SetBlipColour(blip, 5)
        SetBlipRoute(blip, true)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(title)
        EndTextCommandSetBlipName(blip)
        
    CreateThread(function()
        local ms = 3
        while DoesEntityExist(jobVehicle) do
            local coords = GetEntityCoords(ped)

            if not IsPedInVehicle(ped, jobVehicle) and GetDistanceBetweenCoords(coords, delivery) <= 25.0 then
                ms = 3
                trunk = GetWorldPositionOfEntityBone(jobVehicle, GetEntityBoneIndexByName(jobVehicle, 'door_dside_r'))

                if isHolding and GetDistanceBetweenCoords(coords, delivery) <= 1.5 then
                    DrawMarker(2, delivery, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 255, 255, 155, 0, 0, 0, 1, 0, 0, 0)
                    if IsControlJustPressed(0, 38) then
                        isHolding = false
                        CreateBox('hei_prop_heist_box', coords, 1*60*1000)
                        exports['dpemotes']:EmoteCommandStart(ped, {'cancel'})

                        jobItems = jobItems - 1
                        if not delivered then delivered = 1 else delivered = delivered + 1 end
                        if jobItems == 0 then
                            delivered = 0
                            RemoveBlip(blip)
                            EndDelivery(delivered)
                            break
                        else
                            ESX.ShowNotification(delivered..'/'..items..' packages delivered.')
                            delivery = Config.DeliveryPoints[math.random(#Config.DeliveryPoints)]

                            RemoveBlip(blip)
                            blip = AddBlipForCoord(delivery)

                            SetBlipDisplay(blip, 6)
                            SetBlipSprite(blip, 478)
                            SetBlipColour(blip, 5)
                            SetBlipRoute(blip, true)
                            SetBlipAsShortRange(blip, true)

                            BeginTextCommandSetBlipName('STRING')
                            AddTextComponentString(title)
                            EndTextCommandSetBlipName(blip)
                        end
                    end
                elseif GetDistanceBetweenCoords(coords, trunk) <= 1.5 then
                    DrawMarker(2, trunk, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 255, 255, 155, 0, 0, 0, 1, 0, 0, 0)
                    if IsControlJustPressed(0, 38) and not isHolding then
                        SetVehicleDoorOpen(jobVehicle, GetEntityBoneIndexByName(jobVehicle, 'door_dside_r'), false, true)
                        SetVehicleDoorOpen(jobVehicle, GetEntityBoneIndexByName(jobVehicle, 'door_dside_l'), false, true)

                        isHolding = true
                        exports['dpemotes']:EmoteCommandStart(ped, {'box'})

                        Wait(500)
                        SetVehicleDoorShut(jobVehicle, GetEntityBoneIndexByName(jobVehicle, 'door_dside_r'), false)
                        SetVehicleDoorShut(jobVehicle, GetEntityBoneIndexByName(jobVehicle, 'door_dside_l'), false)
                    end
                end
            elseif not IsPedInVehicle(ped, jobVehicle) and GetDistanceBetweenCoords(coords, delivery) > 25.0 then
                ESX.ShowNotification('You must return to your vehicle to complete the job.')
                ms = 10000
            end

            Wait(ms)
        end
    end)
end

EndDelivery = function(items)
    local ped = GetPlayerPed(-1)
    ESX.ShowNotification('You have delivered all your packages, congratulations.', 'success', 4500)
    ESX.ShowNotification('You must now deliver your vehicle back to the station', 'success', 6500)

    local title = 'Deliver vehicle'
    local blip = AddBlipForCoord(jobStation.SpawnPoint.coords)

    SetBlipDisplay(blip, 6)
    SetBlipSprite(blip, 479)
    SetBlipColour(blip, 5)
    SetBlipRoute(blip, true)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(title)
    EndTextCommandSetBlipName(blip)

    CreateThread(function()
        local ms = 3
        while DoesEntityExist(jobVehicle) do
            local coords = GetEntityCoords(ped)
            if not IsPedInVehicle(ped, jobVehicle) and GetDistanceBetweenCoords(coords, jobStation.SpawnPoint.coords) > 25.0 then
                ESX.ShowNotification('You must return to your vehicle and deliver it to receive your pay.')
                ms = 10000
            elseif GetDistanceBetweenCoords(coords, jobStation.SpawnPoint.coords) <= 15.0 then
                ms = 3
                DrawMarker(2, jobStation.SpawnPoint.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.50, 0.4, 0.2, 255, 255, 255, 155, 0, 0, 0, 1, 0, 0, 0)
                if GetDistanceBetweenCoords(coords, jobStation.SpawnPoint.coords) <= 1.5 and IsControlJustPressed(0, 38) then
                    TaskEveryoneLeaveVehicle(jobVehicle)
                    Wait(1000)
                    RemoveBlip(blip)
                    TriggerServerEvent('chao-delivery:finish', items)
                    DeleteVehicle(jobVehicle)
                end
            end
            Wait(ms)
        end
    end)
end

AddEventHandler('chao-delivery:getVehicle', function()
    if not jobVehicle then
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped)
        local closest = nil

        for k,v in pairs(Config.DeliveryStations) do
            if not closest then closest = v else
                if GetDistanceBetweenCoords(coords, v.SpawnPoint.coords) < GetDistanceBetweenCoords(coords, Config.DeliveryStations[closest].SpawnPoint.coords) then
                    closest = v
                end
            end
        end

        if closest then
            ESX.Game.SpawnVehicle(closest.Vehicle, closest.SpawnPoint.coords, closest.SpawnPoint.heading, function(vehicle)
                jobVehicle = vehicle
            end)
        end
    else
        ESX.ShowNotification('You already have a job vehicle', nil, 'error')
    end
end)