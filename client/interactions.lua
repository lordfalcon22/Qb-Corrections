CreateThread(function()
    for k, v in pairs(Config.Locations["duty"]) do
        exports['qb-target']:AddBoxZone("CorrectionsDuty_"..k, vector3(v.x, v.y, v.z), 1, 1, {
            name = "CorrectionsDuty_"..k,
            heading = 11,
            debugPoly = true,
            minZ = v.z - 1,
            maxZ = v.z + 1,
        }, {
            options = {
                {
                    type = "client",
                    event = "qb-corrections:ToggleDuty",
                    icon = "fas fa-sign-in-alt",
                    label = "Sign In",
                    job = "corrections",
                },
            },
            distance = 1.5
        })
    end
end)

CreateThread(function()
    local evidenceZones = {}
    for _, v in pairs(Config.Locations["evidence"]) do
        evidenceZones[#evidenceZones+1] = BoxZone:Create(
            vector3(vector3(v.x, v.y, v.z)), 2, 1, {
            name="box_zone",
            debugPoly = true,
            minZ = v.z - 1,
            maxZ = v.z + 1,
        })
    end

    local evidenceCombo = ComboZone:Create(evidenceZones, {name = "evidenceCombo", debugPoly = true})
    evidenceCombo:onPlayerInOut(function(isPointInside)
        if isPointInside then
            if PlayerJob.name == 'corrections' and onDuty then
                local currentEvidence = 0
                local pos = GetEntityCoords(PlayerPedId())

                for k, v in pairs(Config.Locations["evidence"]) do
                    if #(pos - v) < 2 then
                        currentEvidence = k
                    end
                end
                exports['qb-menu']:showHeader({
                    {
                        header = 'Prisoner Storage', {value = currentEvidence},
                        params = {
                            event = 'corrections:client:EvidenceStashDrawer',
                            args = {
                                currentEvidence = currentEvidence
                            }
                        }
                    }
                })
            end
        else
            exports['qb-menu']:closeMenu()
        end
    end)

    local stashZones = {}
    for _, v in pairs(Config.Locations["stash"]) do
        stashZones[#stashZones+1] = BoxZone:Create(
            vector3(vector3(v.x, v.y, v.z)), 1.5, 1.5, {
            name="box_zone",
            debugPoly = true,
            minZ = v.z - 1,
            maxZ = v.z + 1,
        })
    end

    local stashCombo = ComboZone:Create(stashZones, {name = "stashCombo", debugPoly = true})
    stashCombo:onPlayerInOut(function(isPointInside, _, _)
        if isPointInside then
            inStash = true
            exports['qb-core']:DrawText('[E] Stash Enter', 'left')
            stash()
        else
            exports['qb-core']:HideText()
            inStash = false
        end
    end)

    local trashZones = {}
    for _, v in pairs(Config.Locations["trash"]) do
        trashZones[#trashZones+1] = BoxZone:Create(
            vector3(vector3(v.x, v.y, v.z)), 1, 1.75, {
            name="box_zone",
            debugPoly = true,
            minZ = v.z - 1,
            maxZ = v.z + 1,
        })
    end

    local trashCombo = ComboZone:Create(trashZones, {name = "trashCombo", debugPoly = true})
    trashCombo:onPlayerInOut(function(isPointInside)
        if isPointInside then
            inTrash = true
            if onDuty then
                exports['qb-core']:DrawText('[E] Trash Bin','left')
                trash()
            end
        else
            inTrash = false
            exports['qb-core']:HideText()
        end
    end)

    local armouryZones = {}
    for _, v in pairs(Config.Locations["armory"]) do
        armouryZones[#armouryZones+1] = BoxZone:Create(
            vector3(vector3(v.x, v.y, v.z)), 5, 1, {
            name="box_zone",
            debugPoly = true,
            minZ = v.z - 1,
            maxZ = v.z + 1,
        })
    end

    local armouryCombo = ComboZone:Create(armouryZones, {name = "armouryCombo", debugPoly = true})
    armouryCombo:onPlayerInOut(function(isPointInside)
        if isPointInside then
            inAmoury = true
            if onDuty then
                exports['qb-core']:DrawText('[E] Armoury','left')
                armoury()
            end
        else
            inAmoury = false
            exports['qb-core']:HideText()
        end
    end)

    local garageZones = {}
    for _, v in pairs(Config.Locations["vehicle"]) do
        garageZones[#garageZones+1] = BoxZone:Create(
            vector3(v.x, v.y, v.z), 3, 3, {
            name="box_zone",
            debugPoly = true,
            minZ = v.z - 1,
            maxZ = v.z + 1,
        })
    end

    local garageCombo = ComboZone:Create(garageZones, {name = "garageCombo", debugPoly = true})
    garageCombo:onPlayerInOut(function(isPointInside, point)
        if isPointInside then
            inGarage = true
            if onDuty and PlayerJob.name == 'corrections' then
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    exports['qb-core']:DrawText('[E] Store Vehicle', 'left')
		    garage()
                else
                    local currentSelection = 0

                    for k, v in pairs(Config.Locations["vehicle"]) do
                        if #(point - vector3(v.x, v.y, v.z)) < 4 then
                            currentSelection = k
                        end
                    end
                    exports['qb-menu']:showHeader({
                        {
                            header = 'Prison Garage',
                            params = {
                                event = 'corrections:client:VehicleMenuHeader',
                                args = {
                                    currentSelection = currentSelection,
                                }
                            }
                        }
                    })
                end
            end
        else
            inGarage = false
            exports['qb-menu']:closeMenu()
            exports['qb-core']:HideText()
        end
    end)
end)

function stash()
    CreateThread(function()
        while true do
            Wait(0)
            if inStash and PlayerJob.name == 'corrections' then
                if onDuty then sleep = 5 end
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent("inventory:server:OpenInventory", "stash", "prisonstash_"..QBCore.Functions.GetPlayerData().citizenid)
                    TriggerEvent("inventory:client:SetCurrentStash", "prisonstash_"..QBCore.Functions.GetPlayerData().citizenid)
                    break
                end
            else
                break
            end
        end
    end)
end

function trash()
    CreateThread(function()
        while true do
            Wait(0)
            if inTrash and PlayerJob.name == 'corrections' then
                if onDuty then sleep = 5 end
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent("inventory:server:OpenInventory", "stash", "prisontrash", {
                        maxweight = 4000000,
                        slots = 300,
                    })
                    TriggerEvent("inventory:client:SetCurrentStash", "prisontrash")
                    break
                end
            else
                break
            end
        end
    end)
end

function armoury()
    CreateThread(function()
        while true do
            Wait(0)
            if inAmoury and PlayerJob.name == 'corrections' then
                if onDuty then sleep = 5 end
                if IsControlJustReleased(0, 38) then
                    TriggerEvent("qb-corrections:client:openArmoury")
                    break
                end
            else
                break
            end
        end
    end)
end

function garage()
    CreateThread(function()
        while true do
            Wait(0)
            if inGarage and PlayerJob.name == 'corrections' then
                if onDuty then sleep = 5 end
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    if IsControlJustReleased(0, 38) then
                        QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                        break
                    end
                end
            else
                break
            end
        end
    end)
end